task :collapse_types => :environment do
  Book.all.each do |book|
    puts "Book: #{book.to_json}"
    book.chapters.each do |chapter|
      puts "Chapter: #{chapter.to_json}"
      if chapter.name =~ /\(T\/F\)/
        new_id = Chapter.find_by_name(chapter.name.gsub("(T/F)", "(MC)")).id
        chapter.questions.each do |question|
          question.chapter_id = new_id
          puts "update question"
          puts question.to_json
          puts "\n\n"
          # question.save
        end
      end
    end    
  end
end

task :clear_collapsed_chapters => :environment do
  Chapter.all.each do |chapter|
    next unless chapter.name =~ /\(T\/F\)/ and chapter.questions.empty?
    puts "delete chapter:"
    puts chapter.to_json
    puts "\n\n"
    # chapter.delete
  end
end
