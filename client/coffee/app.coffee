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
			$("#login-modal").modal()
			$("#login-modal #login-button").click (e) ->
				e.preventDefault()
				username = $('#username').val()
				password = $('#password').val()

				Chaplin.mediator.socket.emit 'login', {username, password}, (err) ->
					alert err if err
					$('#login-modal').modal('hide')

		initMediator: () ->
			Chaplin.mediator.socket = backboneio.connect()
			super