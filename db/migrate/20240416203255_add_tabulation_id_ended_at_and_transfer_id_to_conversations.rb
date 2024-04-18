class AddTabulationIdEndedAtAndTransferIdToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :tabulation_id, :uuid
  end
end
