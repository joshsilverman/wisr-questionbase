class ResourcesController < ApplicationController
  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resources }
    end
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
    @resource = Resource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource }
    end
  end

  # GET /resources/new
  # GET /resources/new.json
  def new
    @resource = Resource.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource }
    end
  end

  # GET /resources/1/edit
  def edit
    @resource = Resource.find(params[:id])
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(params[:resource])
    render :json => @resource.id if @resource.save 
    # respond_to do |format|
    #   if @resource.save
    #     format.html { redirect_to @resource, notice: 'Resource was successfully created.' }
    #     format.json { render json: @resource, status: :created, location: @resource }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @resource.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PUT /resources/1
  # PUT /resources/1.json
  def update
    @resource = Resource.find(params[:id])
    @resource.update_attributes(params[:resource])
    render :json => @resource.id
    # respond_to do |format|
    #   if @resource.update_attributes(params[:resource])
    #     format.html { redirect_to @resource, notice: 'Resource was successfully updated.' }
    #     format.json { head :ok }
    #   else
    #     format.html { render action: "edit" }
    #     format.json { render json: @resource.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy
    render :nothing => true
    # respond_to do |format|
    #   format.html { redirect_to resources_url }
    #   format.json { head :ok }
    # end
  end
  
  def parse_article
    net = Net::HTTP.get_response URI.parse(URI.encode("http://ftr.fivefilters.org/makefulltextfeed.php?url=#{params[:url]}"))
    nok = Nokogiri::HTML(net.body)
    text = CGI.unescapeHTML(nok.css('description').to_s.gsub(/<\/?description>/, ""))
    text = text.gsub(/^[^<]*</, "<").gsub('<p><em>This entry passed through the <a href="http://fivefilters.org/content-only/">Full-Text RSS</a> service &mdash; if this is your content and you\'re reading it on someone else\'s site, please read the FAQ at <a href="http://fivefilters.org/content-only/faq.php#publishers">fivefilters.org/content-only/faq.php#publishers</a>. <a href="http://fivefilters.org">Five Filters</a> recommends: <a href="http://shop.wikileaks.org/donate">Donate to Wikileaks</a>.</em></p>', "")
    render :text => text
  end
end
