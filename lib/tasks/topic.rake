task :create_topics => :environment do
  Question.all.each do |question|
    puts question.topic
    puts question.keywords
    puts "\n\n"
  end
end
