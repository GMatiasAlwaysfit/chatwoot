# == Schema Information
#
# Table name: agent_sessions
#
#  id               :uuid             not null, primary key
#  ended_at         :datetime
#  sla_missed_count :integer
#  sla_total_time   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  contact_id       :bigint
#  sla_id           :bigint
#  tabulation_id    :uuid
#  user_id          :bigint
#
# Indexes
#
#  index_agent_sessions_on_account_id     (account_id)
#  index_agent_sessions_on_contact_id     (contact_id)
#  index_agent_sessions_on_sla_id         (sla_id)
#  index_agent_sessions_on_tabulation_id  (tabulation_id)
#  index_agent_sessions_on_user_id        (user_id)
#
class AgentSession < ApplicationRecord
  belongs_to :account
  belongs_to :tabulation, optional: true
  belongs_to :sla, optional: true
  belongs_to :user, optional: true
  belongs_to :contact, optional: true
end
