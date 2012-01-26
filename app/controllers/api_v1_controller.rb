class ApiV1Controller < ApplicationController
  def get_books
    egg_ids = params[:ids].split('+')
    @books = Book.where(:public => true, :id => egg_ids)
    respond_to :json
  end

  def get_book_details
    @book = Book.find(params[:id])
    @chapters = @book.chapters.sort{|a, b| a.number <=> b.number}
    respond_to :json
  end
  
  def get_book_by_chapter_id
    @chapter = Chapter.find(params[:id])
    @book = Book.find(@chapter.book_id)
    
    respond_to :json
  end
  
  def get_lessons
    @lesson_ids = params[:ids].split('+')
    book_ids = Chapter.select(:book_id).where(:id => @lesson_ids).group("chapters.book_id, chapters.id").collect(&:book_id)
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
    @chapter = Chapter.find(params[:id])
    @questions = @chapter.questions.includes(:answers, :resources).sort!{|a, b| a.created_at <=> b.created_at}
#    json = @questions.to_json \
#      :only => [:id, :question],
#      :include => {
#        :answers => {:only => [:id, :answer, :correct]},
#        :resources => {:only => [:url, :contains_answer, :media_type, :begin, :end, :article_text]}
#      }
#    render :json => json
    respond_to :json
  end

  def get_questions
    @question_ids = params[:ids].split('+')
    @questions = Question.includes(:answers, :resources).where(:id => @question_ids).sort!{|a, b| a.created_at <=> b.created_at}
    respond_to :json
  end
  
  def get_public
    @book = @books = Book.where(:public => true)
    respond_to :json
  end
end
