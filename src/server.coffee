express = require 'express'
fs = require 'fs'
path = require 'path'

app = express()

publicDir = path.join __dirname, 'public'

app.use express.static publicDir

indexHTML = fs.readFileSync path.join(publicDir, 'index.html'), 'utf8'

app.get '/', (req, res) ->
	res.send indexHTML

app.listen(1337)