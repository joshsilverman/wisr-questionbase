task :collapse_types => :environment do
  Book.all.each do |book|
    book.chapters.each do |chapter|
      if chapter.name =~ /\(T\/F\)/
        new_id = Chapter.find_by_name(chapter.name.gsub("(T/F)", "(MC)")).id
        chapter.questions.each do |question|
          question.chapter_id = new_id
          question.save
        end
      end
    end    
  end
end

task :clear_collapsed_chapters => :environment do
  Chapter.all.each do |chapter|
    next unless chapter.name =~ /\(T\/F\)/ and chapter.questions.empty?
    chapter.delete
  end
end
