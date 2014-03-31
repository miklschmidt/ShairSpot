define [
	'views/base/view'
	'hbs!templates/song-list-entry'
], (View, tmpl) ->

	class SongListEntryView extends View

		tagName: 'tr'
		template: tmpl

		initialize: () ->
			@listenTo @model, 'change', @render