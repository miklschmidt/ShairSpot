express = require 'express'
fs = require 'fs'
path = require 'path'

app = express()

publicDir = path.join __dirname, '..', 'public'

app.use express.static publicDir

app.get '/', (req, res) ->
	res.send fs.readFileSync path.join(publicDir, 'index.html'), 'utf8'

app.listen(1337)