class CreateCelebrities < ActiveRecord::Migration[8.0]
  def change
    create_table :celebrities do |t|
      t.string :name, null: false
      t.integer :age_at_death
      t.date :death_date
      t.integer :points
      t.boolean :is_deceased, default: false, null: false

      t.timestamps
    end

    add_index :celebrities, :name, unique: true
  end
end
