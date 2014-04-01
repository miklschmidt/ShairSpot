define [
	'chaplin'
	'collections/airplay'
	'collections/queue'
	'collections/players'
	'views/queue'
	'views/devices'
	'views/player'
	'views/login'
], ({Controller}, AirplayDeviceCollection, QueueCollection, PlayerCollection, QueueView, DevicesView, PlayerView, LoginView) ->

	class QueueController extends Controller

		index: () ->
			{collection} = @reuse 'queue-collection', () ->
				@collection = new QueueCollection
				@collection.fetch()

			@reuse 'device-menu', {
				compose: () ->
					@collection = new AirplayDeviceCollection
					@collection.fetch()
					console.log 'models', @collection.models
					@view = new DevicesView {@collection, autoRender: true, autoAttach: true}

				check: (composition) ->
					return false
			}

			@reuse 'queue-view', () ->
				@view = new QueueView {collection, container: "#main", autoRender: true, autoAttach: true}

			@reuse 'player', () ->
				collection = new PlayerCollection
				collection.fetch success: () =>
					@model = collection.models[0] 
					@view = new PlayerView {@model}

			@reuse 'login', LoginView