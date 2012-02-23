## Delete resource not working
## One existing answer resource

class Builder
	constructor: -> 
		$("#tabs").tabs()
		for activity in $("#activities").find(".activity_group")
			new Question activity
	newQuestion: -> new Question


class Question
	question_id: null
	answers: []
	dom_group: null # Stores the div w/ the question area + add answer button
	activity_content: null
	question_media: null
	answer_media: []
	keywords: []
	constructor: (dom_group) ->
		@answers = []
		@keywords = []
		if dom_group # Initializing existing question
			@dom_group = $(dom_group)
			@question_id = $(@dom_group[0]).find($("textarea"))[0].getAttribute "question_id"
			for answer_element in @dom_group.find(".answer_group").find(".answer")
				@answers.push new Answer(this, answer_element)
			for question_resource in $(@dom_group).find(".question_media_box")
				if $(question_resource).find("img").attr("resource_id")	
					resource =
						"resource" :
							url: $(question_resource).find("img")[0].getAttribute "src"
							contains_answer: false
							id: $(question_resource).find("img")[0].getAttribute "resource_id"
					@question_media = new Resource resource, this, question_resource
				## Add Media
				$(question_resource).on "click", (e) => window.media.addMedia(@, @question_media, e.srcElement, false) if $(e.srcElement).is "img"
			for answer_resource in $(@dom_group).find(".answer_media_box")	
				if $(answer_resource).find("img").attr("resource_id")
					resource =
						"resource" :
							url: $(answer_resource).find("img")[0].getAttribute "src"
							contains_answer: true
							id: $(answer_resource).find("img")[0].getAttribute "resource_id"
					@answer_media.push new Resource resource, this, answer_resource
				## Add Media
				$(answer_resource).on "click", (e) =>
					return unless $(e.srcElement).is "img"
					resource_ids = (String(resource.resource_id) for resource in @answer_media)
					window.media.addMedia @, @answer_media[resource_ids.indexOf($(e.srcElement).attr("resource_id"))], e.srcElement, true
		else # Creating new question
			@dom_group = $($('#activity_group')[0]).clone().removeAttr("id").attr("class", "activity_group")
			@dom_group.appendTo $('#activities')[0]
			keyword_field = $(@dom_group).find(".keyword_field").hide()

			##QUESTION RES
			question_resource = $(@dom_group).find(".question_media_box").hide()
			question_resource.on "click", (e) => 
				if $(e.srcElement).attr "resource_id"
					window.media.addMedia @, @question_media, e.srcElement, false
				else
					window.media.addMedia @, null, e.srcElement, false
			answer_resources = $(@dom_group).find(".answer_media_box").hide()
			for answer_resource in answer_resources
				$(answer_resource).on "click", (e) => 
					if $(e.srcElement).attr "resource_id"
						resource_ids = (String(resource.resource_id) for resource in @answer_media)
						window.media.addMedia @, @answer_media[resource_ids.indexOf($(e.srcElement).attr("resource_id"))], e.srcElement, true
					else
						window.media.addMedia @, null, e.srcElement, true
			@dom_group.find(".activity_content").toggle 400, () => 
				$('html, body').animate({scrollTop: $(document).height() - $(window).height()}, 600)
				@dom_group.find(".question_area").focus()
		@activity_content = $(@dom_group).find(".activity_content")[0]
		$(@dom_group).find(".header_text_container").on "click", () => $(@activity_content).toggle 400
		$(@dom_group).find(".delete_question_container").on "click", (e) => 
			if @question_id
				data = 
					"id" : @question_id
				$.ajax
					url: "/questions/get_permission"
					type: "POST"
					data: data	
					success: (e) => if e then window.media.confirm("question", @delete) else alert "Cannot delete that question!"
			else @dom_group.hide()				
		$(@dom_group.find(".question_group")).on "keydown", (e) => 
			if e.keyCode == 9 and @answers.length < 1
				e.preventDefault() 
				@answers.push new Answer this
				@save
			$(@dom_group).find(".question_media_box").fadeIn 600
			$(@dom_group).find(".token-input-list-facebook").fadeIn 600				
		@dom_group.find(".question_group").on "change", @save
		@dom_group.find($('.add_answer')).on "click", () => @answers.push new Answer this if @answers.length < 4
		@getKeywords()
		$(@dom_group).find(".token-input-list-facebook").hide()
		# @dom_group.find(".keyword_field").on "keydown", (e) => console.log e
			# if e.keyCode == 9 and @question.answers.length == 4 and $(@dom_element).next(".answer").length < 1
			# 	new Question			
	save: (event) =>
		[submit_url, method] = if @question_id then ["/questions/" + @question_id, "PUT"] else ["/questions", "POST"]
		question_data = 
			"question":
				question: event.srcElement.value
				chapter_id: $(chapter_id)[0].value
		$.ajax
			url: submit_url
			type: method
			data: question_data
			success: (e) => @question_id = e
	delete: () =>
		@dom_group.hide()
		$.ajax
			url: "/questions/" + @question_id
			type: "DELETE"	
	getKeywords: () =>
		if @question_id
			params = "question_id": @question_id
			$.ajax
				url: "/keywords/get_keywords"
				type: "POST"
				data: params
				success: (keywords) => 
					@populateKeywords(keywords)
					for keyword in keywords
						@keywords.push new Keyword keyword, @, @dom_group.find(".keyword_field")
		else
			@populateKeywords(null)
	populateKeywords: (keywords) =>
		@dom_group.find(".keyword_field").tokenInput("/keywords/get_matching_keywords", {
			theme: "facebook",
			onAdd: (e) => @addKeyword(e, @),
			onDelete: (e) => @removeKeyword(e, @)
			prePopulate: keywords,
			hintText: "Add a topic or select from existing"
		})			
	addKeyword: (keyword, question) =>
		new_keyword = new Keyword keyword, question, @dom_group.find(".keyword_field")
		@keywords.push new_keyword
		new_keyword.add()
	removeKeyword: (keyword, question) =>
		params = {}
		params.question_id = @question_id
		params.keyword_id = keyword.id if keyword.id
		params.keyword_text = keyword.name if keyword.name
		$.ajax
			url: "/keywords/remove_keyword"
			type: "POST"
			data: params
		

