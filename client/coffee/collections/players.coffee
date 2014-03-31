define [
	'chaplin'
	'models/player'
], ({Collection}, PlayerModel) ->

	class PlayerCollection extends Collection

		backend: 'player'
		model: PlayerModel

		initialize: () ->
			super
			@bindBackend()