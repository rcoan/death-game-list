# frozen_string_literal: true

class AddLockedToGameYears < ActiveRecord::Migration[8.0]
  def change
    add_column :game_years, :locked, :boolean, default: false, null: false
  end
end

