class BooksController < ApplicationController

  # GET /books
  # GET /books.xml
  def index
    @my_books = Book.all(:conditions => {:user_id => current_user.id})
    @shared_books = Book.find_all_by_id(Authorship.where(:user_id => current_user.id).collect(&:book_id))
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @books }
    end
  end

  # GET /books/1
  # GET /books/1.xml
  def show
    get_book(params[:id])
    if @book
      @chapters = @book.chapters.sort!{|a, b| a.number <=> b.number}
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @book }
      end
    else
      redirect_to "/"
    end
  end

  # GET /books/new
  # GET /books/new.xml
  def new
    @book = Book.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @book }
    end
  end

  # GET /books/1/edit
  def edit
    get_book(params[:id])
    redirect_to "/" unless @book && @e
  end

  # POST /books
  # POST /books.xml
  def create
    @book = Book.new(params[:book])
    @book.user_id = current_user.id
    respond_to do |format|
      if @book.save
        format.html { redirect_to(@book, :notice => 'Book was successfully created.') }
        format.xml  { render :xml => @book, :status => :created, :location => @book }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @book.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /books/1
  # PUT /books/1.xml
  def update
    get_book(params[:id])
    if @book && @e
      respond_to do |format|
        if @book.update_attributes(params[:book])
          format.html { redirect_to('/books') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @book.errors, :status => :unprocessable_entity }
        end
      end      
    else
      redirect_to "/"
    end   
  end

  # DELETE /books/1
  # DELETE /books/1.xml
  def destroy
    get_book(params[:id])
    if @book && @e
      @book.destroy
      respond_to do |format|
        format.html { redirect_to(books_url) }
        format.xml  { head :ok }
      end
    else
      redirect_to "/"
    end 
  end

  def get_next_chapter_number
    render :json => Book.find(params[:book_id]).chapters.maximum(:number) + 1
  end

  private

  def get_book(id)
    book = Book.find_by_id(id)
    get_permission(book)
    @book = book if @w or @e
  end

  def get_permission(book)
    @e = @w = false
    return if book.nil?
    if book.user_id == current_user.id || current_user.user_type == "ADMIN"
      @e = @w = true
    elsif book.public
      @w = true
    end
  end

end
