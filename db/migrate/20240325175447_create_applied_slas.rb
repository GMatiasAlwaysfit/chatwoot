class CreateAppliedSlas < ActiveRecord::Migration[7.0]
  def change
    create_table :applied_slas do |t|
      t.references :account, null: false
      t.references :sla, null: false
      t.references :conversation, null: false
      t.string :status

      t.timestamps
    end
  end
end
