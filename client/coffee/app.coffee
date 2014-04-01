define [
	'jquery'
	'chaplin'
	'socketio'
	'backboneio'

	'bootstrap'
], ($, Chaplin, io, backboneio) ->
	'use strict'

	# The application object.
	# Choose a meaningful name for your application.
	class Application extends Chaplin.Application
		title: 'Chaplin example application'


		start: ->
			super

		initMediator: () ->
			Chaplin.mediator.socket = backboneio.connect()
			Chaplin.mediator.socket.on 'error', (err) ->
				console.log 'ERROR:', err
			super