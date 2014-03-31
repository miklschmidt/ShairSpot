util = require 'util'
os = require 'os'
exec = require('child_process').exec

module.exports = {
	findDevices: (callback) ->
		console.error 'mdns browser only works on osx for now' if os.platform() isnt 'darwin'
		mdnsbin = if os.release() < '12' then 'mDNS' else 'dns-sd'
		exec "#{mdnsbin} -B _raop._tcp", {timeout: 1000}, (err, stdout) ->
			devices = []
			n = 0
			done = () ->
				callback null, devices
			lines = stdout.split('\n')
			for line in lines
				do (line) ->
					result = /_raop\._tcp\.\s+([^@]+)@(.*)/.exec line
					# return callback new Error('no devices') unless result
					return unless result
					n++
					device = mac: result[1], name: result[2]

					cmd = "#{mdnsbin} -L \"#{device.mac}@#{device.name}\" _raop._tcp local"
					exec cmd, {timeout: 1000}, (err, stdout) ->

						result = /can be reached at\s+(\S*)\s*:(\d+)/.exec stdout
						if result
							device.host = result[1]
							device.port = result[2]
							devices.push device
						--n or done()
}