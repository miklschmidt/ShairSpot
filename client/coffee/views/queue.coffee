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
					if item.type is 'text/uri-list'
						item.getAsString (string) =>
							if string.indexOf('\n') isnt -1
								# Collection of uris
								uris = string.split('\n')
								for uri in uris
									uri = uri.replace('\r', '').replace('\n', '')
									console.log uri
									@parseSpotifyUri uri
							else
								@parseSpotifyUri string
				
				$("#drop_area").text("Spotify drag 'n dropperino area")

			@delegate "dragover", "#drop_area", (e) ->
				e.preventDefault()
				$("#drop_area").text("Add to queue")

			@delegate "dragleave", "#drop_area", (e) ->
				$("#drop_area").text("Spotify drag 'n dropperino area")

		parseSpotifyUri: (string) ->
			if string.indexOf('http://open.spotify.com/track/') isnt -1
				uri = 'spotify:track:' + string.replace('http://open.spotify.com/track/', '')
				more = uri.indexOf('http://open.spotify.com/track/')
				if more > -1
					realuri = uri.substring(0,more)
					rest = uri.replace(realuri, '')
					@parseSpotifyUri rest
					uri = realuri
				console.log 'adding', uri
				@collection.create {uri}, {wait: true}
			else if string.indexOf('spotify:track') isnt -1
				console.log 'adding', string
				@collection.create {uri: string}, {wait: true}