extend = require 'node.extend'

module.exports = (backend, db) ->
	# Save a reference to the spotify instance so we can play the file
	# as the right user.
	q = []
	id = 0
	clientMap = {}

	createQ = []
	createRunning = no

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

	return {
		getCurrent: () ->
			console.log q
			if q.length
				return q[0]
			else
				return null

		getClientFor: (id) ->
			return clientMap[id]

		shift: () ->
			model = q.shift()
			delete clientMap[model.id]
			backend.emit 'deleted', model
			return model

		markAsPlaying: (index) ->
			model = q[index]
			model.playing = true
			backend.emit 'updated', model
			return model

		hasItemsToCreate: () ->
			return createQ.length > 0

		createNext
	}