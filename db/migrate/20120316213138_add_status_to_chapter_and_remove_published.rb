class AddStatusToChapterAndRemovePublished < ActiveRecord::Migration
  def change
  	#STATUS
  	# 0 => unclaimed
  	# 1 => in-progress
  	# 2 => qc
  	# 3 => published
  	add_column :chapters, :status, :integer, :default => 0
  	Chapter.all.each do |chapter|
  		if chapter.published
  			chapter.status = 3
  			chapter.save
  		end
  	end
  	remove_column :chapters, :published
  end
end
