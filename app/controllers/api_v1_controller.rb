class ApiV1Controller < ApplicationController

  def get_books
    egg_ids = params[:ids].split('+')
    @books = Book.where(:public => true, :id => egg_ids)
    respond_to :json
  end

  def get_book_details
    @book = Book.find(params[:id])
    @chapters = @book.chapters.where(:published => true).sort{|a, b| a.number <=> b.number}
    respond_to :json
  end
  
  def get_book_by_chapter_id
    @chapter = Chapter.find(params[:id])
    @book = Book.find(@chapter.book_id)
    
    respond_to :json
  end
  
  def get_lessons
    # Prevent unpublished chapters from being added here
    @lesson_ids = params[:ids].split('+')
    book_ids = Chapter.select(:book_id).where(:id => @lesson_ids, :published => true).group("chapters.book_id, chapters.id").collect(&:book_id)
    @books = Book.where(:id => book_ids)
    #@chapter = Chapter.includes(:book).where(:id => @lesson_ids)
    #@chapter = @chapter.sort!{|a, b| a.number <=> b.number}
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
    # puts @questions.to_json
    # json = @questions.to_json \
    #   :only => [:id, :question],
    #   :include => {
    #   :answers => {:only => [:id, :answer, :correct]},
    #   :resources => {:only => [:url, :contains_answer, :media_type, :begin, :end, :article_text]}
    # }
    # puts json
    # render :json => json
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
    keywords.uniq!.each do |keyword|
      keywords_questions = []
      keyword.questions.each {|question| keywords_questions << question.id if question_ids.include? question.id.to_s }
      topics_questions << {:keyword => keyword.keyword, :questions => keywords_questions}
    end
    render :json => topics_questions
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
end
