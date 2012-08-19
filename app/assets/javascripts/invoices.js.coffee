# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# class Builder 
# 	constructor: ->
# 		@initializeListeners()
# 	initializeListeners: => 
# 		$("#user_first_name").on "change", (e) => window.location = "/users/#{$("#user_first_name").attr "value"}/invoices"
# 		$(".paid_checkbox").on "change", (e) => 
# 			params = 
# 				"invoice":
# 					"paid": if $(e.srcElement).attr("checked") == "checked" then true else false
# 			$.ajax
# 				url: "/invoices/#{$(e.srcElement).attr "invoice_id"}.json"
# 				type: "PUT"
# 				data: params

# $ -> new Builder