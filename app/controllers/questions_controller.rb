class QuestionsController < ApplicationController
  # include ActionView::Helpers::SanitizeHelper

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
    @question.user_id = current_user.uid
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
    @question = Question.find(params[:id])
    @question.update_attributes(params[:question])
    render :json => @question.id if @question.save
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

  def get_permission
    render :json => Question.find(params[:id]).user_id.to_i == current_user.uid.to_i
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

  def examview_uploader
    render "upload"
  end

  def examview_parser   
    
    # MANUALLY ADD CAPTIONS FOR 39
    # REMOVE PARA TAGS IN QUESTION CONTENT
    # BLOOD SUGAR LEVELS SA QUESTION, SA054 => SA004
    # NON NARRATIVE SUPPLEMENTAL TABLES
    
    image_resource_path = "https://s3.amazonaws.com/studyegg_images/Biology - CA - "
   
    xml = Nokogiri::XML.parse(File.open(params[:dump][:file1].tempfile)).remove_namespaces!  

    chapter = Chapter.new
    chapter.book_id = params["book"]["id"].to_i
    chapter.name = xml.css("title").text
    chapter.number = 2
    chapter.save
    puts chapter.to_json

    sections = xml.css("question")
    sections.each do |section|
      question = Question.new
      question.rationale = section.css("rationale").text
      question.difficulty = section.css("difficulty").text
      question.reference = section.css("reference").text
      question.topic = section.css("topic").text
      question.keywords = section.css("keywords").text
      question.objective = section.css("text-objective").text
      question.state = section.css("state-objective").attribute("state").text
      question.state_objective = section.css("state-objective").text  
      question.question_type = section.attribute("type").text
      question.chapter_id = chapter.id
      question.user_id = current_user.uid
      question.save

      if question.question_type == "mc" or question.question_type == "bi"
        correct = section.css("answer").text
        if section.css("choice-a").text
          answer = Answer.new
          answer.answer = strip_tags(section.css("choice-a").text)
          answer.correct = (correct == "A")
          answer.feedback = strip_tags(section.css("feedback-a").text)
          answer.question_id = question.id
          answer.save
          puts answer.to_json
        end

        if section.css("choice-b").text
          answer = Answer.new
          answer.answer = strip_tags(section.css("choice-b").text)
          answer.correct = (correct == "B")
          answer.feedback = strip_tags(section.css("feedback-b").text)
          answer.question_id = question.id
          answer.save
          puts answer.to_json
        end
        
        if section.css("choice-c").text    
          answer = Answer.new
          answer.answer = strip_tags(section.css("choice-c").text)
          answer.correct = (correct == "C")
          answer.feedback = strip_tags(section.css("feedback-c").text)
          answer.question_id = question.id
          answer.save
          puts answer.to_json
        end

        if section.css("choice-d").text   
          answer = Answer.new
          answer.answer = strip_tags(section.css("choice-d").text)
          answer.correct = (correct == "D")
          answer.feedback = strip_tags(section.css("feedback-d").text)
          answer.question_id = question.id  
          answer.save 
          puts answer.to_json
        end
      elsif question.question_type == "sa" or question.question_type == "nr" or question.question_type == "es"
        answer = Answer.new
        answer.answer = strip_tags(section.css("answer").text.gsub("Note: The following is only a sample answer. All reasonable answers should be accepted.\n\n", ""))
        answer.correct = true
        answer.question_id = question.id
        answer.save
        puts answer.to_json
      else
        puts "Unsupported question type found!"
      end

      if !section.attribute("narrative").blank?
        narrative = xml.css("narrative[name='#{section.attribute('narrative').text}']")      
        if !narrative.search("picture").empty?
          narrative.search(".//picture").each_with_index do |image, i|
            resource = Resource.new
            resource.article_text = strip_tags(narrative.css("text").inner_html().split("<pict")[0])
            resource.media_type = "image"
            resource.required = true
            resource.url = "#{image_resource_path}nar#{narrative.attribute("narrative-id").text.rjust(3, '0')}-#{i+1}.jpg"
            resource.contains_answer = false
            resource.question_id = question.id
            resource.save
            puts resource.to_json
          end
        elsif !narrative.search("table").empty?
          narrative.search(".//table").each_with_index do |table, i|
            resource = Resource.new
            resource.media_type = "table"
            resource.required = true
            resource.contains_answer = false
            resource.question_id = question.id
            resource.table = table.to_s()
            resource.article_text = strip_tags(narrative.css("text").inner_html().split("<tabl")[0])
            resource.save
            puts resource.to_json
          end
        else
          resource = Resource.new
          resource.article_text = strip_tags(narrative.css("text").inner_html())
          resource.media_type = "text"
          resource.required = true
          resource.contains_answer = false
          resource.question_id = question.id
          resource.save
          puts resource.to_json          
        end
      else
        content = section.css("text")
        type = section.attribute("type").text
        type = "mc" if type == "bi"
        if !content.search("picture").empty?
          content.search(".//picture").each_with_index do |image, i|
            resource = Resource.new
            resource.media_type = "image"
            resource.required = true
            resource.url = "#{image_resource_path}#{type}#{section.attribute("question-id").text.rjust(3, '0')}-#{i+1}.jpg"
            resource.contains_answer = false
            resource.question_id = question.id
            resource.save
            puts resource.to_json
            image.remove
          end
        end
        if !content.search("equation").empty?
          content.search(".//equation").each_with_index do |image, i|
            resource = Resource.new
            resource.media_type = "image"
            resource.required = true
            resource.url = "#{image_resource_path}#{type}#{section.attribute("question-id").text.rjust(3, '0')}-#{i+1}.jpg"
            resource.contains_answer = false
            resource.question_id = question.id
            resource.save
            puts resource.to_json
          end
          content.search(".//equation").remove
        end
        content = content.text   
      end

      text = section.css("text")
      text.search(".//picture").remove
      text.search(".//equation").remove
      question.question = strip_tags(text.first.inner_html())
      question.save
      puts question.to_json
      puts "\n\n\n"
    end


    # xml.root.xpath("//question").each do |question|
    #   puts question.xpath("./text").text
    # end

    # sections = xml.root.xpath("//section")
    # sections.each do |section|
    #   number = section.attribute("ident").to_s.gsub("QDB_", "").to_i
    #   if number >= 0
    #     chapter = Chapter.create(
    #       :book_id => params["book"]["id"].to_i,
    #       :name => section.attribute("title").to_s,#.split(/[\d]?[:]?[ [A-Z] ]?/)[1].strip,
    #       :number => number
    #     )
    #     puts section.attribute("title").to_json
    #     activities = section.xpath(".//item")
    #     activities.each do |activity|
    #       #Check if its a logical identifier (MC)
    #       if activity.xpath(".//qmd_itemtype").text == "Logical Identifier"
    #         answer_index = nil
    #         high_score = 0
    #         question = Question.create(
    #           :question => activity.xpath(".//mattext").first.text,
    #           :chapter_id => chapter.id,
    #           :user_id => current_user.uid
    #         )
    #         # puts activity.xpath(".//mattext").first.text
    #         #Determine correct answer by comparing scores
    #         activity.xpath(".//setvar").each_with_index do |answer, i|
    #           if answer_index == nil
    #             answer_index = i
    #             high_score = answer.text
    #           elsif high_score < answer.text 
    #             answer_index = i
    #           end
    #         end
    #         activity.xpath(".//response_lid//mattext").each_with_index do |answer, i|
    #           Answer.create(
    #             :answer => answer.text,
    #             :correct => (i == answer_index),
    #             :question_id => question.id
    #           )
    #           # puts " - #{answer.text} ( correct: #{i == answer_index} )"
    #         end
    #         # puts "\n\n"
    #       # elsif
    #       #   puts "Skipping non-MC question for now."
    #       end
    #     end        
    #   end
    # end
    render "upload"
  end

  def strip_tags(input)
    input.gsub(/<(?!sub|\/sub|sup|\/sup).*?>/, "").strip
  end

  # def bandoy_uploader
  #   render "upload"
  # end

  # def bandoy_parser
  #   doc = Zip::ZipFile.open(params[:dump][:file].tempfile).find_entry("word/document.xml")
  #   raw_content = Nokogiri::XML.parse(doc.get_input_stream).root.xpath("//w:p")
  #   current_question = nil
  #   topic = ""
  #   chapter_id = params["chapter"]["id"].to_i
    
  #   raw_content.each do |line|
  #     next if line.content.empty? || line.content.nil? || line.content =~ /Bandoy/
  #     cleaned_line = clean_content(line)
  #     if question_format?(line.content)
  #       puts "Creating Q: #{current_question.to_json}" unless current_question.nil?
  #       current_question.save unless current_question.nil?

  #       current_question = Question.new
  #       current_question.question = cleaned_line
  #       current_question.user_id = 1
  #       current_question.topic = topic
  #       current_question.chapter_id = chapter_id
  #     elsif answer_format?(line.content)
  #       if line.content.include? "@"
  #         current_question.correct_answer = cleaned_line
  #       else
  #         if current_question.incorrect_answer1.nil?
  #           current_question.incorrect_answer1 = cleaned_line
  #         elsif current_question.incorrect_answer2.nil?
  #           current_question.incorrect_answer2 = cleaned_line
  #         else
  #           current_question.incorrect_answer3 = cleaned_line
  #         end
  #       end
  #     else
  #       topic = line.content.strip if current_question.nil? 
  #     end      
  #     puts "\n\n"
  #   end  
  #   puts "Creating Q: #{current_question.to_json}" unless current_question.nil?
  #   current_question.save unless current_question.nil?
  #   render "upload"
  # end

  # def answer_format?(input)
  #   if input =~ /[ABCDabcd]\./ || input =~ /[ABCDabcd] \./
  #     true
  #   else
  #     false
  #   end 
  # end

  # def question_format?(input)
  #   if input =~ /[0-9]\./ || input =~ /[0-9] \./  
  #     true
  #   else
  #     false
  #   end 
  # end

  # def create_question_component(current)
  #   puts current.to_json
  # end

  # def clean_content(line)
  #   clean = line.content.split(".")[1]
  #   clean.strip.gsub("  ", " ") unless clean.nil?
  # end

end
