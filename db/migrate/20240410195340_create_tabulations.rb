class CreateTabulations < ActiveRecord::Migration[7.0]
  def change
    create_table :tabulations, id: :uuid do |t|
      t.string :name
      t.string :description
      t.string :end_phrase
      t.string :tab_type
      t.references :account, null: false, index: true

      t.timestamps
    end
  end
end
