class CreateYears < ActiveRecord::Migration[8.0]
  def change
    create_table :years do |t|
      t.integer :value, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end

    add_index :years, :value, unique: true
  end
end
