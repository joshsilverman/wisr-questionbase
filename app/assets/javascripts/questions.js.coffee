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
	answer_media: null
	article_placeholder_url: "http://www.elitetranslingo.com/css/css/images/doc.png"
	video_placeholder_url: "http://cache.gizmodo.com/assets/images/4/2010/09/youtube-video-player-loading.png"
	constructor: (dom_group) ->
		@answers = []
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
					@question_media = new Resource resource, this
				$(question_resource).on "click", (e) => 
					if $(e.srcElement).is("img") then @addMedia false, @question_media
			for answer_resource in $(@dom_group).find(".answer_media_box")
				if $(answer_resource).find("img").attr("resource_id")
					resource =
						"resource" :
							url: $(answer_resource).find("img")[0].getAttribute "src"
							contains_answer: true
							id: $(answer_resource).find("img")[0].getAttribute "resource_id"
					@answer_media = new Resource resource, this	
				$(answer_resource).on "click", (e) => 
					if $(e.srcElement).is("img") then @addMedia true, @answer_media
		else # Creating new question
			@dom_group = $($('#activity_group')[0]).clone().removeAttr("id").attr("class", "activity_group")
			@dom_group.appendTo $('#activities')[0]
			question_resource = $(@dom_group).find(".question_media_box")
			answer_resource = $(@dom_group).find(".answer_media_box").hide()
			question_resource.hide()
			question_resource.on "click", () => @addMedia false, @answer_media
			answer_resource.hide()
			answer_resource.on "click", () => @addMedia true, @answer_media
			@dom_group.find(".activity_content").toggle 400, () => 
				$('html, body').animate({scrollTop: $(document).height() - $(window).height()}, 600)
				@dom_group.find(".question_area").focus()
		@activity_content = $(@dom_group).find(".activity_content")[0]
		$(@dom_group).find(".header_text_container").on "click", () => $(@activity_content).toggle 400
		$(@dom_group).find(".delete_question_container").on "click", (e) => 
			@delete @question_id
		$(@dom_group.find(".question_group")).on "keydown", (e) => 
			if e.keyCode == 9 and @answers.length < 1
				e.preventDefault() 
				@answers.push new Answer this
				@save
			$(@dom_group).find(".question_media_box").fadeIn 600
		@dom_group.find(".question_group").on "change", @save
		@dom_group.find($('.add_answer')).on "click", () => @answers.push new Answer this if @answers.length < 4
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
	delete: (id) =>
		question = @
		$("#dialog-confirm").dialog({
			resizable: false
			modal: true
			title: "Delete this question?"
			buttons: { 
				"Cancel": () -> $(this).dialog("close")
				"Delete": () -> 
					$(this).dialog("close")
					question.dom_group.hide()
					if id
						$.ajax
							url: "/questions/" + id
							type: "DELETE"
			}
			closeOnEscape: true
			draggable: false
			resizable: false
			modal: true
			height: 180
		})
		$(".ui-widget-overlay").click -> $(".ui-dialog-titlebar-close").trigger('click')	
	addMedia: (contains_answer, resource) =>
		question = @
		$("#media-dialog").dialog({
			title: "Add Media"
			buttons: 
				"Done": () -> 
					# Close modal.
					$(this).dialog("close")

					# Collect values.
					if $(this).find("#image_link_input")[0].value != ""
						url = $(this).find("#image_link_input")[0].value
						preview = url
						begin = null
						end = null
						media_type = "image"
						article_text = null
					else if $(this).find("#article_link_input")[0].value != ""
						url = "http://en.wikipedia.org/wiki/" + $(this).find("#article_link_input")[0].value
						preview = question.article_placeholder_url
						begin = null
						end = null
						media_type = "text"
						article_text = $(this).find("#article_preview_field")[0]
					else if $(this).find("#video_link_input")[0].value != ""
						url = $(this).find("#video_link_input")[0].value
						preview = question.video_placeholder_url
						begin = $("#video_start_input")[0].value
						end = $("#video_end_input")[0].value
						media_type = "video"
						article_text = null
					$(this).find("#image_link_input")[0].value = ""
					$(this).find("#article_link_input")[0].value = ""
					$(this).find("#video_link_input")[0].value = ""
					$(this).find("#video_start_input")[0].value = ""
					$(this).find("#video_end_input")[0].value = ""

					# Set preview image.
					question_preview = $($(question.dom_group).find(".question_media_box").find("img")[0])
					answer_preview = $($(question.dom_group).find(".answer_media_box").find("img")[0])
					if contains_answer then answer_preview.attr "src", preview else question_preview.attr "src", preview

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
                        new_resource = new Resource resource, question
                        new_resource.save()
                        if contains_answer then question.answer_media = new_resource else question.question_media = new_resource
			closeOnEscape: true
			draggable: true
			resizable: false
			modal: true
			height: 600
			width: "70%"
		})
		$(".ui-widget-overlay").click -> $(".ui-dialog-titlebar-close").trigger('click')


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
			else if e.keyCode == 9 and @question.answers.length == 4 and $(@dom_element).next(".answer").length < 1
				new Question
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
	dom_element: null
	url: null
	contains_answer: null
	resource_id: null
	question: null # Stores the parent question object
	media_type: null
	start: null
	end: null
	constructor: (resource, question) -> 
		@contains_answer = resource["resource"]["contains_answer"]
		@resource_id = resource["resource"]["id"]
		@url = resource["resource"]["url"]
		@media_type = resource["resource"]["media_type"]	
		@begin = resource["resource"]["begin"]	
		@end = resource["resource"]["end"]		
		@question = question
		@article_text = resource["resource"]["article_text"]
	save: () =>
		[submit_url, method] = if @resource_id then ["/resources/" + @resource_id, "PUT"] else ["/resources", "POST"]	
		resource_data = 
			"resource" :
				url: @url
				contains_answer: @contains_answer
				question_id: @question.question_id
				media_type: @media_type
				begin: @begin
				end: @end
				article_text: String(@article_text.innerHTML)
		console.log resource_data
		$.ajax
			url: submit_url
			type: method
			data: resource_data
			success: (e) => @resource_id = e


