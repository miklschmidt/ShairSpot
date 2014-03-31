# Spotify = require 'spotify-web'
lame = require 'lame'
airtunes = require 'airtunes'
Spotify = require './node-spotify-edge/lib/spotify'
Speaker = require 'speaker'
User = require './node-spotify-edge/lib/user'
Connection = require './node-spotify-edge/lib/connection/connection'

module.exports = class SpotifyClient

	username: null
	password: null

	constructor: (@sockets, @client) ->
		@setupEvents()

	setupEvents: () ->
		@client.socket.on 'login', @setLogin.bind @

	setLogin: (credentials, callback) ->
		Spotify.login credentials.username, credentials.password, (err, spotify) =>
			if err
				callback err.toString()
			else
				{@username, @password} = credentials
				User.get spotify, @username, (err, user) =>
					return @handleError err, spotify if err
					# return spotify.disconnect() if err
					user.get (err, user) =>
						return @handleError err, spotify if err
						@client.set 'username', user.fullName
						callback()
						spotify.disconnect()

	login: (callback) ->
		unless @username and @password
			@client.socket.emit 'invalid-login'
			callback new Error("No login credentials specified")
		else
			Spotify.login @username, @password, (err, spotify) ->
				return @handleError err, spotify if err
				callback err, spotify

	handleError: (err, spotify) ->
		@client.emit 'error', err
		spotify.disconnect()

	getMetaData: (trackURI, callback) ->
		@login (err, spotify) ->
			return @handleError err, spotify if err
			spotify.get trackURI, (err, track) ->
				return @handleError err, spotify if err
				spotify.disconnect()
				callback err, track

	userInfo: (username, callback) ->


	play: (uri, callback, endCallback) ->
		@login (err, spotify) =>
			return @handleError(err, spotify) if err

			spotify.get uri, (err, track) =>
				return @handleError(err, spotify) if err
				stream = track.play()
				.pipe new lame.Decoder()
				stream.pipe new Speaker()
				.on 'finish', () -> 
					spotify.disconnect()
					endCallback()
				callback(stream)



