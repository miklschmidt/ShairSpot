define [
	'chaplin'
], ({Model}) ->

	class QueueItemModel extends Model

		backend: 'queue'