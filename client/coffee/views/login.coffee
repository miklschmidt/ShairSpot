define [
	'chaplin'
	'views/base/view'
	'hbs!templates/login'
], ({mediator}, View, tmpl) ->

	class DeviceView extends View

		template: tmpl
		tagName: 'div'
		container: 'body'
		logging: no

		initialize: () ->
			super
			@delegate 'click', '#login-button', (e) ->
				e.preventDefault()
				do @login
			@delegate 'keyup', (e) =>
				if e.keyCode is 13
					do @login

		login: () ->
			return if @logging
			@logging = yes
			username = @$('#username').val()
			password = @$('#password').val()

			mediator.socket.emit 'login', {username, password}, (err) =>
				if err
					@logging = no
					alert err
					return
				window.localStorage.setItem 'username', username
				@$('#login-modal').modal('hide')

		getTemplateData: () ->
			data = {
				username: @getUsername()
			}
			return data

		getUsername: () ->
			window.localStorage.getItem 'username'

		render: () ->
			super
			@$("#login-modal").modal()
			if @getUsername()
				setTimeout () =>
					@$("#password").focus()
				, 300
			else