class Controller
	constructor: -> @hideActivities()
	scrollToTop: -> $.scrollTo 0, 500
	scrollToBottom: -> $.scrollTo document.body.scrollHeight, 500
	hideActivities: -> $(".activity_content").hide()	


class MediaController
	constructor: -> 
		window.wikiAutocomplete = @wikiAutocomplete
		$("#article_link_input").autocomplete
			source: (request, response) => 
				$("html").append "<script src='http://en.wikipedia.org/w/api.php?action=opensearch&search=#{request.term}&namespace=0&suggest=&callback=wikiAutocompleteCallback'></script>"
				window.wikiAutocompleteCallback = (r) -> response(r[1])
			select: (e) => 
				if e.which == 13 then term = e.srcElement.value else term = e.srcElement.innerText
				@updatePreview("http://en.wikipedia.org/wiki/" + term.replace(/\ /g, '_'))		
		$("#image_preview_button").on "click", (e) =>
			e.preventDefault()
			@updatePreview("http://en.wikipedia.org/wiki/" + $("#article_link_input")[0].value.replace(" ", "_"))
		$("#article_preview_field").on "click", "p", (e) -> 
			if $(e.srcElement).parent().is("span") then $(e.srcElement).unwrap() else
				$(e.srcElement).wrap '<span class="highlighted" />'
		$("#article_preview_field").on "click", "a", (e) =>
			e.preventDefault()
			$("#article_link_input")[0].value = $(e.srcElement).attr "title"
			@updatePreview($(e.srcElement).attr "href")
	updatePreview: (url) =>
		params = "url" : url
		$.ajax
			url: "/parse_article/"
			type: "POST"
			data: params
			success: (text) => $("#article_preview_field").html text


$ -> 
	window.controller = new Controller
	window.media = new MediaController
	window.builder = new Builder