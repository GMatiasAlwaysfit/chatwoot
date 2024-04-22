class CreateAgentSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_sessions, id: :uuid do |t|
      t.references :account, null: false
      t.references :user
      t.references :contact
      t.references :tabulation, type: :uuid
      t.timestamp :ended_at
      t.integer :sla_total_time
      t.integer :sla_missed_count
      t.references :sla

      t.timestamps
    end
  end
end