class Answer
	answer_id: null
	dom_element: null # Stores the answer dom element
	question: null # Stores the parent question object
	correct: null
	changed: false
	constructor: (question, answer_element) -> 
		@question = question
		if question.answers.length < 1 then @correct = 1 else @correct = 0 
		if answer_element # If initializing existing answer
			@dom_element = answer_element
			@answer_id = $(@dom_element).find("input")[0].getAttribute "answer_id"
			if @correct then $(@dom_element).find(".indicator_mark")[0].innerHTML = "O" else $(@dom_element).find(".indicator_mark")[0].innerHTML = "X"
		else # If new answer
			@dom_element = $('#answer').clone().removeAttr("id").attr("class", "answer")
			$(question.dom_group).find(".add_answer").before(@dom_element)
			if @correct then $(@dom_element).find(".indicator_mark")[0].innerHTML = "O" else $(@dom_element).find(".indicator_mark")[0].innerHTML = "X"
			$(@dom_element).find("input").focus()
		$(@dom_element).on "change", @save
		$(@dom_element).on "keydown", (e) =>
			if e.keyCode == 9 and @question.answers.length < 4 and $(@dom_element).next(".answer").length < 1
				e.preventDefault()
				@question.answers.push new Answer @question
				@save
				@question.save
			$(@question.dom_group).find(".answer_media_box").fadeIn 600	
	save: (event) =>
		[submit_url, method] = if @answer_id then ["/answers/" + @answer_id, "PUT"] else ["/answers", "POST"]
		answer_data = 
			"answer":
				answer: event.srcElement.value
				question_id: @question.question_id
				correct: @correct
		$.ajax
			url: submit_url
			type: method
			data: answer_data
			success: (e) => @answer_id = e


