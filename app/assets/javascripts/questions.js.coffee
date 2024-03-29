## Delete resource not working
## One existing answer resource

class Chapter
	questions: []
	published: null
	media_url: null
	constructor: -> 
		window.media = new MediaController
		window.ytID = $("#ytID").val()
		# google.setOnLoadCallback(window.media.initializeImageSearch)	
		$(".activity_content").hide()
		$(".feedback_body").hide()
		@published = $.trim($(".status").text()) == "Published"
		window.preview_path = $("#preview_path").attr "value"
		$("#tabs").tabs()
		$(".menu").on "click", () => @newQuestion()
		for activity in $("#activities").find(".activity_group")
			@questions.push(new Question activity)
		@loadKeywords()
	pageLoaded: => @lockChapter() if @published and $("#admin").attr("value") == "false"
	lockChapter: ->
		$(".question_area").attr "disabled", "disabled"
		$(".answer_field").attr "disabled", "disabled"
		$(".token-input-list-facebook input").attr "disabled", "disabled"
		$(".token-input-token-facebook token-input-selected-token-facebook").off "click"
		$(".token-input-delete-token-facebook").off "click"
		$(".menu").off "click"
		$('.add_answer').off "click"
		$(".delete_question_container").off "click"
		$(".question_media_box").off "click"
		$(".answer_media_box").off "click"
		$(".remove_resource").off "click"
		$(".remove_resource").on "click", (e) => e.preventDefault()
		$(".delete_answer").off "click"
		$(".delete_answer").on "click", (e) => e.preventDefault()
	newQuestion: -> window.chapter.questions.push(new Question)
	submitChapter: -> 
		data = 
			"id" : $(chapter_id)[0].value
			"status": 2
		$.ajax
			url: "/chapters/update_status"
			type: "POST"
			data: data	
			success: (e) => window.location = "/books/#{e.book_id}"
	unsubmitChapter: -> 
		data = 
			"id" : $(chapter_id)[0].value
			"status": 1
		$.ajax
			url: "/chapters/update_status"
			type: "POST"
			data: data	
			success: (e) => window.location = "/chapters/#{$(chapter_id)[0].value}"
	unpublishChapter: -> 
		data = 
			"id" : $(chapter_id)[0].value
			"status": 1
		$.ajax
			url: "/chapters/update_status"
			type: "POST"
			data: data	
			success: (e) => window.location = "/chapters/#{$(chapter_id)[0].value}"	
	loadKeywords: () =>
		params = "question_ids": (question.question_id for question in @questions)
		return if params["question_ids"].length == 0
		$.ajax
			url: "/keywords/get_questions_keywords"
			type: "POST"
			data: params
			success: (keywords) => 
				for question in @questions
					keyword_array = []
					(keyword_array.push({"id": keyword.id, "name": keyword.keyword}) for keyword in keywords[question.question_id].keywords)
					question.populateKeywords(keyword_array)
				@pageLoaded()
			error: => @pageLoaded()


