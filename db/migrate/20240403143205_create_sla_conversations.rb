class CreateSlaConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :sla_conversations do |t|
      t.references :account, null: false
      t.references :sla, null: false
      t.references :conversation, null: false
      t.datetime :waiting_since, optional: true

      t.timestamps
    end
  end
end