class Resource
	url: null
	element: null
	contains_answer: null
	resource_id: null
	question: null # Stores the parent question object
	media_type: null
	start: null
	end: null
	constructor: (resource, question, element) -> 
		@element = element
		@contains_answer = resource["resource"]["contains_answer"]
		@resource_id = resource["resource"]["id"]
		@url = resource["resource"]["url"]
		@media_type = resource["resource"]["media_type"]	
		@begin = resource["resource"]["begin"]	
		@end = resource["resource"]["end"]		
		@question = question
		$(question.dom_group).find("#delete_resource_" + @resource_id).on "click", (event) =>
			event.preventDefault()
			window.media.confirm("resource", @delete)
		if resource["resource"]["article_text"] then @article_text = resource["resource"]["article_text"] else @article_text = null
	save: () =>
		[submit_url, method] = if @resource_id then ["/resources/" + @resource_id, "PUT"] else ["/resources", "POST"]	
		resource_data = "resource" : {}
		resource_data.resource["url"] = @url if @url
		resource_data.resource["contains_answer"] = @contains_answer if @contains_answer != null
		resource_data.resource["question_id"] = @question.question_id if @question.question_id != null
		resource_data.resource["media_type"] = @media_type if @media_type != null
		resource_data.resource["begin"] = @begin if @begin != null
		resource_data.resource["end"] = @end if @end != null
		resource_data.resource["article_text"] = @article_text if @article_text != null
		$.ajax
			url: submit_url
			type: method
			data: resource_data
			success: (e) => 
				@resource_id = e
				$(@element).attr "id", "media_preview_#{@resource_id}"
				$(@element).attr "resource_id", @resource_id
				$(@element).attr "resource_type", @media_type
				$(@element).attr "resource_url", @url
	delete: (e) =>
		$.ajax
			url: "/resources/" + @resource_id
			type: "DELETE"
			success: =>
				$($("#media_preview_" + @resource_id)[0]).attr "src", "http://www.mediatehawaii.org/wp-content/uploads/placeholder.jpg"
	show: (id) =>
		$.ajax
			url: "/resources/" + id + ".json"
			type: "GET"


class Keyword
	text: null
	id: null
	question: null
	element: null
	constructor: (keyword, question, element) ->
		@question = question
		@text = keyword.name
		@id = keyword.id
		@element = element	
	add: () =>
		params = {}
		params.text = @text
		params.question_id = @question.question_id
		params.id = @id if @id
		$.ajax
			url: "/keywords/add_keyword"
			type: "POST"
			data: params
			success: (e) => 
				@id = e
	delete: () => 
		console.log "delete"


