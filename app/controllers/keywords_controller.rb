class KeywordsController < ApplicationController
  # GET /keywords
  # GET /keywords.json
  def index
    @keywords = keyword.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @keywords }
    end
  end

  # GET /keywords/1
  # GET /keywords/1.json
  def show
    @keyword = keyword.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @keyword }
    end
  end

  # GET /keywords/new
  # GET /keywords/new.json
  def new
    @keyword = keyword.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @keyword }
    end
  end

  # GET /keywords/1/edit
  def edit
    @keyword = keyword.find(params[:id])
  end

  # POST /keywords
  # POST /keywords.json
  def create
    @keyword = keyword.new(params[:keyword])
    render :json => @keyword.id if @keyword.save 
    # respond_to do |format|
    #   if @keyword.save
    #     format.html { redirect_to @keyword, notice: 'keyword was successfully created.' }
    #     format.json { render json: @keyword, status: :created, location: @keyword }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @keyword.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PUT /keywords/1
  # PUT /keywords/1.json
  def update
    puts params.to_json
    @keyword = keyword.find(params[:id])
    @keyword.update_attributes(params[:keyword])
    render :json => @keyword.id
    # respond_to do |format|
    #   if @keyword.update_attributes(params[:keyword])
    #     format.html { redirect_to @keyword, notice: 'keyword was successfully updated.' }
    #     format.json { head :ok }
    #   else
    #     format.html { render action: "edit" }
    #     format.json { render json: @keyword.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /keywords/1
  # DELETE /keywords/1.json
  def destroy
    @keyword = keyword.find(params[:id])
    @keyword.destroy
    render :nothing => true
    # respond_to do |format|
    #   format.html { redirect_to keywords_url }
    #   format.json { head :ok }
    # end
  end 
  
  def get_matching_keywords
    keywords = Keyword.find(:all, :conditions => ['keyword LIKE ?', "%#{params[:q]}%"], :select => ["keyword", "id"]).collect {|keyword| {:id => keyword["id"], :name => keyword["keyword"]}}
    keywords.insert(0, {:name => params[:q], :id => nil}) unless Keyword.find_by_keyword(params[:q])
    render :json => keywords
  end

  def add_keyword
    if params[:id] 
      keyword = Keyword.find(params[:id])
      keyword.questions << Question.find(params[:question_id])
    else
      keyword = Keyword.new
      keyword.keyword = params[:text]
      keyword.save
      keyword.questions << Question.find(params[:question_id])
    end
    render :json => keyword.id
  end

  def get_keywords
    keywords = Question.find(params[:question_id]).keywords.all(:select => ["keyword", "id"]).collect {|keyword| {:id => keyword["id"], :name => keyword["keyword"]}}
    render :json => keywords
  end

  def remove_keyword
    keywords = Question.find(params[:question_id]).keywords
    if params[:keyword_id]
      keywords.delete(Keyword.find(params[:keyword_id]))
    else
      keywords.delete(Keyword.find_by_keyword(params[:keyword_text]))
    end
    render :nothing => true
  end
   
end
