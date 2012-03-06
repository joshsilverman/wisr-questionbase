class AddPublishedToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :published, :boolean, :default => 0
  end
end
