class RemoveOldPlayerListIndexes < ActiveRecord::Migration[8.0]
  def change
    remove_index :player_lists, [:user_id, :position], if_exists: true
    remove_index :player_lists, [:user_id, :celebrity_id], if_exists: true
  end
end
