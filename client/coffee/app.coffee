$ () ->
	socket = io.connect 'http://localhost:1337'
	$("#login-modal").modal()
	$("#login-modal #login-button").click (e) ->
		e.preventDefault()
		username = $('#username').val()
		password = $('#password').val()

		socket.emit 'login', {username, password}, (err) ->
			alert err if err
			$('#login-modal').modal('hide')