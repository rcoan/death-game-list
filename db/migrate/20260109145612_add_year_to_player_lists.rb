class AddYearToPlayerLists < ActiveRecord::Migration[8.0]
  def change
    add_column :player_lists, :year, :integer, null: false, default: Date.current.year
    add_index :player_lists, [:user_id, :year, :position], unique: true
    add_index :player_lists, [:user_id, :year, :celebrity_id], unique: true
  end
end
