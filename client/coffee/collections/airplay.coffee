define [
	'chaplin'
	'models/airplay-device'
], ({Collection}, AirplayDeviceModel) ->

	class AirplayCollection extends Collection

		backend: 'airplay'
		model: AirplayDeviceModel

		initialize: () ->
			super
			@bindBackend()

			@listenTo @, 'backend', () ->
				console.log arguments

			@listenTo @, 'add', () ->
				console.log 'add', arguments