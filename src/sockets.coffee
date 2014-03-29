EventEmitter = require('events').EventEmitter

module.exports.initialize = (io, app) ->

	class SocketServer extends EventEmitter

		constructor: () ->
			# if app.settings.env is 'production'
			# 	io.enable('browser client minification')
			# 	io.enable('browser client etag')
			# 	io.enable('browser client gzip')
			# 	io.set('log level', 1)
			# 	io.set 'transports', [
			# 		'websocket'
			# 		'htmlfile'
			# 		'xhr-polling'
			# 		'jsonp-polling'
			# 	]

			io.sockets.on 'connection', @clientConnect

		getUserRoom: (userID) ->
			return io.sockets.in(userID)

		getUserSockets: () ->
			return io.sockets.clients('users')

		getUserRoom: () ->
			return io.sockets.in('users')

		countConnections: () =>
			return @getUserSockets().length

		clientConnect: (socket) =>
			# console.log 'client connected'
			client = new SocketClient
			client.initialize socket, @
			@emit 'connection', client

	class SocketClient

		attributes: {}

		initialize: (@socket, @server) ->
			@socket.join('users')
			# Set up events
			@bindEvents()

		set: (attr, val) ->
			if typeof attr is 'string'
				console.log attr
				@attributes[attr] = val
				@socket.emit 'change', attr, val
			else
				for own key, val of attr
					@attributes[key] = val
				@socket.emit 'change', attr

		get: (attr) ->
			@attributes[attr]

		bindEvents: () =>
			@socket.on 'disconnect', @disconnect

		countConnections: (action, fn) =>
			if @socket.handshake.admin
				# console.log 'user is admin, connection count', @server.countConnections()
				if action is 'get'
					fn(@server.countConnections())

		disconnect: () =>
			@server = undefined
			@socket = undefined
			# Do stuff

	module.exports.server = new SocketServer