class Question
	question_id: null
	answers: []
	dom_group: null # Stores the div w/ the question area + add answer button
	activity_content: null
	question_media: null
	answer_media: []
	keywords: []
	feedback: null
	constructor: (dom_group) ->
		@answers = []
		@keywords = []
		if dom_group # Initializing existing question
			@dom_group = $(dom_group)
			@question_id = @dom_group.find(".header").attr "question_id"
			@dom_group.find(".question_feedback_container img").on "click", (e) =>
				@feedback = new Feedback @ if @feedback == null
				if @dom_group.find(".feedback_body").is(':hidden')
					@dom_group.find(".feedback_body").fadeIn 400 
					$(@activity_content).toggle(400, => $.scrollTo e.srcElement) if $(@activity_content).is(":hidden")
				else 
					@dom_group.find(".feedback_body").fadeOut 400
					# $(@activity_content).toggle 400
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
					# return unless $(e.srcElement).is "img"
					resource_ids = (String(resource.resource_id) for resource in @answer_media)
					window.media.addMedia @, @answer_media[resource_ids.indexOf($(e.srcElement).attr("resource_id"))], e.srcElement, true
		else # Creating new question
			@dom_group = $($('#activity_group')[0]).clone().removeAttr("id").attr("class", "activity_group")
			@dom_group.appendTo $('#activities')[0]
			keyword_field = $(@dom_group).find(".keyword_field").hide()
			@populateKeywords(null)
			question_resource = $(@dom_group).find(".question_media_box").hide()
			question_resource.on "click", (e) => 
				if $(e.srcElement).attr "resource_id"
					window.media.addMedia @, @question_media, e.srcElement, false
				else
					window.media.addMedia @, null, e.srcElement, false
			answer_resources = $(@dom_group).find(".answer_media_box")#.hide()
			for answer_resource in answer_resources
				$(answer_resource).on "click", (e) => 
					if $(e.srcElement).closest(".answer_media_box").attr "resource_id"
						element = $(e.srcElement).closest(".answer_media_box")
						resource_ids = (String(resource.resource_id) for resource in @answer_media)
						window.media.addMedia @, @answer_media[resource_ids.indexOf(element.attr("resource_id"))], element, true
					else
						window.media.addMedia @, null, e.srcElement, true
			@dom_group.find(".activity_content").toggle 400, () => 
				$('html, body').animate({scrollTop: $(document).height() - $(window).height()}, 600)
				@dom_group.find(".question_area").focus()
		@activity_content = $(@dom_group).find(".activity_content")[0]
		$(@dom_group).find(".header_text_container").on "click", (e) =>  
			@dom_group.find(".feedback_body").fadeOut(400) unless $(@activity_content).is(":hidden")
			$(@activity_content).toggle 400, => $.scrollTo e.srcElement unless $(@activity_content).is(":hidden")
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
		@dom_group.find(".question_group").on "change", @save
		$(@dom_group.find(".question_group")).on "keydown", (e) => 
			if e.keyCode == 9 and @answers.length < 1
				e.preventDefault() 
				@answers.push new Answer this
				@save
			$(@dom_group).find(".question_media_box").fadeIn 600
			$(@dom_group).find(".token-input-list-facebook").fadeIn 600				
		@dom_group.find($('.add_answer')).on "click", () => 
			if @answers.length < 4
				@answers.push new Answer this 
				@save
		$(@dom_group).find(".token-input-list-facebook").hide()

	save: (event) =>
		console.log event
		console.log event.target
		console.log "save"
		[submit_url, method] = if @question_id then ["/questions/" + @question_id, "PUT"] else ["/questions", "POST"]
		question_data = 
			"question":
				question: event.target.value
				chapter_id: $(chapter_id)[0].value
		$.ajax
			url: submit_url
			type: method
			data: question_data
			success: (e) => 
				@question_id = e
				header = $(event.srcElement).parents(".activity_content").prevAll("div.header")
				prev_header = $(header).parents(".activity_group").prev().find("p.header_text")
				if prev_header.length != 0
					number = parseInt(prev_header.text().split(".")[0]) + 1
				else 
					number = 1
				header.find("p.header_text").text("#{number}. #{event.target.value}")
	delete: () =>
		@dom_group.remove()
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
			theme: "facebook"
			onAdd: (e) => @addKeyword(e, @)
			onDelete: (e) => @removeKeyword(e, @)
			prePopulate: keywords
			hintText: false#"Add a topic or select from existing"
		})
		if @dom_group.find(".token-input-list-facebook p").length < 1
			@dom_group.find(".token-input-list-facebook input").attr "placeholder", "Add topic"
	addKeyword: (keyword, question) =>
		new_keyword = new Keyword keyword, question, @dom_group.find(".keyword_field")
		@keywords.push new_keyword
		new_keyword.add()
		@dom_group.find(".token-input-list-facebook input").attr "placeholder", ""
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
		else # If new answer
			if @correct 
				@dom_element = $('#correct_answer').clone().removeAttr("id").attr("class", "answer")
			else 
				@dom_element = $('#incorrect_answer').clone().removeAttr("id").attr("class", "answer")
			$(question.dom_group).find(".add_answer").before(@dom_element)
			$(@dom_element).find("input").focus()
		$(@dom_element).on "change", (e) => @save(e)
		$(@dom_element).on "keydown", (e) =>
			next_answer = $(@dom_element).next(".answer")
			if e.keyCode == 9 and @question.answers.length < 4 and (next_answer.length < 1 or next_answer.css("display") == "none")
				e.preventDefault()
				@question.answers.push new Answer @question
				@save
				@question.save
			$(@question.dom_group).find(".answer_media_box").fadeIn 600	
		close = $(@dom_element).find(".delete_answer")
		$(@dom_element).find(".delete_answer").on "click", (e) =>
			e.preventDefault()
			if @answer_id
				window.media.confirm("answer", @delete) 
			else
				$(@dom_element).hide()
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
	delete: () => 
		$.ajax
			url: "/answers/" + @answer_id
			type: "DELETE"
			success: =>
				@question.answers.splice(@question.answers.indexOf(@), 1)
				$(@dom_element).hide()


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
			success: => $($("#media_preview_" + @resource_id)[0]).attr "src", "http://www.mediatehawaii.org/wp-content/uploads/placeholder.jpg"
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


