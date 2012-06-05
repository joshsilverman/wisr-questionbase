class ApiV1Controller < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :valid_key?

  def get_books
    egg_ids = params[:ids].split('+')
    @books = Book.where(:public => true, :id => egg_ids)
    respond_to :json
  end

  def get_book_details
    @book = Book.find(params[:id])
    @chapters = @book.chapters.where(:status => 3).sort{|a, b| a.number <=> b.number}
    respond_to :json
  end
  
  def get_book_by_chapter_id
    @chapter = Chapter.find(params[:id])
    @book = Book.find(@chapter.book_id)
    respond_to :json
  end

  def get_book_id_by_chapter_id
    chapter = Chapter.find(params[:id])
    if chapter
      course_id = chapter.book_id
    else
      course_id = nil
    end
    render :json => course_id
  end
 
  def get_lessons
    @lesson_ids = params[:ids].split('+')
    book_ids = Chapter.select(:book_id).where(:id => @lesson_ids, :status => 3).group("chapters.book_id, chapters.id").collect(&:book_id)
    @books = Book.where(:id => book_ids).includes(:chapters).where("chapters.id IN (?)", @lesson_ids)
    respond_to :json
  end
  
  def get_courses_lessons
    course_ids = params[:ids].split('+')
    render :json => Chapter.select(:id).where(:book_id => course_ids, :status => 3).collect(&:id)
  end

  def get_lesson_details
    render :json => Chapter.where(:id => params[:ids].split('+')).select([:id, :name])
  end

  def get_index_data
    course_ids = params["course_ids"].split("+")
    lesson_ids = params["lesson_ids"].split("+") 

    # @courses = Book.select(["books.id", "books.name", "chapters.id", "questions.id"]).find(course_ids, :include => {:chapters => :questions})
    # puts @courses.to_json(:include => {:chapters => {:include => :questions}})
    lessons_course_ids = Chapter.select(:book_id).where("id IN (?) AND book_id NOT IN (?)", lesson_ids, course_ids).collect(&:book_id).uniq!#.includes(:questions).select(:id)
    courses = Book.where("id IN (?) OR id in (?)", course_ids, lessons_course_ids).select([:name, :id])
    
    # courses = {:courses => courses.to_json}#.to_json
    # puts courses
    lessons = Chapter.where("book_id IN (?) OR id IN (?)", course_ids, lesson_ids).select([:id, :book_id]).group_by(&:book_id)

    # puts lessons.to_json

    questions = Question.where(:chapter_id => lesson_ids).select([:id, :chapter_id]).group_by(&:chapter_id)
    # lessons = {:lessons => lessons.as_json}
    # puts lessons
    # puts questions
    hash = {:courses => []}
    courses.as_json.each do |course|
      # puts course
      hash[:courses] << course.as_json
      # lessons[course["id"]].each do |lesson|
      #   puts lesson["id"]
      #   puts questions[lesson["id"]].as_json
      # end
      # puts "\n\n"
    end
    puts hash.to_json

    # Chapter.where("id IN lesson_ids")
    # puts lessons.to_json(:include => :questions)
    # courses = Book.find(course_ids, :include => {:chapters => :questions})
    # puts courses.to_json(:include => {:chapters => {:include => :questions}})
    # courses = Book.where(:id => course_ids)
    # chapters = Chapter.where(:id => @lesson_ids).includes(:questions).select(:id)
    # @courses = Book.find(course_ids)
    # chapters.each do |c|
    #   c.questions.each do |q|
    #     puts q.id
    #   end
    # end
    # puts chapters.to_json
    # puts course_ids.to_json, lesson_ids.to_json
    # render :json => chapters
    # respond_to :json
  end

  def get_all_questions
    @lesson = Chapter.find(params[:id])
    @book_name = Book.find(@lesson.book_id).name
    respond_to :json
  end

  def get_all_question_ids_from_lesson
    @question_ids = params[:ids].split('+')
    @question_ids = Question.select('id').where(:chapter_id => @question_ids).collect(&:id)
    render :json => @question_ids
  end

  def get_questions
    @question_ids = params[:ids].split('+')
    @questions = Question.includes(:answers, :resources).where(:id => @question_ids).sort!{|a, b| @question_ids.index(a["id"].to_s) <=> @question_ids.index(b["id"].to_s)}
    respond_to :json
  end
  
  def get_lessons_questions
    render :json => Question.select([:id, :chapter_id]).where(:chapter_id => params[:ids].split('+')).group_by(&:chapter_id)
  end

  def get_question_count
    render :json => Chapter.find(params[:chapter_id]).questions.count
  end

  def get_questions_topics(keywords = [], topics_questions = [])
    question_ids = params[:question_ids].split('+')
    Question.find(question_ids, :include => :keywords).each do |question|
      question.keywords.each {|keyword| keywords << keyword}
    end
    if keywords.blank?
      render :nothing => true
    else
      keywords = keywords.uniq if keywords.uniq
      keywords.each do |keyword|
        keywords_questions = []
        keyword.questions.each {|question| keywords_questions << question.id if question_ids.include? question.id.to_s }
        topics_questions << {:keyword => keyword.keyword, :questions => keywords_questions}
      end
      render :json => topics_questions
    end
    # questions = Question.select('questions.*', 'keywords.keyword').include(:keywords).where(:id => question_ids)
    # puts questions.to_json
    # questions.each do |question|
    #   puts question.keywords.to_json
    # end
    # puts questions.to_json
    # question_ids.each do |question_id|
    #   Question.find(question_id)#.keywords.each do |keyword|
    # #     keywords << keyword if !keywords.include? keyword
    # #   end
    # end
    # keywords.each do |keyword|
    #   kq = []
    #   keyword.questions.each do |question|
    #     if question_ids.include? question.id.to_s
    #       kq << question.id
    #     end
    #   end
    #   topics_questions << {:keyword => keyword.keyword, :questions => kq}
    # end
    # render :json => topics_questions
  end

  def get_public
    @book = @books = Book.where(:public => true)
    respond_to :json
  end

  def get_public_with_lessons
    # @book = @books = Book.find(:all, :include => :chapters, :conditions => ["public = true AND chapters.status = 3"])
    @book = @books = Book.where(:public => true).includes(:chapters)
    respond_to :json
  end

  protected

  def valid_key?
    return if params[:api_key] == STUDYEGG_API_KEY 
    render :json => {:error => "Invalid API key value!"}
  end
end
