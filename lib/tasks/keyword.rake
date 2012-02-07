task :create_keywords => :environment do
  Question.all.each do |question|
    puts question.keywords
    puts "\n\n"
  end
end
