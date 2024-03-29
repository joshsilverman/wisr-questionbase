book = Book.create!(:name => 'Book #1', :author => 'StudyEgg', :edition => 1, :public => true, :user_id => 1)
book2 = Book.create!(:name => 'Book #2', :author => 'StudyEgg', :edition => 1, :public => true, :user_id => 1)

biology = Book.new
biology.name = 'Biology (Khan Academy)'
biology.author = 'StudyEgg'
biology.edition = 1
biology.public = true
biology.user_id = 1
biology.id = 13
biology.save

chemistry = Book.new
chemistry.name = 'Chemistry (Khan Academy)'
chemistry.author = 'StudyEgg'
chemistry.edition = 1
chemistry.public = true
chemistry.user_id = 1
chemistry.id = 14
chemistry.save

chapters = []
chapters << Chapter.create!(:book_id => book.id, :name => 'Chapter #1', :number => 1, :status => 3, :media_url => "http://www.youtube.com/watch?v=_-vZ_g7K6P0", :media_duration => 1685)
chapters << Chapter.create!(:book_id => book.id, :name => 'Chapter #2', :number => 2, :status => 3, :media_url => "http://www.youtube.com/watch?v=_-vZ_g7K6P0", :media_duration => 1685)
chapters << Chapter.create!(:book_id => book.id, :name => 'Chapter #3', :number => 3, :status => 3, :media_url => "http://www.youtube.com/watch?v=_-vZ_g7K6P0", :media_duration => 1685)
chapters << Chapter.create!(:book_id => book.id, :name => 'Chapter #4', :number => 4, :status => 3, :media_url => "http://www.youtube.com/watch?v=_-vZ_g7K6P0", :media_duration => 1685)
chapters << Chapter.create!(:book_id => book.id, :name => 'Chapter #5', :number => 5, :status => 3, :media_url => "http://www.youtube.com/watch?v=_-vZ_g7K6P0", :media_duration => 1685)

chapter = Chapter.create!(:book_id => book2.id, :name => 'Chapter #1', :number => 1, :status => 3, :media_url => "http://www.youtube.com/watch?v=_-vZ_g7K6P0", :media_duration => 1685)
book2.chapters << chapter
chapters << chapter

biology.chapters << Chapter.create!(:book_id => biology.id, :name => 'Biology Chapter #1', :number => 1, :status => 3, :media_url => "http://www.youtube.com/watch?v=_-vZ_g7K6P0", :media_duration => 1685)
chemistry.chapters << Chapter.create!(:book_id => chemistry.id, :name => 'Biology Chapter #1', :number => 1, :status => 3, :media_url => "http://www.youtube.com/watch?v=_-vZ_g7K6P0", :media_duration => 1685)

demo_chapter = Chapter.new
demo_chapter.book_id = book.id
demo_chapter.name = 'Chapter #5'
demo_chapter.number = 6
demo_chapter.status = 3
demo_chapter.id = 112
demo_chapter.media_url = "http://www.youtube.com/watch?v=_-vZ_g7K6P0"
demo_chapter.media_duration = 1685
demo_chapter.save
chapters << demo_chapter

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
	 #  	q.resources << Resource.create!(:question_id => q.id,
		# 	:url => 'http://weeklyguiltypleasure.files.wordpress.com/2011/07/rick-astley.jpg',
		# 	:contains_answer => false,
		# 	:media_type => 'image',
		# 	:begin => nil,
		# 	:end => nil,
		# 	:article_text => nil,
		# 	:table => nil,
		# 	:required => false
		# )	
		start_time = (i * 80) - 80
		# puts start_time
		end_time = start_time + 5
		q.resources << Resource.create!(:question_id => q.id,
			:url => "kpCJyQ2usJ4",
			:contains_answer => true,
			:media_type => "video",
			:begin => start_time,
			:end => end_time,
			:article_text => nil,
			:table => nil,
			:required => false
		)
		# q.resources << Resource.create!(:question_id => q.id,
		# 	:url => nil,
		# 	:contains_answer => true,
		# 	:media_type => 'text', 
		# 	:begin => nil,
		# 	:end => nil,
		# 	:article_text => "<h1>Test Article</h1><p>This is a text article</p>",
		# 	:table => nil,
		# 	:required => false
		# )	
	end
end