task :collapse_types => :environment do
  Book.all.each do |book|
    puts "\n\nBOOK: #{book.to_json}"
    chapters = book.chapters
    chapters.each do |chapter|
      if chapter.name
        if chapter.name =~ /\(T\/F\)/
          name = chapter.name.gsub("(T/F)", "(MC)").strip
          new_id = (chapters.select {|c| c.name.include? name}).first.id
          chapter.questions.each do |question|
            question.chapter_id = new_id
            question.save
          end
        end
      end
    end    
  end
end

task :clear_collapsed_chapters => :environment do
  Chapter.all.each do |chapter|
    next unless chapter.name =~ /\(T\/F\)/ and chapter.questions.empty?
    puts "\ndelete chapter:"
    puts chapter.to_json
    puts "\n\n"
    chapter.delete
  end
end
