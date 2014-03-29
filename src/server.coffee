express = require 'express'
http = require 'http'
fs = require 'fs'
path = require 'path'
sockets = require './sockets'
Spotify = require './spotify'

app = express()
server = http.createServer app
io = require('socket.io').listen server

publicDir = path.join __dirname, '..', 'public'

app.use express.static publicDir

app.get '/', (req, res) ->
	res.send fs.readFileSync path.join(publicDir, 'index.html'), 'utf8'

sockets.initialize io, app
sockets.server.on 'connection', (client) ->
	client.spotify = new Spotify(sockets.server, client)

server.listen 1337
console.log 'server running on port 1337'