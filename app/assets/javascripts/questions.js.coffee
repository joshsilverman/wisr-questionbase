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
			for question_resource in $(@dom_group).find(".question_media_box").find("img")
				@resources.push new Resource question_resource, this
				$(question_resource).on "click", () -> console.log "update!"
			for answer_resource in $(@dom_group).find(".answer_media_box").find("img")
				@resources.push new Resource answer_resource, this
				$(answer_resource).on "click", () -> console.log "update!"
		else # Creating new question
			@dom_group = $($('#activity_group')[0]).clone().removeAttr("id").attr("class", "activity_group")
			@dom_group.appendTo $('#activities')[0]
			@dom_group.find(".question_area").focus()
			$(@dom_group).find(".question_media_box").hide()
			$(@dom_group).find(".answer_media_box").hide()
		@question_media = $(@dom_group).find(".question_media_box")
		@answer_media = $(@dom_group).find(".answer_media_box")			
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
		#@question_media.on "click", () => @addMedia()
		#@answer_media.on "click", () => @addMedia()
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
	addMedia: () => 
		question = this
		$("#media-dialog").dialog({
			title: 'Add Media'
			buttons: { 
				"Done": () -> 
					$(this).dialog("close")
					question.createResource($(this).find("#modal_image_link")[0].value if $(this).find("#modal_image_link")[0].value)
			}
			closeOnEscape: true
			draggable: false
			resizable: false
			modal: true
			height: 400
			width: 600
		})
		$(".ui-widget-overlay").click -> $(".ui-dialog-titlebar-close").trigger('click')
	createResource: (url) -> 
		console.log "create Resource"
		#console.log this, url
		#@resources.push new Resource url, this
			

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
	question: null # Stores the parent question object
	constructor: (dom_element, question) -> 		
		@question = question
		@url = dom_element.getAttribute "src"
		@dom_element = dom_element
		#console.log @question, @url, @dom_element
		#$(question.dom_group).find(".question_media_box").css("background-image", "url(" + url + ")")
#		console.log $('#resource').clone().removeAttr("id")
#		$('#resource').clone().removeAttr("id").appendTo @question.dom_group.find($(".resource_group"))



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
	
