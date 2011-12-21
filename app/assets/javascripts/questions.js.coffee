class Builder
	constructor: -> 
		for activity in $("#activities").find(".activity_group")
			new Question activity
	newQuestion: -> new Question


class Question
	question_id: null
	answers: []
	dom_group: null # Stores the div w/ the question area + add Q button
	changed: false
	constructor: (dom_group) ->
		@answers = []
		if dom_group # If initializing existing question
			@dom_group = $(dom_group)
			@question_id = $(@dom_group[0]).find($("textarea"))[0].getAttribute "question_id"
			for answer_element in @dom_group.find(".answer_group").find("input")
				@answers.push new Answer(this, answer_element)
		else # If new question
			@dom_group = $($('#activity_group')[0]).clone().attr("id", "").attr("class", "activity_group")
			@dom_group.appendTo $('#activities')[0]	
			window.control.scrollToBottom()
		@dom_group.find(".question_group").change @save
		@dom_group.find($('.add_answer')).click () => @answers.push new Answer this
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
			@answer_id = answer_element.getAttribute "answer_id"
			if @correct then $(@dom_element).prev(".correct")[0].innerHTML = "O" else $(@dom_element).prev(".correct")[0].innerHTML = "X"
		else # If new answer
			@dom_element = $('#answer').clone().attr("id", "")
			@dom_element.appendTo question.dom_group.find(".answer_group")
			if @correct then $(@dom_element).find(".correct")[0].innerHTML = "O" else $(@dom_element).find(".correct")[0].innerHTML = "X"
		$(@dom_element).change @save
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
			success: (e) =>
				console.log e
				@answer_id = e

class Controls
	scrollToTop: -> $.scrollTo 0, 500
	scrollToBottom: -> $.scrollTo document.body.scrollHeight, 500

# class Resource

# class Tag (?)

$ -> 
	window.control = new Controls
	window.builder = new Builder
	
