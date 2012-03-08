class AddAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :school, :string
    add_column :users, :user_type, :string
    add_column :users, :user_token, :string
  end
end