class AddSlaIdToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :sla_id, :integer
  end
end
