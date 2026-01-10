# frozen_string_literal: true

class AddUsernameToUsers < ActiveRecord::Migration[8.0]
  def up
    # Add username column as nullable first
    add_column :users, :username, :string
    
    # Generate usernames from emails for existing users using SQL
    execute <<-SQL
      UPDATE users
      SET username = LOWER(REGEXP_REPLACE(SPLIT_PART(email, '@', 1), '[^a-z0-9_]', '_', 'g'))
      WHERE email IS NOT NULL AND email != '';
    SQL
    
    # Handle users without email or with duplicate usernames
    execute <<-SQL
      UPDATE users
      SET username = 'user_' || id::text
      WHERE username IS NULL OR username = '';
    SQL
    
    # Fix duplicates by appending user id
    execute <<-SQL
      UPDATE users u1
      SET username = u1.username || '_' || u1.id::text
      WHERE EXISTS (
        SELECT 1 FROM users u2
        WHERE u2.username = u1.username AND u2.id < u1.id
      );
    SQL
    
    # Now make username required and add unique index
    change_column_null :users, :username, false
    add_index :users, :username, unique: true
    
    # Make email nullable since we're using username for authentication
    change_column_null :users, :email, true
  end

  def down
    remove_index :users, :username
    remove_column :users, :username
    change_column_null :users, :email, false
  end
end

