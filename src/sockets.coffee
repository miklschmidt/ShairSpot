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
			socket.set 'client', client
			@emit 'connection', client

	class SocketClient

		attributes: {}

		initialize: (@socket, @server) ->
			@socket.join('users')
			# Set up events
			@bindEvents()

		set: (attr, val) ->
			if typeof attr is 'string'
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

		disconnect: () =>
			@server = undefined
			@socket = undefined
			# Do stuff

	module.exports.server = new SocketServer