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
					# return @disconnect(spotify) if err
					user.get (err, user) =>
						return @handleError err, spotify, callback if err
						@client.set 'username', (user.fullName or user.username)
						callback()
						@disconnect(spotify)

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

	disconnect: (spotify) ->
		try
			spotify.disconnect()
		catch e
			@handleError e, spotify

	handleError: (err, spotify, callback) ->
		@client.socket.emit 'error', err.toString()
		spotify?.disconnect()
		callback? err

	getMetaData: (trackURI, callback) ->
		@login (err, spotify) =>
			return @handleError err, spotify, callback if err
			try
				spotify.get trackURI, (err, track) =>
					return @handleError err, spotify, callback if err
					@disconnect(spotify)
					callback err, track
			catch e
				callback e

	play: (uri, callback, endCallback) ->
		try
			@login (err, spotify) =>
				return @handleError(err, spotify, endCallback) if err
				try
					spotify.get uri, (err, track) =>
						return @handleError(err, spotify, endCallback) if err
						try
							stream = track.play()
							.on 'error', (err) =>
								@handleError(err, spotify, endCallback)
							.pipe new lame.Decoder()
							.on 'finish', () =>
								stream.unpipe airtunes # prevent airtunes buffer from ending
								@disconnect(spotify)
								endCallback()
							stream.pipe airtunes
							callback(stream)
						catch e
							return @handleError(e, spotify, endCallback) if err
				catch e
					@play uri, callback, endCallback
		catch e
			@play uri, callback, endCallback



