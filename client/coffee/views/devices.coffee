define [
	'views/base/collection-view'
	'views/device'
	'hbs!templates/devices'
], (CollectionView, DeviceView, tmpl) ->

	class DevicesView extends CollectionView

		template: tmpl
		itemView: DeviceView
		listSelector: '.content.devices ul'
		container: "#main-menu"

		initialize: () ->
			super
			console.log @collection
			@listenTo @collection, 'add', () ->
				console.log 'yup collection add'

			@listenTo @collection, 'add remove reset sync', () ->
				@$('.header.devices .count').text @collection.length
				@$('.header.devices span.icon').html ''

			@delegate 'click', '.header.devices', () ->
				@collection.fetch()
				@$('.header.devices span.icon').html '<i class="icon-cycle spin"></i>'
