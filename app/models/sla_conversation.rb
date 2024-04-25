# == Schema Information
#
# Table name: sla_conversations
#
#  id              :bigint           not null, primary key
#  waiting_since   :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint           not null
#  conversation_id :bigint           not null
#  sla_id          :bigint           not null
#
# Indexes
#
#  index_sla_conversations_on_account_id       (account_id)
#  index_sla_conversations_on_conversation_id  (conversation_id)
#  index_sla_conversations_on_sla_id           (sla_id)
#
class SlaConversation < ApplicationRecord
  belongs_to :account
  belongs_to :sla
  belongs_to :conversation
end
