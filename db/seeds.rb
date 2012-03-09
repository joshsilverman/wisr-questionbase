# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
puts "Make Book"
@book = Book.create(:id => 99999, :name => 'public test book', :author => 'se_teacher', :edition => 1, :public => true, :user_id => 999999)
puts @book.inspect
puts "Make Chapter"
@chapter = Chapter.create(:book_id => @book.id, :name => 'public test chapter', :number => 1)
puts @chapter.inspect
keywords = []
for i in 1..4
	keywords << Keyword.create!(:keyword => "keyword#{i}")
end

for i in 1..20
  puts i
	q = Question.create!(:question => "This is question number #{i}", 
    								:user_id => 999999,
    								:chapter_id => @chapter.id)
  Answer.create!(:question_id => q.id, :answer => 'correct', :correct => true)
  Answer.create!(:question_id => q.id, :answer => 'wrong1', :correct => false)
  Answer.create!(:question_id => q.id, :answer => 'wrong2', :correct => false)
  Answer.create!(:question_id => q.id, :answer => 'wrong3', :correct => false)
  mod = i%4
  case mod
  when 0
    q.keywords << keywords.sample(rand(keywords.size))
  when 1
  	Resource.create!(:question_id => q.id,
  										:url => "oHg5SJYRHA0",
					            :contains_answer => true,
    									:media_type => "video",
    									:begin => nil,
    									:end => nil,
    									:article_text => nil,
											:table => nil,
											:required => false)

	  Resource.create!(:question_id => q.id,
  										:url => 'http://weeklyguiltypleasure.files.wordpress.com/2011/07/rick-astley.jpg',
											:contains_answer => false,
    									:media_type => 'image',
    									:begin => nil,
    									:end => nil,
    									:article_text => nil,
											:table => nil,
											:required => false)

    q.keywords << keywords.sample(rand(keywords.size))
  when 2
  	Resource.create!(:question_id => q.id,
                      :url => 'http://weeklyguiltypleasure.files.wordpress.com/2011/07/rick-astley.jpg',
                      :contains_answer => true,
                      :media_type => 'image',
                      :begin => nil,
                      :end => nil,
                      :article_text => nil,
                      :table => nil,
                      :required => false)

    q.keywords << keywords.sample(rand(keywords.size))
  when 3
  	Resource.create!(:question_id => q.id,
  										:url => nil,
											:contains_answer => true,
    									:media_type => 'text', 
    									:begin => nil,
    									:end => nil,
    									:article_text => "<h1>Test Article</h1><p>This is a text article</p>",
											:table => nil,
											:required => false)

    q.keywords << keywords.sample(rand(keywords.size))
  else
    puts "THIS SHOULD NEVER HAPPEN"
  end
end