class Feedback
	question: null
	long: null
	hard: null
	easy: null
	correct: null
	missing: null
	accurate: null
	timing: null
	relevant: null
	constructor: (question) -> 
		@question = question
		$.ajax
			url: "/questions/get_feedback/#{@question.question_id}"
			type: "POST"
			success: (e) => @populateFeedback(e)
		$(question.dom_group.find(".submit_feedback")).on "click", (e) => 
			e.preventDefault()
			@update(@question.dom_group.find(".question_feedback_container img").attr "src", "/assets/flag_red.png")
		$(question.dom_group.find(".clear_feedback")).on "click", (e) => 
			e.preventDefault()
			@clear()
	populateFeedback: (feedback) =>
		return if feedback == null
		@question.dom_group.find(".long").attr("checked", "checked") if feedback.long == true
		@question.dom_group.find(".hard").attr("checked", "checked") if feedback.hard == true
		@question.dom_group.find(".easy").attr("checked", "checked") if feedback.easy == true
		@question.dom_group.find(".check_correct").attr("checked", "checked") if feedback.correct == true
		# @question.dom_group.find(".missing").attr("checked", "checked") if feedback.topic_missing == true
		# @question.dom_group.find(".accurate").attr("checked", "checked") if feedback.topic_appropriate == true
		@question.dom_group.find(".timing").attr("checked", "checked") if feedback.media_timing == true
		@question.dom_group.find(".relevant").attr("checked", "checked") if feedback.media_relevant == true
		@question.dom_group.find(".comment").val(feedback.comment)
	update: (callback) =>
		params = {}
		params["question_id"] = @question.question_id
		params["feedback"] = {}
		if @question.dom_group.find(".long").attr("checked") == "checked" then params["feedback"]["long"] = true else params["feedback"]["long"] = false
		if @question.dom_group.find(".hard").attr("checked") == "checked" then params["feedback"]["hard"] = true else params["feedback"]["hard"] = false
		if @question.dom_group.find(".easy").attr("checked") == "checked" then params["feedback"]["easy"] = true else params["feedback"]["easy"] = false
		if @question.dom_group.find(".check_correct").attr("checked") == "checked" then params["feedback"]["correct"] = true else params["feedback"]["correct"] = false
		# if @question.dom_group.find(".missing").attr("checked") == "checked" then params["feedback"]["missing"] = true else params["feedback"]["missing"] = false
		# if @question.dom_group.find(".accurate").attr("checked") == "checked" then params["feedback"]["accurate"] = true else params["feedback"]["accurate"] = false
		if @question.dom_group.find(".timing").attr("checked") == "checked" then params["feedback"]["timing"] = true else params["feedback"]["timing"] = false
		if @question.dom_group.find(".relevant").attr("checked") == "checked" then params["feedback"]["relevant"] = true else params["feedback"]["relevant"] = false
		params["feedback"]["comment"] = @question.dom_group.find(".comment").val()
		$.ajax
			url: "/questions/set_feedback"
			type: "POST"
			data: params
			success: (e) => callback
	clear: =>
		@question.dom_group.find(".long").removeAttr("checked")
		@question.dom_group.find(".hard").removeAttr("checked")
		@question.dom_group.find(".easy").removeAttr("checked")
		@question.dom_group.find(".check_correct").removeAttr("checked")
		# @question.dom_group.find(".missing").removeAttr("checked")
		# @question.dom_group.find(".accurate").removeAttr("checked")
		@question.dom_group.find(".timing").removeAttr("checked")
		@question.dom_group.find(".relevant").removeAttr("checked")
		@question.dom_group.find(".comment").val("")
		params = {"id": @question.question_id}
		$.ajax
			url: "/questions/remove_feedback"
			type: "POST"
			data: params
			success: (e) => @question.dom_group.find(".question_feedback_container img").attr "src", "/assets/flag_gray.png"		


