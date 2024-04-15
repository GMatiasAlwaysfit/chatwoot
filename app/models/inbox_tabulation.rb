# == Schema Information
#
# Table name: inbox_tabulations
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :bigint           not null
#  inbox_id      :bigint           not null
#  tabulation_id :uuid             not null
#
# Indexes
#
#  index_inbox_tabulations_on_account_id     (account_id)
#  index_inbox_tabulations_on_inbox_id       (inbox_id)
#  index_inbox_tabulations_on_tabulation_id  (tabulation_id)
#
class InboxTabulation < ApplicationRecord
  belongs_to :tabulation
  belongs_to :inbox
  belongs_to :account
end
