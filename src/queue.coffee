extend = require 'node.extend'

module.exports = (backend, db) ->
	# Save a reference to the spotify instance so we can play the file
	# as the right user.
	q = []
	id = 0
	clientMap = {}

	createQ = []
	createRunning = no
	lastShift = null
	lastClient = null

	createNext = () ->
		createRunning = yes
		{req, res, next, spotify, uri} = createQ.shift()
		spotify.getMetaData uri, (err, track) ->
			if err
				unless createQ.length
					createRunning = no
				else
					createNext()
				return next(err)
			# TODO err handling
			artists = (artist.name for artist in track.artist)
			req.model.artist = artists.join ', '
			req.model.title = track.name
			req.model.duration = track.duration
			req.model.album = track.album.name
			req.model.user = req.socket.store.data.client.get('username')
			req.model.id = id++

			q.push req.model
			clientMap[req.model.id] = req.socket.store.data.client
			res.end req.model
			unless createQ.length
				createRunning = no
			else
				createNext()

	backend.use 'create', (req, res, next) ->
		spotify = req.socket.store.data.client.spotify
		createQ.push {req, res, next, spotify, uri: req.model.uri}
		process.nextTick createNext unless createRunning


	backend.use 'read', (req, res, next) ->
		if req.model.id
			for model in q when req.model.id is model.id
				return res.end model
		else
			res.end q

	backend.use 'delete', (req, res, next) ->
		for model, index in q when req.model.id is model.id
			q.splice(index,1) # remove the model from the q
			delete clientMap[req.model.id]
			res.end model

	backend.use 'update', (req, res, next) ->
		res.end new Error("not implemented yet")

	return publicMethods = {
		getCurrent: (callback) ->
			if q.length
				callback q[0]
			else
				# add a similar track to the last one in the queue (TODO: Setting)
				spotify = lastClient.spotify
				spotify.login (err, conn) =>
					conn.get lastShift.uri, (err, track) =>
						callback null if err
						track.similar (err, tracks) =>
							return callback null if err or not tracks.length
							# console.log tracks
							nextTrack = tracks[Math.floor(Math.random() * tracks.length)]
							conn.disconnect()
							spotify.getMetaData nextTrack.uri._uri_parts.join(':'), (err, track) ->
								callback null if err
								# TODO err handling
								artists = (artist.name for artist in track.artist)
								model = {uri: nextTrack.uri._uri_parts.join(':')}
								model.artist = artists.join ', '
								model.title = track.name
								model.duration = track.duration
								model.album = track.album.name
								model.user = lastClient.get('username')
								model.id = id++

								q.push model
								backend.emit 'created', model
								clientMap[model.id] = lastClient
								callback q[0]
				, false

		getClientFor: (id) ->
			return clientMap[id]

		shift: () ->
			shift = q.shift()
			return unless shift
			lastShift = shift
			lastClient = publicMethods.getClientFor(lastShift.id)
			delete clientMap[lastShift.id]
			backend.emit 'deleted', lastShift
			return lastShift

		markAsPlaying: (index) ->
			model = q[index]
			model.playing = true
			backend.emit 'updated', model
			return model

		hasItemsToCreate: () ->
			return createQ.length > 0

		createNext
	}