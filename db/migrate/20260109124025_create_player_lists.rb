class CreatePlayerLists < ActiveRecord::Migration[8.0]
  def change
    create_table :player_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :celebrity, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :player_lists, [:user_id, :position], unique: true
    add_index :player_lists, [:user_id, :celebrity_id], unique: true
  end
end
