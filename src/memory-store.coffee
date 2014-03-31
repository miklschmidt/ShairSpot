extend = require 'node.extend'

module.exports = (backend) ->
	models = {}
	id = 0
	return {
		middleware: (req, res, next) =>
			crud =
				create: () ->
					model = req.model
					model.id = id++
					models[model.id] = model
					res.end model

				read: () ->
					if req.model.id
						res.end model[req.model.id]
					else
						result = (model for id, model of models)
						res.end result
				
				update: () ->
					extend true, models[req.model.id], req.model
					res.end models[req.model.id]

				delete: () ->
					delete models[req.model.id]
					res.end req.model

			return next new Error("Unsupported method #{req.method}") unless crud[req.method]?
			crud[req.method]()

		getModel: (id) =>
			return models[id]

		getStore: () =>
			return models

		setStore: (data) =>
			for index, model of models
				backend.emit 'deleted', model
				delete models[index]
			id = 0
			for model in data
				model.id = id++
				models[model.id] = extend true, {}, model
				backend.emit 'created', models[model.id]

	} 