class CreateGameYears < ActiveRecord::Migration[8.0]
  def change
    create_table :game_years do |t|
      t.integer :year, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end

    add_index :game_years, :year, unique: true
  end
end
