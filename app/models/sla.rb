# == Schema Information
#
# Table name: slas
#
#  id         :bigint           not null, primary key
#  alert_time :float
#  limit_time :float
#  max_time   :float
#  name       :string
#  online     :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#
# Indexes
#
#  index_slas_on_account_id  (account_id)
#
class Sla < ApplicationRecord
  belongs_to :account
end
