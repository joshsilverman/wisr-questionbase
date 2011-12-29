class Builder
	constructor: -> 
		for activity in $("#activities").find(".activity_group")
			new Question activity
	newQuestion: -> new Question


class Question
	question_id: null
	answers: []
	resources: []
	question_resources: []
	answer_resources: []
	dom_group: null # Stores the div w/ the question area + add answer button
	header: null #Stores the header div
	activity_content: null
	question_media: null
	answer_media: null
	changed: false
	constructor: (dom_group) ->
		@answers = []; @resources = []
		if dom_group # Initializing existing question
			@dom_group = $(dom_group)
			@question_id = $(@dom_group[0]).find($("textarea"))[0].getAttribute "question_id"
			for answer_element in @dom_group.find(".answer_group").find(".answer")
				@answers.push new Answer(this, answer_element)
			for question_resource in $(@dom_group).find(".question_media_box")
				if $(question_resource).find("img").attr("resource_id")
					@question_media = new Resource $(question_resource).find("img")[0], this, false
				$(question_resource).on "click", () => @addMedia false, @question_media 
			for answer_resource in $(@dom_group).find(".answer_media_box")
				if $(answer_resource).find("img").attr("resource_id")
					@answer_media = new Resource $(answer_resource).find("img")[0], this, true			
				$(answer_resource).on "click", () => @addMedia true, @answer_media
		else # Creating new question
			@dom_group = $($('#activity_group')[0]).clone().removeAttr("id").attr("class", "activity_group")
			@dom_group.appendTo $('#activities')[0]
			question_resource = $(@dom_group).find(".question_media_box")
			answer_resource = $(@dom_group).find(".answer_media_box").hide()
			question_resource.hide()
			question_resource.on "click", () => @addMedia false, @answer_media
			answer_resource.hide()
			answer_resource.on "click", () => @addMedia true, @answer_media
			#$(@dom_group).find(".question_media_box").hide()
			#$(@dom_group).find(".answer_media_box").hide()
			@dom_group.find(".activity_content").toggle 400, () => 
				$('html, body').animate({scrollTop: $(document).height() - $(window).height()}, 600)
				@dom_group.find(".question_area").focus()
		@activity_content = $(@dom_group).find(".activity_content")[0]
		@header = $(@dom_group).find(".header")		
		# Question listeners (save, new answer, new resource)
		$(@dom_group.find(".question_group")).on "keydown", (e) => 
			if e.keyCode == 9 and @answers.length < 1
				e.preventDefault() 
				@answers.push new Answer this
				@save
			$(@dom_group).find(".question_media_box").fadeIn 600
			#@answers.push new Answer this if @answers.length < 1
		$(@header).on "click", () => $(@activity_content).toggle 400
		@dom_group.find(".question_group").on "change", @save
		@dom_group.find($('.add_answer')).on "click", () => @answers.push new Answer this if @answers.length < 4
		@dom_group.find($(".add_resource")).on "click", () => @resources.push new Resource this
	save: (event) =>
		console.log "save q"
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
	addMedia: (contains_answer, resource) =>
		question = this
		$("#media-dialog").dialog({
			title: 'Add Media'
			buttons: { 
				"Done": () -> 
					$(this).dialog("close")
					if $(this).find("#modal_image_link")[0].value != ""
						url = $(this).find("#modal_image_link")[0].value
						if contains_answer
							dom_element = $(question.dom_group).find(".answer_media_box").find("img")[0]
							$(dom_element).attr "src", url
						else
							dom_element = $(question.dom_group).find(".question_media_box").find("img")[0]
							console.log question.dom_group.find(".question_media_box")
							$(dom_element).attr "src", url
						if resource
							resource.url = url
							resource.save()
						else 
							resource = new Resource(dom_element, question, contains_answer)
							resource.save()
							if contains_answer then question.answer_media = resource else question.question_media = resource
			}
			closeOnEscape: true
			draggable: false
			resizable: false
			modal: true
			height: 400
			width: 600
		})
		$(".ui-widget-overlay").click -> $(".ui-dialog-titlebar-close").trigger('click')

class Answer
	answer_id: null
	dom_element: null # Stores the answer dom element
	question: null # Stores the parent question object
	correct: null
	changed: false
	#number: null
	constructor: (question, answer_element) -> 
		@question = question
		#@number = question.answers.length
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
				console.log "yeah"
			else if e.keyCode == 9 and @question.answers.length == 4 and $(@dom_element).next(".answer").length < 1
				new Question
			$(@question.dom_group).find(".answer_media_box").fadeIn 600			
		#$(@dom_element).on "keypress", () => 
		#	@question.answers.push new Answer @question if @number < @question.answers.length
		#	console.log @number
		#	console.log @question.answers.length			
	save: (event) =>
		console.log "save"
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
			success: (e) =>
				@answer_id = e


class Resource
	dom_element: null
	url: null
	contains_answer: null
	resource_id: null
	question: null # Stores the parent question object
	constructor: (dom_element, question, contains_answer) -> 
		@contains_answer = contains_answer if contains_answer
		@question = question
		@resource_id = dom_element.getAttribute "resource_id"
		@url = dom_element.getAttribute "src"
		@dom_element = dom_element
	save: () =>
		console.log "save resource"
		[submit_url, method] = if @resource_id then ["/resources/" + @resource_id, "PUT"] else ["/resources", "POST"]	
		console.log submit_url, method, @question.question_id
		resource_data = 
			"resource" :
				url: @url
				contains_answer: @contains_answer
				question_id: @question.question_id
		$.ajax
			url: submit_url
			type: method
			data: resource_data
			success: (e) =>
				@resource_id = e



class Controller
	constructor: -> @hideActivities()
	scrollToTop: -> $.scrollTo 0, 500
	scrollToBottom: -> $.scrollTo document.body.scrollHeight, 500
	hideActivities: -> 
		$(".activity_content").hide()
	addMedia: ->
		$("#media-dialog").dialog({
			title: 'Add Media'
			buttons: { 
				"Done": () -> 
					new Resource $(this).find("#modal_image_link")[0].value if $(this).find("#modal_image_link")[0].value 
					$(this).dialog("close")
			}
			closeOnEscape: true
			draggable: false
			resizable: false
			modal: true
			height: 400
			width: 600
		})
		$(".ui-widget-overlay").click -> $(".ui-dialog-titlebar-close").trigger('click')	
	collectValues: (content) -> console.log content


# class Tag (?)

$ -> 
	window.controller = new Controller
	window.builder = new Builder
	
