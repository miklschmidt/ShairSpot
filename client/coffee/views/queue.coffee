define [
	'views/base/collection-view'
	'views/song-list-entry'
	'hbs!templates/queue'
], (CollectionView, SongListEntryView, tmpl) ->

	class QueueView extends CollectionView

		listSelector: "#queue-song-list"
		itemView: SongListEntryView
		template: tmpl

		initialize: () ->
			super
			@delegate "drop", "#drop_area", (e) ->
				e.preventDefault()
				e.stopPropagation()
				for item in e.originalEvent.dataTransfer.items
					item.getAsString (string) =>
						if string.indexOf('spotify:track') isnt -1
							@collection.create {uri: string}
				
				$("#drop_area").text("Spotify drag 'n droperino area")

			@delegate "dragover", "#drop_area", (e) ->
				e.preventDefault()
				$("#drop_area").text("Add to queue")

			@delegate "dragleave", "#drop_area", (e) ->
				$("#drop_area").text("Spotify drag 'n droperino area")