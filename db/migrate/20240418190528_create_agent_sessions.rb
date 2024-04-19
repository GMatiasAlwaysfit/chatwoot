class CreateAgentSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_sessions, id: :uuid do |t|
      t.string :account_id
      t.string :user_id
      t.string :contact_id
      t.uuid :tabulation_id
      t.timestamp :ended_at
      t.integer :sla_total_time
      t.integer :sla_missed_count
      t.string :sla_id

      t.timestamps
    end
  end
end
