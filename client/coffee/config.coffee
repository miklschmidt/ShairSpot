requirejs.config

	baseUrl: "./js/"
	paths:
		jquery: "vendor/jquery/jquery"
		backbone: "vendor/backbone/backbone"
		underscore: "vendor/lodash/dist/lodash"
		hbs: "vendor/requirejs-hbs/hbs"
		chaplin: "vendor/chaplin/chaplin"
		socketio: "/socket.io/socket.io"
		backboneio: "/socket.io/backbone.io"
		bootstrap: "vendor/bootstrap/bootstrap.2.0.4.min"

	hbs:
		helperPathCallback: (name) ->
			return 'helpers/' + name
		disableI18n: true

	shim:
		backbone:
			deps: ['underscore', 'jquery']
			exports: 'Backbone'
		backboneio:
			deps: ['backbone', 'socketio']
			exports: 'Backbone.io'

require ['backboneio'], () ->
	require ['app', 'routes'], (Application, routes) ->
		new Application routes: routes, controllerSuffix: ''