task :index do    
    
    # Course definitions.
    # yale_psychology = {
    #     :name => "Introduction to Psychology (Yale)",
    #     :count => 20,
    #     :video_ids => ["P3FKHH2RzjI", "vg01Q1BI4WM", "7emS3ye3cVU", "rCKK6r15fro", "eznq75eBy2o", 
    #                    "Uf9tlbMckS0", "DmWrOUK2zgA", "Yuwqr5o58Z0", "kZoBgX8rScg", "AMsQfgV07vU", 
    #                    "8UySWKNjw5Y", "i5IrSEIPdwk", "piDznzrNymE", "RCNgknc7Qv8", "xpmESnTeZP8", 
    #                    "jsrB5m3mL-A", "S6OfFaBWtx4", "rW79ZwDPKsY", "4wtl3q87Rn8", "7dep9KPWp3g"]
    # }
    # courses = []
    # courses << yale_psychology
    

    # # Collect transcripts.
    # browser = Watir::Browser.new
    # courses.each do |course|
    #     path = "#{Rails.root}/db/data/video_transcripts/#{course[:name]}"
    #     Dir.mkdir path unless File.exists? path
    #     course[:video_ids].each_with_index do |video_id, j|
    #         file = File.open("#{path}/srt_#{j+1}.txt", "w")
    #         browser.goto "http://www.youtube.com/watch?v=#{video_id}"
    #         browser.button(:id => "watch-transcript").click
    #         sleep 1
    #         page_html = Nokogiri::HTML.parse(browser.html)
    #         page_html.xpath('//div[@class="cpline"]').each_with_index do |element, i|
    #             div = element
    #             puts "#{i+1}"
    #             puts "\n"
    #             puts div.xpath('./div[@class="cptime"]')[0].text.strip
    #             puts "\n"
    #             puts div.xpath('./div[@class="cptext"]')[0].text.strip
    #             puts "\n\n"
    #             file.write("#{i+1}")
    #             file.write("\n")
    #             file.write(div.xpath('./div[@class="cptime"]')[0].text.strip)
    #             file.write("\n")
    #             file.write(div.xpath('./div[@class="cptext"]')[0].text.strip)
    #             file.write("\n\n")
    #         end    
    #         file.close    
    #     end
    # end
    # browser.close()

    @courses = Dir.glob("#{Rails.root}/db/data/video_transcripts/\*")
    puts @courses
    @courses.each do |course|
        puts Dir.glob("#{course}/\*")        
    end
    

end