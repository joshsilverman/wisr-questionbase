task :create_keywords => :environment do
  Question.all.each do |question|
    next unless question.words
    question.words.split("|").each do |word|
      keyword = word.strip.downcase
      if k = Keyword.find_by_keyword(keyword)
        question.keywords << k
      else
        k = Keyword.new
        k.keyword = keyword
        k.save
        question.keywords << k
      end
    end
  end
end