class MediaController
	# article_placeholder_url: "http://www.elitetranslingo.com/css/css/images/doc.png"
	video_placeholder_url: "/assets/video_placeholder.png"
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
		$("#preview_link").on "click", (e) =>
			e.preventDefault()
			if window.chapter.questions.length < 1
				alert "Add some questions first!"
			else
				$("#preview").attr "src", preview_path
				$("#preview_modal").dialog({
					close: () => $(".ui-widget-overlay").off "click"
					title: "Lesson Preview"
					closeOnEscape: true
					draggable: false
					resizable: false
					modal: true
					height: 725
					width: "90%"
				})
				$(".ui-widget-overlay").on "click", -> 
					$(".ui-dialog-titlebar-close").trigger('click')
					$(".ui-widget-overlay").off "click"					
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
			close: () => $(".ui-widget-overlay").off "click"
			modal: true
			title: "Delete this #{context}?"
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
		$(".ui-widget-overlay").on "click", -> 
			$(".ui-dialog-titlebar-close").trigger('click')
			$(".ui-widget-overlay").off "click"		
	showMediaModal: (question, resource, element, contains_answer) =>
		element = $(element).parent() if $(element).is "p"
		media = @
		$("#video_preview_frame").attr "src", "http://www.youtube.com/v/#{window.ytID}"
		if resource != null && resource != undefined
			start_seconds = (resource.begin % 60)
			end_seconds = (resource.end % 60)
			start_seconds = '0' + start_seconds if start_seconds < 10
			end_seconds = '0' + end_seconds if end_seconds < 10
			$("#video_start_input_minute")[0].value = Math.floor(resource.begin / 60)
			$("#video_start_input_second")[0].value = start_seconds				
			$("#video_end_input_minute")[0].value = Math.floor(resource.end / 60)	
			$("#video_end_input_second")[0].value = end_seconds
			# $($("#media-dialog").find("#tabs")).tabs({selected:2})
			$("#video_preview_frame").attr "src", "http://www.youtube.com/v/#{window.ytID}&start=#{resource.begin}" 
		$("#media-dialog").on "keyup", (e) =>
			if e.which == 13 then $(".ui-dialog-buttonpane").find("button").last().trigger "click"#.ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only")#"save and close"
		$("#media-dialog").dialog({
			title: "Add a clip"
			buttons: 
				"Cancel": -> media.clearModalFields()			
				"Save Clip": () -> 
					$(this).dialog("close")	
					if $($(this).find("#video_preview_frame")).attr("src") != undefined
						# question.dom_group.find(".question_area").trigger "change"
						url = String($(this).find("#video_preview_frame").attr("src").match("v/[A-Za-z0-9_-]*")).split("/")[1]
						preview = media.video_placeholder_url
						begin = (parseInt(($("#video_start_input_minute")[0].value * 60)) + parseInt(($("#video_start_input_second")[0].value)))
						end = (parseInt(($("#video_end_input_minute")[0].value * 60)) + parseInt(($("#video_end_input_second")[0].value)))
						media_type = "video"
						article_text = null

						if resource != null && resource != undefined
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
					if $(element).find(".resource_label").length > 0
						$(element).find(".resource_label").remove()
						$(element).append("<img src=#{preview} id=media_preview_ class=media_preview resource_url=#{url} resource_type=video></img>")
					media.clearModalFields()
			closeOnEscape: true
			draggable: false
			resizable: false
			modal: true
			height: 550
			width: 500
		})
		$("#media-dialog").parent().find('a.ui-dialog-titlebar-close').hide()
		# $(".ui-widget-overlay").on "click", -> 
			# $(".ui-dialog-titlebar-close").trigger('click')
			# $(".ui-widget-overlay").off "click"		
	clearModalFields: =>
		$(".ui-dialog-titlebar-close").trigger('click')
		$("#video_start_input_minute")[0].value = ""
		$("#video_start_input_second")[0].value = ""
		$("#video_end_input_minute")[0].value = ""
		$("#video_end_input_second")[0].value = ""
		$("#video_preview_frame").attr "src", null	
	parseYouTubeID: (url) => String(url.match("v=[A-Za-z0-9_-]*")).split("=")[1]	
	imageSearchComplete: () =>
		$("#search_preview")[0].innerHTML = ""
		$("#next_page, #previous_page").css "visibility", "visible"
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
						start_minutes = Math.floor($(source).attr("time") / 60)
						start_seconds = $(source).attr("time") - (start_minutes * 60)
						if start_seconds < 10 then start_seconds = '0' + start_seconds
						$("#video_start_input_minute")[0].value = start_minutes
						$("#video_start_input_second")[0].value = start_seconds
					element.appendTo $("#video_search_results")


$ -> window.chapter = new Chapter