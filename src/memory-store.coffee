extend = require 'node.extend'

module.exports = (backend) ->
	models = data
	id = 0
	return {
		models: {}
		id: 0
		middleware: (req, res, next) =>
			crud =
				create: () ->
					model = req.model
					model.id = @id++
					@models[model.id] = model
					res.end(model)

				read: () ->
					if req.model.id
						res.end model[req.model.id]
					else
						res.end extend true, {}, @models
				
				update: () ->
					extend true, @models[req.model.id], req.model
					res.end @models[req.model.id]

				delete: () ->
					delete @models[req.model.id]
					res.end req.model

			return next new Error("Unsupported method #{req.method}") unless crud[req.method]?
			crud[req.method]()

		getModel: (id) =>
			return @models[id]

		setStore: (data) =>
			for model, index in @models
				backend.emit 'deleted', model
				delete models[index]
			@id = 0
			for model in data
				model.id = @id++
				@models[model.id] = extend true, {}, model
				backend.emit 'created', @models[model.id]

	} 