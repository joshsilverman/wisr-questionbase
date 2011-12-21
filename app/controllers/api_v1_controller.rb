class ApiV1Controller < ApplicationController
  def get_books
    egg_ids = params[:ids].split('+')
    @books = Book.where(:public => true, :id => egg_ids)
    respond_to :json
  end

  def get_book_details
    @book = Book.find(params[:id])
    
    respond_to :json
  end
  
  def get_lessons
    @lesson_ids = params[:ids].split('+')
    book_ids = Chapter.where(:id => @lesson_ids).group(:book_id).collect(&:book_id)
    @books = Book.where(:id => book_ids)
    puts @books
    respond_to :json
  end
  
  def get_questions
    @chapter = Chapter.find(params[:id])
    @questions = @chapter.questions.sort!{|a, b| a.created_at <=> b.created_at}
    
    respond_to :json
  end
end