class MediaController
	article_placeholder_url: "http://www.elitetranslingo.com/css/css/images/doc.png"
	video_placeholder_url: "http://cache.gizmodo.com/assets/images/4/2010/09/youtube-video-player-loading.png"
	imageSearch = null
	constructor: -> 
		$("#article_link_input").autocomplete
			source: (request, response) => 
				$("html").append "<script src='http://en.wikipedia.org/w/api.php?action=opensearch&search=#{request.term}&namespace=0&suggest=&callback=wikiAutocompleteCallback'></script>"
				window.wikiAutocompleteCallback = (r) -> response(r[1])
			select: (e) => 
				if e.which == 13 then term = e.srcElement.value else term = e.srcElement.innerText
				@updatePreview("http://en.wikipedia.org/wiki/" + term.replace(/\ /g, '_'))
		$("#article_preview_button").on "click", (e) =>
			e.preventDefault()
			@updatePreview("http://en.wikipedia.org/wiki/" + $("#article_link_input")[0].value.replace(/\ /g, '_'))
		$("#article_preview_field").on "mouseup", (e) ->
			$("#article_preview_field").wrapSelection().addClass("highlighted")
		$("#article_preview_field").on "click", ["span"], (e) -> 
			if $(e.srcElement).hasClass "highlighted" then $(e.srcElement).contents().unwrap()
		$("#article_preview_field").on "click", "a", (e) =>
			e.preventDefault()
			$("#article_link_input")[0].value = $(e.srcElement).attr "title"
			@updatePreview($(e.srcElement).attr "href")
		$("#video_link_input").on "keyup", (e) =>
			if $("#video_link_input")[0].value.match(/(^|\s)((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)/gi)
				video_id = @parseYouTubeID $("#video_link_input")[0].value
				$("#video_preview_frame").attr "src", "http://www.youtube.com/v/#{video_id}"
				$("#video_start_input_minute")[0].value = ""
				$("#video_start_input_second")[0].value = ""
				$("#video_end_input_minute")[0].value = ""
				$("#video_end_input_second")[0].value = ""
		$("#image_link_input").on "keyup", (e) =>
			if e.which == 13 then @imageSearch.execute($("#image_link_input")[0].value)
			else if $("#image_link_input")[0].value.match(/(^|\s)((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)/gi)
				$("#image_search_preview").attr "src", $("#image_link_input")[0].value
		$("#image_search_button").on "click", (e) =>
			e.preventDefault()
			@imageSearch.execute($("#image_link_input")[0].value)
		$("#next_page").on "click", () => @imageSearch.gotoPage(@imageSearch.cursor.currentPageIndex+1)
		$("#previous_page").on "click", () => @imageSearch.gotoPage(@imageSearch.cursor.currentPageIndex-1)	
		$("#search_preview").on "click", "img", (e) => $("#image_search_preview").attr "src", e.srcElement.src
		$("#video_search_button").on "click", (e) => 
			e.preventDefault()
			@videoSearch($("#video_link_input")[0].value)
	updatePreview: (url) =>
		params = "url" : url
		$.ajax
			url: "/parse_article/"
			type: "POST"
			data: params
			success: (text) => 
				$("#article_preview_field").html text
				$("#article_preview_field")[0].scrollTop = 0
	addMedia: (question, resource, element, contains_answer) =>
		if resource
			$.ajax
				url: "/resources/" + resource.resource_id + ".json"
				type: "GET"
				success: (data) => 
					resource.media_type = data.media_type
					resource.begin = data.begin
					resource.end = data.end
					resource.article_text = data.article_text
					resource.url = data.url
					@showMediaModal question, resource, element, contains_answer
		else @showMediaModal question, resource, element, contains_answer
	confirm: (context, callback) =>
		$("#dialog-confirm").dialog({
			resizable: false
			modal: true
			title: "Delete this question?"
			context: context
			buttons: { 
				"Cancel": -> $(this).dialog("close")
				"Delete": -> 
					callback()
					$(this).dialog("close")
			}
			closeOnEscape: true
			draggable: false
			resizable: false
			height: 180
		})
		$(".ui-widget-overlay").click -> $(".ui-dialog-titlebar-close").trigger('click')
	showMediaModal: (question, resource, element, contains_answer) =>
		media = @
		if resource
			switch resource.media_type
				when "text"
					$("#article_link_input")[0].value = resource.url
					$("#article_preview_field").html resource.article_text					
					$($("#media-dialog").find("#tabs")).tabs({selected:1})
				when "image"
					$("#image_link_input")[0].value = resource.url
					$($("#media-dialog").find("#tabs")).tabs({selected:0})
					$("#image_search_preview")[0].src = resource.url
				when "video" 
					$("#video_link_input")[0].value = "http://www.youtube.com/watch?v=#{resource.url}&t=0m#{resource.begin}s"
					start_seconds = (resource.begin % 60)
					end_seconds = (resource.end % 60)
					start_seconds = '0' + start_seconds if start_seconds < 10
					end_seconds = '0' + end_seconds if end_seconds < 10
					$("#video_start_input_minute")[0].value = Math.floor(resource.begin / 60)
					$("#video_start_input_second")[0].value = start_seconds				
					$("#video_end_input_minute")[0].value = Math.floor(resource.end / 60)	
					$("#video_end_input_second")[0].value = end_seconds
					$($("#media-dialog").find("#tabs")).tabs({selected:2})
					$("#video_preview_frame").attr "src", "http://www.youtube.com/v/#{resource.url}&start=#{resource.begin}" 
		$("#media-dialog").dialog({
			title: "Add Media"
			buttons: 
				"Cancel": -> media.clearModalFields()			
				"Done": () -> 
					# Close modal.
					$(this).dialog("close")	
									
					switch $(this).find("#tabs").tabs("option", "selected")
						when 0 
							if $(this).find("#image_link_input")[0].value.match(/(^|\s)((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)/gi) then url = $(this).find("#image_link_input")[0].value else url = $("#image_search_preview")[0].src
							break if url == ""
							preview = url
							begin = null
							end = null
							media_type = "image"
							article_text = null
						when 1
							break if $(this).find("#article_link_input")[0].value == ""
							url = "http://en.wikipedia.org/wiki/" + $(this).find("#article_link_input")[0].value.replace(/\ /g, '_')
							preview = media.article_placeholder_url
							begin = null
							end = null
							media_type = "text"
							article_text = $(this).find("#article_preview_field")[0].innerHTML
						when 2
							break if !$($(this).find("#video_preview_frame")).attr "src"
							url = String($(this).find("#video_preview_frame").attr("src").match("v/[A-Za-z0-9_-]*")).split("/")[1]
							preview = media.video_placeholder_url
							begin = (parseInt(($("#video_start_input_minute")[0].value * 60)) + parseInt(($("#video_start_input_second")[0].value)))
							end = (parseInt(($("#video_end_input_minute")[0].value * 60)) + parseInt(($("#video_end_input_second")[0].value)))
							media_type = "video"
							article_text = null
					media.clearModalFields()
										
					# Set preview image.
					$(element).attr "src", preview

					# Create/update resource.
					if resource
						resource.url = url
						resource.begin = begin
						resource.end = end
						resource.media_type = media_type
						resource.article_text = article_text
						resource.save()
					else
						resource = 
	                        "resource":
	                            url: url
	                            contains_answer: contains_answer
	                            media_type: media_type
	                            begin: begin
	                            end: end
	                            article_text: article_text
	                    new_resource = new Resource resource, question, element
	                    new_resource.save()
	                    if contains_answer then question.answer_media.push(new_resource) else question.question_media = new_resource       
			closeOnEscape: true
			draggable: true
			resizable: false
			modal: true
			height: 600
			width: "80%"
		})
		$(".ui-widget-overlay").click -> media.clearModalFields()
	clearModalFields: =>
		$(".ui-dialog-titlebar-close").trigger('click')
		$("#image_link_input")[0].value = ""
		$("#article_link_input")[0].value = ""
		$("#video_link_input")[0].value = ""
		$("#video_start_input_minute")[0].value = ""
		$("#video_start_input_second")[0].value = ""
		$("#video_end_input_minute")[0].value = ""
		$("#video_end_input_second")[0].value = ""
		$("#article_preview_field").html null
		$("#video_preview_frame").attr "src", null
		$("#image_search_preview").attr "src", null	
		$("#search_preview")[0].innerHTML = ""	
		$("#video_search_results")[0].innerHTML = ""
	parseYouTubeID: (url) => String(url.match("[?]v=[A-Za-z0-9_-]*")).split("=")[1]	
	imageSearchComplete: () =>
		$("#search_preview")[0].innerHTML = ""
		for result in @imageSearch.results
			image_container = $("#image_container_template").clone().attr("id", "image_container")
			$(image_container).find("img")[0].src = result.url
			image_container.appendTo $("#search_preview")
	initializeImageSearch: () => 
		@imageSearch = new google.search.ImageSearch()
		@imageSearch.setSearchCompleteCallback(@, @imageSearchComplete, null)
		@imageSearch.setResultSetSize(8)
		@imageSearch.setSiteRestriction("wikipedia.org")
	videoSearch: (term) =>
		params = "term" : term
		$.ajax
			url: "/search_videos"
			type: "POST"
			data: params
			success: (results) => 
				$("#video_search_results")[0].innerHTML = ""
				for result, i in results
					element = $("#video_search_result_template").clone()
					label = $(element).find(".video_search_result_label")
					$(label).text("#{i+1}. ...#{result.text}...")
					$(element).attr "time", result.time
					$(element).attr "video_id", result.video_id
					$(element).on "click", (event) => 
						source = event.srcElement
						source = $(source).parent() if $(source).is "label"
						$("#video_preview_frame").attr "src", "http://www.youtube.com/v/#{$(source).attr 'video_id'}&start=#{$(source).attr 'time'}"
						# media.createVideoSlider($(e.srcElement).attr("video_id"), $(e.srcElement).attr("time"))
						start_minutes = Math.floor($(source).attr("time") / 60)
						start_seconds = $(source).attr("time") - (start_minutes * 60)
						if start_seconds < 10 then start_seconds = '0' + start_seconds
						$("#video_start_input_minute")[0].value = start_minutes
						$("#video_start_input_second")[0].value = start_seconds
					element.appendTo $("#video_search_results")



class Controller
	constructor: -> @hideActivities()
	scrollToTop: -> $.scrollTo 0, 500
	scrollToBottom: -> $.scrollTo document.body.scrollHeight, 500
	hideActivities: -> $(".activity_content").hide()	


$ -> 
	window.controller = new Controller
	window.media = new MediaController
	google.setOnLoadCallback(window.media.initializeImageSearch)
	window.builder = new Builder