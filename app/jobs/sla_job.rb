class SlaJob < ApplicationJob
  queue_as :medium

  def perform
    AppliedSla.where(status: 'active').each do |applied_sla|
      process_sla(applied_sla)

      return unless applied_sla.conversation.resolved?
      handle_sla_hit(applied_sla) if applied_sla.status == 'active'
    end
  end

  private

  def process_sla(applied_sla)
    sla = Sla.find_by(id: applied_sla.sla_id)
    conversation = Conversation.find_by(id: applied_sla.conversation_id)

    check_max_time_limit(applied_sla, conversation, sla)
  end

  def exceeded_max_time_limit?(max_time)
    Time.zone.now.to_i < max_time
  end

  def check_max_time_limit(applied_sla, conversation, sla)
    max_time = conversation.created_at.to_i + sla.max_time.to_i
    
    return if exceeded_max_time_limit?(max_time)

    handle_sla_miss(applied_sla)
  end

  def handle_sla_miss(applied_sla)
    return unless applied_sla.status == 'active'

    applied_sla.update!(status: 'missed')
  end

  def handle_sla_hit(applied_sla)
    return unless applied_sla.status == 'active'

    applied_sla.update!(status: 'hit')
  end
end