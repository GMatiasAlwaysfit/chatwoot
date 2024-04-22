# == Schema Information
#
# Table name: tabulations
#
#  id          :uuid             not null, primary key
#  description :string
#  end_phrase  :string
#  name        :string
#  tab_type    :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :bigint           not null
#
# Indexes
#
#  index_tabulations_on_account_id  (account_id)
#
class Tabulation < ApplicationRecord
  validates :name, uniqueness: { scope: :account_id }

  belongs_to :account
  has_many :inbox_tabulations, dependent: :destroy
  has_many :inboxes, through: :inbox_tabulations, dependent: :destroy
  has_many :agent_sessions
end
