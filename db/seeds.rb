book = Book.create!(:name => 'Book #1', :author => 'StudyEgg', :edition => 1, :public => true, :user_id => 1)
chapter = Chapter.create!(:book_id => book.id, :name => 'Chapter #1', :number => 1)
for i in 1..20
	q = Question.create!(:question => "This is question number #{i}?", 
		:user_id => 1,
		:chapter_id => chapter.id
	)
	Answer.create!(:question_id => q.id, :answer => 'Correct', :correct => true)
	for j in 1..3
		Answer.create!(:question_id => q.id, :answer => 'Incorrect #{j}', :correct => false)
	end	
	for j in 1..3
		q.keywords << Keyword.create!(:keyword => "Keyword #{j}")
	end
  q.resources << 	Resource.create!(:question_id => q.id,
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