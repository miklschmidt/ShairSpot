define ['vendor/requirejs-hbs/hbs/handlebars'], (Handlebars) ->

	strPad = (string, pad) ->
		string = string + ''
		while (string.length < pad)
			string = '0' + string
		return string

	formatDuration = (ms) ->
		seconds = ms/1000
		sign = ""
		if not seconds? or isNaN(seconds)
			return '00:00'
		if seconds < 0
			seconds *= -1
			sign = "-"
		duration = new Date();
		duration.setHours 0
		duration.setMinutes 0
		duration.setSeconds seconds

		hours = strPad(Math.floor(seconds/60/60), 2)
		mins = strPad(duration.getMinutes(), 2)
		secs = strPad(duration.getSeconds(), 2)

		return sign + mins + ':' + secs

	Handlebars.registerHelper 'format-duration', (ms) ->
		return formatDuration ms

	return formatDuration
	