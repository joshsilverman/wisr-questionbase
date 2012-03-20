class AddMediaUrlAndAuthorIdToChapters < ActiveRecord::Migration
  def change
  	add_column :chapters, :media_url, :text
  	add_column :chapters, :author_id, :integer
  end
end
