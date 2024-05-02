class AddTransferObservationToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :transfer_observation, :string
  end
end
