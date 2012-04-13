book = Book.create!(:name => 'Book #1', :author => 'StudyEgg', :edition => 1, :public => true, :user_id => 1)

book2 = Book.create!(:name => 'Book #2', :author => 'StudyEgg', :edition => 1, :public => true, :user_id => 1)

chapters = []
chapters << Chapter.create!(:book_id => book.id, :name => 'Chapter #1', :number => 1, :status => 3)
chapters << Chapter.create!(:book_id => book.id, :name => 'Chapter #2', :number => 2, :status => 3)
chapters << Chapter.create!(:book_id => book.id, :name => 'Chapter #3', :number => 3, :status => 3)
chapters << Chapter.create!(:book_id => book.id, :name => 'Chapter #4', :number => 4, :status => 3)
chapters << Chapter.create!(:book_id => book.id, :name => 'Chapter #5', :number => 5, :status => 3)

demo_chapter = Chapter.new
demo_chapter.book_id = book.id
demo_chapter.name = 'Chapter #5'
demo_chapter.number = 6
demo_chapter.status = 3
demo_chapter.id = 112
demo_chapter.save
chapters << demo_chapter

book2.chapters << Chapter.create!(:book_id => book2.id, :name => 'Chapter #1', :number => 1, :status => 3)

strengths = []
for k in 1..3
	strengths << Keyword.create!(:keyword => "Strong Keyword ##{k}")
end

weaknesses = []
for k in 1..3
	weaknesses << Keyword.create!(:keyword => "Weak Keyword ##{k}")
end

chapters.each do |chapter|
	for i in 1..20
		q = Question.create!(:question => "This is question number ##{i}?", 
			:user_id => 1,
			:chapter_id => chapter.id
		)
		q.answers << Answer.create!(:question_id => q.id, :answer => 'Correct', :correct => true)
		for a in 1..3
			q.answers << Answer.create!(:question_id => q.id, :answer => "Incorrect ##{a}", :correct => false)
		end	
		if (i % 2 == 0)
			for keyword in strengths
				q.keywords << keyword
			end
		else
			for keyword in weaknesses
				q.keywords << keyword
			end
		end
	  q.resources << Resource.create!(:question_id => q.id,
			:url => 'http://weeklyguiltypleasure.files.wordpress.com/2011/07/rick-astley.jpg',
			:contains_answer => false,
			:media_type => 'image',
			:begin => nil,
			:end => nil,
			:article_text => nil,
			:table => nil,
			:required => false
		)	
		q.resources << Resource.create!(:question_id => q.id,
			:url => "kpCJyQ2usJ4",
			:contains_answer => true,
			:media_type => "video",
			:begin => 5,
			:end => 15,
			:article_text => nil,
			:table => nil,
			:required => false
		)
		q.resources << Resource.create!(:question_id => q.id,
			:url => nil,
			:contains_answer => true,
			:media_type => 'text', 
			:begin => nil,
			:end => nil,
			:article_text => "<h1>Test Article</h1><p>This is a text article</p>",
			:table => nil,
			:required => false
		)	
	end
end