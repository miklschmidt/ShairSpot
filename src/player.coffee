airtunes = require 'airtunes'
airtunesDevices = require 'airtunes/lib/devices'

module.exports = (player, queueControl) ->

	class Player

		track: null
		currentStream: null
		playtime: 0
		playtimeInterval: null
		volume: 25

		constructor: (@playing = no) ->

		play: () ->
			queueControl.getCurrent (@track) =>
				if @track?
					client = queueControl.getClientFor @track.id
					queueControl.markAsPlaying(0)
					@playing = yes
					client.spotify.play @track.uri, (currentStream) =>
						@playtime = 0
						@playtimeInterval = setInterval () =>
							@playtime++
							player.emit 'updated', @serialize()
						, 1000
						@currentStream = currentStream
					, () =>
						clearInterval @playtimeInterval
						@currentStream = null
						@next()
				else
					@playing = no
					@playtime = 0
					player.emit 'updated', @serialize()

		setVolume: (vol) =>
			@volume = vol
			player.emit 'updated', @serialize()
			airtunesDevices.forEach (device) ->
				device.setVolume vol

		stop: () ->
			if @currentStream
				@playing = no
				@currentStream.end() unless @currentStream.ended

		next: () ->
			queueControl.shift()
			@play() if @playing

		serialize: () ->
			{id: 1, @playing, @track, @playtime, @volume}

	audioPlayer = new Player()

	player.use 'create', (req, res, next) ->
		console.log 'player#create'
		return next(new Error("Can't create players"))
	player.use 'read', (req, res, next) ->
		console.log 'player#read'
		res.end audioPlayer.serialize()
	player.use 'update', (req, res, next) ->
		console.log 'player#update'
		if req.model.playing and not audioPlayer.playing
			audioPlayer.play()
		else if not req.model.playing and audioPlayer.playing
			audioPlayer.stop()
		res.end audioPlayer.serialize()
	player.use 'delete', (req, res, next) ->
		console.log 'player#delete'
		return next(new Error("Can't delete players"))

	return audioPlayer