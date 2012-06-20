class Chapter < ActiveRecord::Base
    belongs_to :book
    has_many :questions	
    belongs_to :feedback
    validates_presence_of :number
    validates_presence_of :media_url

    def question_count
      questions.where(:feedback_id => nil).count
    end

    def get_media_duration(media_url)
	    id = media_url.match("v=[a-zA-Z0-9\-_]*").to_s.gsub("v=", "")
	    url = URI.parse("http://gdata.youtube.com/feeds/api/videos/#{id}")
	    req = Net::HTTP::Get.new(url.path)
	    res = Net::HTTP.start(url.host, url.port) {|http|
	      http.request(req)
	    }
	    begin
	      duration = Hash.from_xml(res.body)["entry"]["group"]["duration"]["seconds"]
	    rescue
	      puts "No duration found for #{id}"
	      duration = 0
	    end
	    self.media_duration = duration if duration
	    self.save 
    end
end
