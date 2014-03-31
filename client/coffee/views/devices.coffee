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