# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@maxHeights = {}
@toggle = (date) ->
	item = $('#' + date + "-accordion")
	
	if(!@maxHeights[date] || item.css('max-height') == 'none')
		@setMaxHeight(date)

	if (item.css('max-height') != '0px')
		item.css('max-height', '0px')	
	else
		item.css('max-height', @maxHeights[date] + 'px')
	item = $('#' + date + "-separator").toggleClass("closed")

@setMaxHeight = (date) ->
	item = $('#' + date + "-accordion")
	@maxHeights[date] = item.height()
	item.css('max-height', @maxHeights[date] + 'px')