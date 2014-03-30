module.exports = (backend, db) ->
	# Save a reference to the spotify instance so we can play the file
	# as the right user.
	backend.use 'create', (req, res, next) ->
		req.model.spotifyClient = req.socket.get('client').spotify
		next()