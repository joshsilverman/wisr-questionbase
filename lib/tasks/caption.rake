task :index do
    url = "http://www.youtube.com/watch?v=WSYEApgJkh0"
    browser = Watir::Browser.new
    browser.goto url
    browser.button(:id => "watch-transcript").click
    page_html = Nokogiri::HTML.parse(browser.html)
    puts page_html.class
    
    # puts page_html.css('body')
    # page_html.css("cpline").each do |caption|
    #     puts caption
    # end
    # page_html.xpath('//div[@class="cpline"]').each_with_index do |div, i|
    #     puts i + 1
    #     puts div.xpath('./div[@class="cptime"]')
    #     puts "\n\n"
    # end
end