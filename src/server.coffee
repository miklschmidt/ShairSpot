express  = require 'express'
http     = require 'http'
fs       = require 'fs'
path     = require 'path'
sockets  = require './sockets'
Spotify  = require './spotify'
backboneio = require 'backbone.io'
memoryStore = require './memory-store'

app = express()
server = http.createServer app

publicDir = path.join __dirname, '..', 'public'
controllerDir = path.join(__dirname, 'controllers')

app.use express.static publicDir

app.get '/', (req, res) ->
	res.send fs.readFileSync path.join(publicDir, 'index.html'), 'utf8'

### 
# Airplay
###

airplay = backboneio.createBackend()
airplayDB = memoryStore airplay
airplay.use airplayDB
require('./airplay')(queue, queueDB)

###
# Queue
###

queue = backboneio.createBackend()
queueDB = memoryStore queue
queue.use queueDB
require('./queue')(queue, queueDB)

io = backboneio.listen server, {airplay, queue}
sockets.initialize io, app
sockets.server.on 'connection', (client) ->
	client.spotify = new Spotify(sockets.server, client)

server.listen 1337
console.log 'server running on port 1337'