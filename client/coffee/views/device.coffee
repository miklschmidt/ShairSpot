define [
	'views/base/view'
	'hbs!templates/device'
], (View, tmpl) ->

	class DeviceView extends View

		template: tmpl
		tagName: 'li'

		initialize: () ->
			super
			@listenTo @model, 'change:active', @render
			@delegate 'click', () ->
				@model.set('active', not @model.get('active'), {silent: true})
				@$('.status').removeClass('active inactive').addClass('syncing').find('i').attr('class', 'icon-cycle spin')
				@model.save({active: @model.get('active')})

		getTemplateData: () ->
			data = super
			data