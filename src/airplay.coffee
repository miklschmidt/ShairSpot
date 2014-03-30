airtunes = require 'airtunes'
mdns     = require './mdns'

module.exports = (backend, db) ->

	backend.use 'read', (req, res, next) ->
		next() if req.model.id

		mdns.findDevices (err, devices) ->
			# Preserve connection status
			for device in devices
				for model in models when model.host is device.host and model.port is device.port
					device.active = model.active
					device.deviceConnection = model.deviceConnection
			db.set devices
			next()

	backend.use 'create', (req, res, next) ->
		next new Error("Cannot create an airtunes device")

	backend.use 'delete', (req, res, next) ->
		next new Error("Cannot delete an airtunes device")

	backend.use 'update', (req, res, next) ->
		clientModel = req.model
		model = db.getModel(clientModel.id)
		
		next new Error("No such model") unless model

		if clientModel.active is yes
			model.deviceConnection = airtunes.add model.host, {port: model.port, volume: clientModel.volume or 50}
			
			model.deviceConnection.on 'status', (status) -> 
				if status is 'ready'
					model.active = yes
				else
					model.active = no
				res.end model

			model.deviceConnection.on 'error', (error) -> 
				model.active = no
				backend.emit 'update', model

		else if model.deviceConnection?
			model.deviceConnection.stop () ->
				model.active = no
				delete model['deviceConnection']
				res.end model