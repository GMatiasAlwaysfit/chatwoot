class AddTransferObservationToTransfersSessions < ActiveRecord::Migration[7.0]
  def change
    add_column :transfers_sessions, :transfer_observation, :string
  end
end
