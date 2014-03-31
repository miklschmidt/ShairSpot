module.exports = (player, queueControl) ->

	class Player

		track: null
		currentStream: null
		playtime: 0
		playtimeInterval: null
		constructor: (@playing = no) ->

		play: () ->
			if @currentStream
				# We were paused.. Resume!
				return @currentStream.play()
			@track = queueControl.getCurrent()
			console.log @track
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

		stop: () ->
			if @currentStream
				@playing = no
				@currentStream.end()

		next: () ->
			queueControl.shift()
			@play() if @playing

		serialize: () ->
			{id: 1, playing: audioPlayer.playing, track: audioPlayer.track, playtime: @playtime}

	audioPlayer = new Player()

	player.use 'create', (req, res, next) ->
		console.log 'player#create'
		return next(new Error("Can't create players"))
	player.use 'read', (req, res, next) ->
		console.log 'player#read'
		res.end audioPlayer.serialize()
	player.use 'update', (req, res, next) ->
		console.log 'player#update'
		console.log req.model
		if req.model.playing and not audioPlayer.playing
			audioPlayer.play()
		else if not req.model.playing and audioPlayer.playing
			audioPlayer.stop()
		res.end audioPlayer.serialize()
	player.use 'delete', (req, res, next) ->
		console.log 'player#delete'
		return next(new Error("Can't delete players"))