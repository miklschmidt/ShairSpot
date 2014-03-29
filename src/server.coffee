express = require 'express'
http = require 'http'
fs = require 'fs'
path = require 'path'
sockets = require './sockets'
Spotify = require './spotify'
airtunes = require 'airtunes'
mdns = require './mdns'

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

## Temporary hack: Add all visible devices
mdns.findDevices (err, devices) ->
	if devices
		for device in devices
			console.log "Streaming to #{device.name} @ #{device.host}:#{device.port}"
			connectedDevice = airtunes.add device.host, {port: device.port, volume: 100}
			connectedDevice.on 'ready', -> console.log 'ready', arguments
			connectedDevice.on 'stopped', -> console.log 'stopped', arguments
			connectedDevice.on 'error', -> console.log 'error', arguments

server.listen 1337
console.log 'server running on port 1337'