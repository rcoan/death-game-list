# frozen_string_literal: true

class AddStartDateToGameYears < ActiveRecord::Migration[8.0]
  def change
    add_column :game_years, :start_date, :date
    
    # Set default start_date for existing years (15/01 of that year)
    GameYear.find_each do |gy|
      gy.update_column(:start_date, Date.new(gy.year, 1, 15))
    end
    
    change_column_null :game_years, :start_date, false
  end
end

