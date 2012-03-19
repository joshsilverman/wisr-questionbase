class AddStatusToChapterAndRemovePublished < ActiveRecord::Migration
  def up
    add_column :chapters, :status, :integer, :default => 0
    Chapter.all.each do |chapter|
      if chapter.published
        chapter.status = 3
        chapter.save
      elsif !chapter.questions.blank?
        chapter.status = 1
        chapter.save
      end
    end
    remove_column :chapters, :published
  end

  def down
    remove_column :chapters, :status
    add_column :chapters, :published, :integer
  end

	#STATUS
	# 0 => unclaimed
	# 1 => in-progress
	# 2 => qc
	# 3 => published
end
