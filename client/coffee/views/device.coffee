define [
	'chaplin'
	'views/base/view'
	'hbs!templates/device'
], ({mediator}, View, tmpl) ->

	class DeviceView extends View

		template: tmpl
		tagName: 'li'

		initialize: () ->
			super
			@listenTo @model, 'change', @render
			@delegate 'click', () ->
				@model.set('active', not @model.get('active'), {silent: true})
				@model.set('volume', mediator.execute('volume'))
				@$('.status').removeClass('active inactive').addClass('syncing').find('i').attr('class', 'icon-cycle spin')
				@model.save({active: @model.get('active')})

		getTemplateData: () ->
			data = super
			data

