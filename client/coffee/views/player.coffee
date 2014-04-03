define [
	'chaplin'
	'views/base/view'
	'helpers/format-duration'
	'hbs!templates/player'
], ({mediator}, View, formatDuration, tmpl) ->

	class PlayerView extends View

		template: tmpl
		autoRender: true
		autoAttach: true
		container: "#player"

		playtime: 0
		initialize: () ->
			super
			@listenTo @model, 'change', @updatePlayer
			@delegate 'click', '.play', @play
			@delegate 'click', '.pause', @pause
			@delegate 'click', '#volume .progress_container', @volumeChangeHandler
			mediator.setHandler 'volume', @volumeHandler

		volumeHandler: (vol) ->
			if vol
				@setVolume vol
				mediator.socket.emit('player:volume', volume)
			else
				return vol

		volumeChangeHandler: (e) ->
			bg = $('#volume .progress_background')
			offset = bg.offset()
			value = e.pageX - offset.left
			volume = value/bg.width() * 100
			@setVolume volume
			mediator.socket.emit('player:volume', volume)

		setVolume: (volume) ->
			@$('#volume .progress_bar').css('width', volume + '%')


		play: (update = yes) ->
			if update
				@model.save {playing: yes}, silent: true, success: () =>
					@updatePlayer()
			@$('.play').hide()
			@$('.pause').show()

		pause: (update = yes) ->
			if update
				@model.save {playing: no}, silent: true
			@$('.play').show()
			@$('.pause').hide()

		setDuration: () ->
			cur = formatDuration @model.get('playtime') * 1000
			total = formatDuration @model.get('track').duration
			progress = (@model.get('playtime')*1000) / @model.get('track').duration
			progress = Math.ceil(progress * 100)
			progress = 100 if progress > 100
			@$('#play-progress .progress_bar').css('width', progress + '%')
			@$('#current_duration').text "#{cur} / #{total}"

		updatePlayer: () ->
			if @model.get('playing')
				@play(false)
			else if not @model.get('playing')
				@pause(false)
				return @$('#currently_playing').text "Paused"
			title = @model.get('track').title
			artist = @model.get('track').artist
			user = @model.get('track').user
			volume = @model.get('volume')
			@setVolume volume if volume?
			@$('#currently_playing').text "#{artist} - #{title} (for #{user})"
			@setDuration()
