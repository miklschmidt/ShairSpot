define [
	'chaplin'
	'models/queue-item'
], ({Collection}, QueueItemModel) ->

	class QueueCollection extends Collection

		backend: 'queue'
		model: QueueItemModel

		initialize: () ->
			super
			@bindBackend()