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

task :guess_media_urls => :environment do
  book_ids = [13, 14, 15, 16, 17, 19]
  Chapter.where(:book_id => book_ids, :media_url => nil).each do |chapter|
    unless chapter.media_url
      chapter.questions.each do |question|
        unless chapter.media_url
          resource = question.resources.where(:media_type => "video").first
          chapter.media_url = "http://www.youtube.com/watch?v=#{resource.url}" if resource
          chapter.save
          puts chapter.to_json          
        end
      end
    end
  end
end
