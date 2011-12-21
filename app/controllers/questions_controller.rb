class QuestionsController < ApplicationController
  # GET /questions
  # GET /questions.xml
  def index
    @questions = Question.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questions }
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    @question = Question.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # GET /questions/new
  # GET /questions/new.xml
  def new
    @question = Question.new
    render :json => {:question_id => @question.id}.to_json
    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.xml  { render :xml => @question }
    # end
  end

  # GET /questions/1/edit
  def edit
    @question = Question.find(params[:id])
  end

  # POST /questions
  # POST /questions.xml
  def create
    @question = Question.new(params[:question])
    render :json => @question.id if @question.save
    # respond_to do |format|
    #   if @question.save     
    #     format.html { redirect_to(@question, :notice => 'Question was successfully created.') }
    #     format.xml  { render :xml => @question, :status => :created, :location => @question }
    #   else    
    #     format.html { render :action => "new" }
    #     format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
    #   end
    # end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    @question = Question.find(params[:id]).update_attributes(params[:question])
    render :nothing => true
    #render :json => @question.id if @question.save
    # respond_to do |format|
    #   if @question.update_attributes(params[:question])
    #     format.html { redirect_to(@question, :notice => 'Question was successfully updated.') }
    #     format.xml  { head :ok }
    #   else
    #     format.html { render :action => "edit" }
    #     format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    respond_to do |format|
      format.html { redirect_to(Chapter.find_by_id(@question.chapter_id)) }
      format.xml  { head :ok }
    end
  end

  def save_question
    if params[:question_id].to_i == -1
      @question = Question.create!(:question => params[:question],
        :correct_answer => params[:correct_answer],
        :incorrect_answer1 => params[:incorrect_answer1],
        :incorrect_answer2 => params[:incorrect_answer2],
        :incorrect_answer3 => params[:incorrect_answer3],
        :topic => params[:topic],
        :chapter_id => params[:chapter_id],
        :user_id => current_user.uid
      )
    else
      @question = Question.find_by_id(params[:question_id])
      @question.question = params[:question]
      @question.correct_answer = params[:correct_answer]
      @question.incorrect_answer1 = params[:incorrect_answer1]
      @question.incorrect_answer2 = params[:incorrect_answer2]
      @question.incorrect_answer3 = params[:incorrect_answer3]
      @question.topic = params[:topic]
      @question.chapter_id = params[:chapter_id]
      @question.user_id = current_user.uid if @question.user_id.nil?
      @question.save
    end
    render :json => @question.id
  end
  
  def compare_question
    @question1 = Question.get_random_question
    @question2 = @question1.get_related_question
  end
  
  def update_question_scores
    winner = Question.find(params[:winner_id])
    loser = Question.find(params[:loser_id])
    if winner and loser
      Question.update_scores(winner, loser, params[:tie])
    end
    redirect_to "/compare_question"
  end

  def bandoy_uploader
    render "upload"
  end

  def bandoy_parser
    doc = Zip::ZipFile.open(params[:dump][:file].tempfile).find_entry("word/document.xml")
    raw_content = Nokogiri::XML.parse(doc.get_input_stream).root.xpath("//w:p")
    current_question = nil
    topic = ""
    chapter_id = params["chapter"]["id"].to_i
    
    raw_content.each do |line|
      next if line.content.empty? || line.content.nil? || line.content =~ /Bandoy/
      cleaned_line = clean_content(line)
      if question_format?(line.content)
        puts "Creating Q: #{current_question.to_json}" unless current_question.nil?
        current_question.save unless current_question.nil?

        current_question = Question.new
        current_question.question = cleaned_line
        current_question.user_id = 1
        current_question.topic = topic
        current_question.chapter_id = chapter_id
      elsif answer_format?(line.content)
        if line.content.include? "@"
          current_question.correct_answer = cleaned_line
        else
          if current_question.incorrect_answer1.nil?
            current_question.incorrect_answer1 = cleaned_line
          elsif current_question.incorrect_answer2.nil?
            current_question.incorrect_answer2 = cleaned_line
          else
            current_question.incorrect_answer3 = cleaned_line
          end
        end
      else
        topic = line.content.strip if current_question.nil? 
      end      
      puts "\n\n"
    end  
    puts "Creating Q: #{current_question.to_json}" unless current_question.nil?
    current_question.save unless current_question.nil?
    render "upload"
  end

  def answer_format?(input)
    if input =~ /[ABCDabcd]\./ || input =~ /[ABCDabcd] \./
      true
    else
      false
    end 
  end

  def question_format?(input)
    if input =~ /[0-9]\./ || input =~ /[0-9] \./  
      true
    else
      false
    end 
  end

  def create_question_component(current)
    puts current.to_json
  end

  def clean_content(line)
    clean = line.content.split(".")[1]
    clean.strip.gsub("  ", " ") unless clean.nil?
  end

end
