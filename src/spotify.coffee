Spotify = require 'spotify-web'
Speaker = require 'speaker'
lame = require 'lame'

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
				spotify.once 'login', () ->	@client.set 'username', spotify.username
				callback()
				spotify.disconnect()
				@testPlay()

	login: (callback) ->
		Spotify.login @username, @password, (err, spotify) ->
			callback err, spotify

	handleError: (err, spotify) ->
		@client.emit 'error', err
		spotify.disconnect()

	testPlay: () ->
		@login (err, spotify) =>
			return @handleError(err, spotify) if err

			spotify.get 'spotify:track:666elemQTQGi8xbjAAdIgB', (err, track) =>
				return @handleError(err, spotify) if err
				track.play()
				.pipe new lame.Decoder()
				.pipe new Speaker()
				.on 'finish', () -> spotify.disconnect()



