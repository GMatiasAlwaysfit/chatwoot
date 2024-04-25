class Api::V1::Accounts::Conversations::AssignmentsController < Api::V1::Accounts::Conversations::BaseController
  # assigns agent/team to a conversation
  def create
    if params.key?(:assignee_id)
      set_agent
    elsif params.key?(:team_id)
      set_team
    else
      render json: nil
    end
  end

  private

  def set_agent
    if @conversation.waiting_since.present? && @conversation.assignee_id.blank? && @conversation.first_reply_created_at.blank?
      @conversation.update(waiting_since: Time.zone.now)
    end
    @agent = Current.account.users.find_by(id: params[:assignee_id])

    handle_agent_session_on_direct_transfer

    @conversation.assignee = @agent
    @conversation.save!
    render_agent
  end

  def handle_agent_session_on_direct_transfer
    ongoing_session = AgentSession.where(contact_id: @conversation.contact_id, ended_at: nil)

    if ongoing_session.exists?
      calculate_sla_missed_time_after_transfer(@conversation) if @conversation.waiting_since.present?

      ongoing_session.update!(ended_at: Time.zone.now, tabulation_id: @conversation.tabulation_id, sla_total_time: @conversation.sla_missed_time,
                              sla_missed_count: @conversation.sla_missed_count, sla_id: @conversation.sla_id)

      @conversation.update!(sla_missed_time: 0, sla_missed_count: 0)

      AgentSession.create!(
        account_id: @conversation.account_id,
        contact_id: @conversation.contact_id,
        user_id: @agent.id
      )
    else
      AgentSession.create!(
        account_id: @conversation.account_id,
        contact_id: @conversation.contact_id,
        user_id: @agent.id
      )

      @conversation.update!(sla_missed_time: 0, sla_missed_count: 0, waiting_since: @conversation.waiting_since.present? ? Time.zone.now : nil)
    end
  end

  def calculate_sla_missed_time_after_transfer(conversation)
    sla = Sla.find_by(id: conversation.sla_id)

    time = conversation.waiting_since.to_i + sla.limit_time.to_i

    @conversation.update!(waiting_since: Time.zone.now)

    return unless Time.zone.now.to_i > time

    difference_in_seconds = Time.zone.now.to_i - time

    conversation.increment!(:sla_missed_count, 1)
    conversation.increment!(:sla_missed_time, difference_in_seconds)
  end

  def render_agent
    if @agent.nil?
      render json: nil
    else
      render partial: 'api/v1/models/agent', formats: [:json], locals: { resource: @agent }
    end
  end

  def set_team
    @team = Current.account.teams.find_by(id: params[:team_id])
    @conversation.update!(team: @team)
    render json: @team
  end
end
