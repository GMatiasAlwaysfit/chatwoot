class AutoAssignment::AgentAssignmentService
  # Allowed agent ids: array
  # This is the list of agents from which an agent can be assigned to this conversation
  # examples: Agents with assignment capacity, Agents who are members of a team etc
  pattr_initialize [:conversation!, :allowed_agent_ids!]

  def find_assignee
    round_robin_manage_service.available_agent(allowed_agent_ids: allowed_online_agent_ids)
  end

  def perform
    new_assignee = find_assignee
    if conversation.waiting_since.present? && conversation.assignee_id.blank? && conversation.first_reply_created_at.blank? && find_assignee
      conversation.update(waiting_since: Time.zone.now)
    end
    conversation.update(assignee: new_assignee) if new_assignee

    ongoing_session = AgentSession.where(contact_id: conversation.contact_id, ended_at: nil)

    if !ongoing_session.exists? && conversation.assignee_id.present?
      AgentSession.create!(
        account_id: conversation.account_id,
        contact_id: conversation.contact_id,
        user_id: conversation.assignee_id,
      )
    end
  end

  private

  def online_agent_ids
    online_agents = OnlineStatusTracker.get_available_users(conversation.account_id)
    online_agents.select { |_key, value| value.eql?('online') }.keys if online_agents.present?
  end

  def allowed_online_agent_ids
    # We want to perform roundrobin only over online agents
    # Hence taking an intersection of online agents and allowed member ids

    # the online user ids are string, since its from redis, allowed member ids are integer, since its from active record
    @allowed_online_agent_ids ||= online_agent_ids & allowed_agent_ids&.map(&:to_s)
  end

  def round_robin_manage_service
    @round_robin_manage_service ||= AutoAssignment::InboxRoundRobinService.new(inbox: conversation.inbox)
  end

  def round_robin_key
    format(::Redis::Alfred::ROUND_ROBIN_AGENTS, inbox_id: conversation.inbox_id)
  end
end
