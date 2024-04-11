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
  belongs_to :account
end
