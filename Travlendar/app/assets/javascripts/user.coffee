# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@displayError = (id, errorMessage) ->
	item = $('#' + id)
	item.addClass('error')
	#errorDescription = item.parent().next()
	#errorDescription[0].innerHTML = errorMessage
	#errorDescription.show()