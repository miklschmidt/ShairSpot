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
			@listenTo @model, 'change', @updateTrack
			@delegate 'click', '.play', @play
			@delegate 'click', '.pause', @pause

		play: (update = yes) ->
			if update
				@model.save {playing: yes}, silent: true, success: () =>
					@updateTrack()
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
			progress *= 100
			progress = 100 if progress > 100
			@$('#progress_bar').css('width', progress + '%')
			@$('#current_duration').text "#{cur} / #{total}"

		updateTrack: () ->
			if @model.get('playing')
				@play(false)
			else if not @model.get('playing')
				@pause(false)
				return @$('#currently_playing').text "Paused"
			title = @model.get('track').title
			artist = @model.get('track').artist
			user = @model.get('track').user
			@$('#currently_playing').text "#{artist} - #{title} (for #{user})"
			@setDuration()
