class CreateInboxTabulations < ActiveRecord::Migration[7.0]
  def change
    create_table :inbox_tabulations, id: :uuid do |t|
      t.references :tabulation, type: :uuid, null: false
      t.references :inbox, null: false
      t.references :account, null: false

      t.timestamps
    end
  end
end
