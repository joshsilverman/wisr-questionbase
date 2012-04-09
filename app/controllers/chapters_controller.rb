class ChaptersController < ApplicationController
  # GET /chapters
  # GET /chapters.xml
  def index
    @chapters = Chapter.all

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @chapters }
    end
  end

  # GET /chapters/1
  # GET /chapters/1.xml
  def show
    get_chapter(params[:id])
    if @chapter
      @book = Book.find_by_id(@chapter.book_id)
      @questions = @chapter.questions.sort!{|a, b| a.created_at <=> b.created_at}
      @preview_path = "#{STUDYEGG_PATH}/review/#{(@chapter.id)}/embed"
      puts @preview_path
      respond_to do |format|
        format.html # show.html.erb
        format.json  { render :text => "#{params[:callback]}(#{@questions.to_json})", :content_type => 'text/javascript' }
      end
    else
      redirect_to "/"
    end
  end

  # GET /chapters/new
  # GET /chapters/new.xml
  def new
    @current_book = Book.find_by_id(params[:book_id])
    @chapter = Chapter.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :json => @chapter }
    end
  end

  # GET /chapters/1/edit
  def edit
    get_chapter(params[:id])
    if @chapter# && @e
      @current_book = Book.find_by_id(@chapter.book_id)
    else
      redirect_to "/" 
    end
  end

  # POST /chapters
  # POST /chapters.xml
  def create
    @chapter = Chapter.new(params[:chapter])
    @chapter.book_id = params[:book_id]
    @current_book = Book.find_by_id(params[:book_id])
    respond_to do |format|
      if @chapter.save
        format.html { redirect_to(@chapter, :notice => 'Chapter was successfully created.') }
        format.xml  { render :json => @chapter, :status => :created, :location => @chapter }
      else
        format.html { render :action => "new" }
        format.xml  { render :json => @chapter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /chapters/1
  # PUT /chapters/1.xml
  def update
    get_chapter(params[:id])
    if @chapter# && @e
      @current_book = Book.find_by_id(@chapter.book_id)
      respond_to do |format|
        if @chapter.update_attributes(params[:chapter])
          format.html { redirect_to "/books/#{@current_book.id}" }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :json => @chapter.errors, :status => :unprocessable_entity }
        end
      end 
    else
      redirect_to "/"
    end       
  end

  # DELETE /chapters/1
  # DELETE /chapters/1.xml
  def destroy
    get_chapter(params[:id])
    if @chapter && @e
      @chapter.destroy
      respond_to do |format|
        format.html { redirect_to(Book.find_by_id(@chapter.book_id)) }
        format.xml  { head :ok }
      end
    else
      redirect_to "/"
    end 
  end

  def publish
    redirect_to "/" if current_user.user_type != "ADMIN" && current_user.user_type != "QC"
    @chapters = Chapter.where(:status => 2)
  end

  def add
    redirect_to "/" if current_user.user_type != "ADMIN"
    @books = Book.all
  end

  def update_status
    chapter = Chapter.find(params[:id])
    chapter.status = params[:status] 
    chapter.author_id = current_user.id if params[:status] == "1"
    chapter.save
    render :json => chapter
  end

  def export_to_csv
    require 'csv'

    @chapter = Chapter.find_by_id(params[:id])
    return if @chapter.nil?
    @questions = Question.where("chapter_id = ?", @chapter.id)

    csv_string_test = CSV.generate do |csv|
      csv << ["id", "question", "correct answer", "incorrect answer1", "incorrect answer2", "incorrect answer3", "topic"]

     @questions.each do |q|
        next if q.question.nil? || q.question.length < 1

        row = [ q.id, 
                clean_markup_from_desc(q.question), 
                clean_markup_from_desc(q.correct_answer), 
                clean_markup_from_desc(q.incorrect_answer1),
                clean_markup_from_desc(q.incorrect_answer2),
                clean_markup_from_desc(q.incorrect_answer3),
                clean_markup_from_desc(q.topic)]
        csv << row
      end
    end

    # send it to the browsah
    filename = "Chapter-#{@chapter.number}"
    send_data csv_string_test,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{filename}.csv"
  end


  private

  def get_chapter(id)
    chapter = Chapter.find_by_id(id)
    get_permission(chapter)
    @chapter = chapter if @w or @e
  end

  def get_permission(chapter)
    @e = @w = false
    return if chapter.nil?
    if Book.find(chapter.book_id).user_id == current_user.id || current_user.user_type == "ADMIN"
      @e = @w = true
    elsif Book.find(chapter.book_id).public
      @w = true
    end
  end

  def clean_markup_from_desc(str)
    return str if str.nil?
    str.gsub!("\s{2,}", " ")
    str.gsub!(" .", ".")
    str.gsub!("\n","")
    return str
  end  
end
