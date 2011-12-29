class RenameTypeInResources < ActiveRecord::Migration
  def change
    rename_column :resources, :type, :media_type
  end
end
