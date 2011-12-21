class AddPublicToBooks < ActiveRecord::Migration
  def change
    add_column :books, :public, :boolean, :default => false
  end
end
