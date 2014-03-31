# Spotify = require 'spotify-web'
lame = require 'lame'
airtunes = require 'airtunes'
Spotify = require './node-spotify-edge/lib/spotify'
Speaker = require 'speaker'
User = require './node-spotify-edge/lib/user'
Connection = require './node-spotify-edge/lib/connection/connection'

module.exports = class SpotifyClient

	constructor: (@sockets, @client) ->
		@setupEvents()
		@username = null
		@password = null

	setupEvents: () ->
		@client.socket.on 'login', @setLogin.bind @

	setLogin: (credentials, callback) ->
		Spotify.login credentials.username, credentials.password, (err, spotify) =>
			if err
				callback err.toString()
			else
				{@username, @password} = credentials
				User.get spotify, @username, (err, user) =>
					return @handleError err, spotify, callback if err
					# return spotify.disconnect() if err
					user.get (err, user) =>
						return @handleError err, spotify, callback if err
						@client.set 'username', (user.fullName or user.username)
						callback()
						spotify.disconnect()

	login: (callback) ->
		try
			unless @username and @password
				@client.socket.emit 'invalid-login'
				callback new Error("No login credentials specified")
			else
				Spotify.login @username, @password, (err, spotify) =>
					return @handleError err, spotify, callback if err
					callback err, spotify
		catch e
			callback e

	handleError: (err, spotify, callback) ->
		@client.socket.emit 'error', err.toString()
		spotify?.disconnect()
		callback? err

	getMetaData: (trackURI, callback) ->
		@login (err, spotify) =>
			return @handleError err, spotify, callback if err
			spotify.get trackURI, (err, track) ->
				return @handleError err, spotify, callback if err
				spotify.disconnect()
				callback err, track

	userInfo: (username, callback) ->


	play: (uri, callback, endCallback) ->
		@login (err, spotify) =>
			return @handleError(err, spotify, endCallback) if err

			spotify.get uri, (err, track) =>
				return @handleError(err, spotify, endCallback) if err
				stream = track.play()
				.pipe new lame.Decoder()
				.on 'finish', () ->
					stream.unpipe airtunes # prevent airtunes buffer from ending
					spotify.disconnect()
					endCallback()
				stream.pipe airtunes
				callback(stream)



