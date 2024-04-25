# == Schema Information
#
# Table name: slas
#
#  id           :bigint           not null, primary key
#  agent_online :boolean          default(FALSE)
#  alert_time   :float
#  limit_time   :float
#  max_time     :float
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :bigint           not null
#
# Indexes
#
#  index_slas_on_account_id  (account_id)
#
class Sla < ApplicationRecord
  validates :name, uniqueness: { scope: :account_id }

  belongs_to :account
  has_many :conversations, dependent: :nullify
  has_many :sla_conversations, dependent: :destroy
end
