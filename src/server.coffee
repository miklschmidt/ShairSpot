###
# Dependencies
###

express  = require 'express'
http     = require 'http'
fs       = require 'fs'
path     = require 'path'
sockets  = require './sockets'
Spotify  = require './spotify'
backboneio = require 'backbone.io'
memoryStore = require './memory-store'
airtunes = require 'airtunes'

###
# Config
###

app = express()
server = http.createServer app

publicDir = path.join __dirname, '..', 'public'
controllerDir = path.join(__dirname, 'controllers')

app.use express.static publicDir

###
# HTTP Routes
###
app.get '/', (req, res) ->
	res.send fs.readFileSync path.join(publicDir, 'index.html'), 'utf8'

###
# Airplay
###

airplay = backboneio.createBackend()
airplayDB = memoryStore airplay
require('./airplay')(airplay, airplayDB)
airplay.use airplayDB.middleware

###
# Queue
###

queue = backboneio.createBackend()
queueControl = require('./queue')(queue)

###
# Player
###

player = backboneio.createBackend()
playerControl = require('./player')(player, queueControl)

###
# Socket setup
###

io = backboneio.listen server, {airplay, queue, player}
sockets.initialize io, app
sockets.server.on 'connection', (client) ->
	client.spotify = new Spotify(sockets.server, client)
	client.socket.on 'player:volume', (vol) ->
		playerControl.setVolume vol

###
# Start server
###

server.listen 1337
console.log 'server running on port 1337'

process.on 'uncaughtException', (err) ->
	console.log 'UNCAUGHT'
	console.log err
	console.log err.stack

airtunes.on 'error', (err) ->
	console.log 'AIRTUNES ERROR' 
	console.log err
	console.log err.stack