class AddMediaDurationToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :media_duration, :integer
  end
end
