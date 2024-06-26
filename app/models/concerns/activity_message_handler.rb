module ActivityMessageHandler
  extend ActiveSupport::Concern

  include PriorityActivityMessageHandler

  private

  def create_activity
    user_name = Current.user.name if Current.user.present?
    status_change_activity(user_name) if saved_change_to_status?
    priority_change_activity(user_name) if saved_change_to_priority?
    create_label_change(activity_message_ownner(user_name)) if saved_change_to_label_list?
  end

  def status_change_activity(user_name)
    content = if Current.executed_by.present?
                automation_status_change_activity_content
              else
                user_status_change_activity_content(user_name)
              end

    ::Conversations::ActivityMessageJob.perform_later(self, activity_message_params(content)) if content
    create_or_update_session(self)
  end

  def create_or_update_session(conversation)
    ongoing_session = nil

    ongoing_session = AgentSession.where(contact_id: conversation.contact_id, ended_at: nil)

    if !ongoing_session.exists? && conversation.status == 'open'
      AgentSession.create!(
        account_id: conversation.account_id,
        contact_id: conversation.contact_id,
        user_id: conversation.assignee_id,
      )
    elsif conversation.status == 'resolved' && ongoing_session.exists?
      calculate_sla_missed_time_after_resolved(conversation) if conversation.waiting_since.present?

      ongoing_session.update!(ended_at: Time.zone.now, tabulation_id: conversation.tabulation_id, sla_total_time: conversation.sla_missed_time,
                              sla_missed_count: conversation.sla_missed_count, sla_id: conversation.sla_id)

      conversation.update!(sla_missed_time: 0, sla_missed_count: 0, waiting_since: nil, tabulation_id: nil)
    end
  end

  def calculate_sla_missed_time_after_resolved(conversation)
    sla = Sla.find_by(id: conversation.sla_id)

    time = conversation.waiting_since.to_i + sla.limit_time.to_i

    return unless Time.zone.now.to_i > time

    difference_in_seconds = Time.zone.now.to_i - time

    conversation.increment!(:sla_missed_count, 1)
    conversation.increment!(:sla_missed_time, difference_in_seconds)
  end

  def user_status_change_activity_content(user_name)
    if user_name
      I18n.t("conversations.activity.status.#{status}", user_name: user_name)
    elsif Current.contact.present? && resolved?
      I18n.t('conversations.activity.status.contact_resolved', contact_name: Current.contact.name.capitalize)
    elsif resolved?
      I18n.t('conversations.activity.status.auto_resolved', duration: auto_resolve_duration)
    end
  end

  def automation_status_change_activity_content
    if Current.executed_by.instance_of?(AutomationRule)
      I18n.t("conversations.activity.status.#{status}", user_name: 'Automation System')
    elsif Current.executed_by.instance_of?(Contact)
      Current.executed_by = nil
      I18n.t('conversations.activity.status.system_auto_open')
    end
  end

  def activity_message_params(content)
    { account_id: account_id, inbox_id: inbox_id, message_type: :activity, content: content }
  end

  def create_label_added(user_name, labels = [])
    create_label_change_activity('added', user_name, labels)
  end

  def create_label_removed(user_name, labels = [])
    create_label_change_activity('removed', user_name, labels)
  end

  def create_label_change_activity(change_type, user_name, labels = [])
    return unless labels.size.positive?

    content = I18n.t("conversations.activity.labels.#{change_type}", user_name: user_name, labels: labels.join(', '))
    ::Conversations::ActivityMessageJob.perform_later(self, activity_message_params(content)) if content
  end

  def create_muted_message
    create_mute_change_activity('muted')
  end

  def create_unmuted_message
    create_mute_change_activity('unmuted')
  end

  def create_mute_change_activity(change_type)
    return unless Current.user

    content = I18n.t("conversations.activity.#{change_type}", user_name: Current.user.name)
    ::Conversations::ActivityMessageJob.perform_later(self, activity_message_params(content)) if content
  end

  def generate_team_change_activity_key
    team = Team.find_by(id: team_id)
    key = team.present? ? 'assigned' : 'removed'
    key += '_with_assignee' if key == 'assigned' && saved_change_to_assignee_id? && assignee
    key
  end

  def generate_team_name_for_activity
    previous_team_id = previous_changes[:team_id][0]
    Team.find_by(id: previous_team_id)&.name if previous_team_id.present?
  end

  def create_team_change_activity(user_name)
    user_name = activity_message_ownner(user_name)
    return unless user_name

    key = generate_team_change_activity_key
    params = { assignee_name: assignee&.name, team_name: team&.name, user_name: user_name }
    params[:team_name] = generate_team_name_for_activity if key == 'removed'
    content = I18n.t("conversations.activity.team.#{key}", **params)

    handle_agent_session_on_team_transfer(self) if key == 'assigned_with_assignee'

    ::Conversations::ActivityMessageJob.perform_later(self, activity_message_params(content)) if content
    ::Conversations::ActivityMessageJob.perform_later(self, activity_message_params("Observação: #{self.transfer_observation}")) if self.transfer_observation.present? && key == 'assigned_with_assignee'
  end

  def handle_agent_session_on_team_transfer(conversation)
    ongoing_session = AgentSession.where(contact_id: conversation.contact_id, ended_at: nil)

    if ongoing_session.exists?
      calculate_sla_missed_time_after_transfer(conversation) if conversation.waiting_since.present?

      ongoing_session.update!(ended_at: Time.zone.now, tabulation_id: conversation.tabulation_id, sla_total_time: conversation.sla_missed_time,
                              sla_missed_count: conversation.sla_missed_count, sla_id: conversation.sla_id)

      conversation.update!(sla_missed_time: 0, sla_missed_count: 0)

      new_session = AgentSession.create!(
        account_id: conversation.account_id,
        contact_id: conversation.contact_id,
        user_id: conversation.assignee_id
      )

      TransfersSession.create!(id_session_origin: ongoing_session.first.id, id_session_destination: new_session.id, transfer_observation: conversation.transfer_observation)
    else
      AgentSession.create!(
        account_id: conversation.account_id,
        contact_id: conversation.contact_id,
        user_id: conversation.assignee_id
      )

      conversation.update!(sla_missed_time: 0, sla_missed_count: 0, waiting_since: conversation.waiting_since.present? ? Time.zone.now : nil)
    end
  end

  def calculate_sla_missed_time_after_transfer(conversation)
    sla = Sla.find_by(id: conversation.sla_id)

    time = conversation.waiting_since.to_i + sla.limit_time.to_i

    conversation.update!(waiting_since: Time.zone.now)

    return unless Time.zone.now.to_i > time

    difference_in_seconds = Time.zone.now.to_i - time

    conversation.increment!(:sla_missed_count, 1)
    conversation.increment!(:sla_missed_time, difference_in_seconds)
  end

  def generate_assignee_change_activity_content(user_name)
    params = { assignee_name: assignee&.name, user_name: user_name }.compact
    key = assignee_id ? 'assigned' : 'removed'
    key = 'self_assigned' if self_assign? assignee_id
    I18n.t("conversations.activity.assignee.#{key}", **params)
  end

  def create_assignee_change_activity(user_name)
    user_name = activity_message_ownner(user_name)

    return unless user_name

    content = generate_assignee_change_activity_content(user_name)
    ::Conversations::ActivityMessageJob.perform_later(self, activity_message_params(content)) if content
    ::Conversations::ActivityMessageJob.perform_later(self, activity_message_params("Observação: #{self.transfer_observation}")) if self.transfer_observation.present?
  end

  def activity_message_ownner(user_name)
    user_name = 'Automation System' if !user_name && Current.executed_by.present?
    user_name
  end
end
