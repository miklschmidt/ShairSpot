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
require('./player')(player, queueControl)

###
# Socket setup
###

io = backboneio.listen server, {airplay, queue, player}
sockets.initialize io, app
sockets.server.on 'connection', (client) ->
	client.spotify = new Spotify(sockets.server, client)

###
# Start server
###

server.listen 1337
console.log 'server running on port 1337'