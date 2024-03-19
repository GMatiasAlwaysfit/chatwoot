class CreateSlas < ActiveRecord::Migration[7.0]
  def change
    create_table :slas do |t|
      t.string :name
      t.float :alert_time
      t.float :limit_time
      t.float :max_time
      t.boolean :agent_online, default: false
      t.references :account, null: false, index: true

      t.timestamps
    end
  end
end
