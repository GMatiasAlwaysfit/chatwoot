class AddSlaMissedCountAndSlaMissedTimeToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :sla_missed_count, :integer, default: 0
    add_column :conversations, :sla_missed_time, :integer, default: 0
  end
end
