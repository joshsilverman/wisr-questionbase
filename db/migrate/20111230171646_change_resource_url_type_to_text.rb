class ChangeResourceUrlTypeToText < ActiveRecord::Migration
  def up
    change_column :resources, :url, :text
  end

  def down
    change_column :resources, :url, :string
  end
end
