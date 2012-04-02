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
  
  def get_lessons
    @lesson_ids = params[:ids].split('+')
    book_ids = Chapter.select(:book_id).where(:id => @lesson_ids, :status => 3).group("chapters.book_id, chapters.id").collect(&:book_id)
    @books = Book.where(:id => book_ids).includes(:chapters).where("chapters.id IN (?)", @lesson_ids)
    respond_to :json
  end
  
  def get_lesson_details
    chapters = []
    params[:ids].split('+').each do |id|
      chapter = Chapter.find(id)
      chapters << {:id => chapter.id, :name => chapter.name}
    end
    render :json => chapters
  end

  def get_all_questions
    @questions = Chapter.find(params[:id]).questions.includes(:answers, :resources).sort!{|a, b| a.created_at <=> b.created_at}
    respond_to :json
  end

  def get_all_question_ids_from_lesson
    @question_ids = Question.select('id').where(:chapter_id => params[:id]).collect(&:id)
    render :json => @question_ids
  end

  def get_questions
    @question_ids = params[:ids].split('+')
    @questions = Question.includes(:answers, :resources).where(:id => @question_ids).sort!{|a, b| a.created_at <=> b.created_at}
    respond_to :json
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
