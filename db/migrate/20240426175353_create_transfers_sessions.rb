class CreateTransfersSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :transfers_sessions, id: :uuid do |t|
      t.uuid :id_session_origin, null: false
      t.uuid :id_session_destination, null: false

      t.timestamps
    end
  end
end