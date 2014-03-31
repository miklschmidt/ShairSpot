airtunes = require 'airtunes'
mdns     = require './mdns'

module.exports = (backend, db) ->

	deviceConnections = {}

	backend.use 'read', (req, res, next) ->
		console.log 'airplay#read'
		next() if req.model.id

		mdns.findDevices (err, devices) ->
			# Preserve connection status
			models = db.getStore
			for device in devices
				for id, model of models when model.host is device.host and model.port is device.port
					device.active = model.active
					device.deviceConnection = model.deviceConnection
			console.log devices
			db.setStore devices
			next()

	backend.use 'create', (req, res, next) ->
		console.log 'airplay#create'
		next new Error("Cannot create an airtunes device")

	backend.use 'delete', (req, res, next) ->
		console.log 'airplay#delete'
		next new Error("Cannot delete an airtunes device")

	backend.use 'update', (req, res, next) ->
		console.log 'airplay#update'
		clientModel = req.model
		model = db.getModel(clientModel.id)
		
		return next new Error("No such model") unless model

		if clientModel.active is yes
			deviceConnections[model.id] = airtunes.add model.host, {port: model.port, volume: clientModel.volume or 10}
			model.active = yes
			next()
			deviceConnections[model.id].on 'status', (status) -> 
				console.log status
				if status is 'ready'
					model.active = yes
				else
					model.active = no
				backend.emit 'updated', model

			deviceConnections[model.id].on 'error', (error) -> 
				console.log error
				model.active = no
				backend.emit 'updated', model

		else if model.deviceConnection?
			return next() unless deviceConnections[model.id]?
			deviceConnections[model.id].stop () ->
				model.active = no
				delete model['deviceConnection']
				next()