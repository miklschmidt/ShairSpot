gulp   = require 'gulp'
coffee = require 'gulp-coffee'
less = require 'gulp-less'
path   = require 'path'
mocha  = require 'gulp-mocha'

######################
# ASSETS COMPILATION
######################

CLIENT_LESSFILES = [
	'./client/less/app.less'
]

gulp.task 'client-less', ->
	gulp.src CLIENT_LESSFILES
	.pipe less()
	.pipe gulp.dest './public/css'

gulp.task 'client-coffee', ->
	gulp.src './client/coffee/*.coffee'
	.pipe coffee()
	.pipe gulp.dest './public/js'

gulp.task 'client-move', ->
	gulp.src ['./client/*.*', './client/!(coffee|less)/**/*']
	.pipe gulp.dest './public'

gulp.task 'server-coffee', ->
	gulp.src './src/**/*.coffee'
	.pipe coffee()
	.pipe gulp.dest './lib'

gulp.task 'server-coffee-move', ->
	gulp.src './src/*.js'
	.pipe gulp.dest './lib'

gulp.task 'compile-server', ['server-coffee', 'server-coffee-move'], ->

gulp.task 'compile-client', [
	'client-less',
	'client-coffee',
	'client-move'
], ->

gulp.task 'compile', ['compile-server', 'compile-client'], ->


######################
# MAIN TASKS
######################

gulp.task 'run', ['compile'], ->
	require './index.js'

gulp.task 'test', ['compile'], ->
	gulp.src './test/setup.coffee'
	.pipe mocha reporter: 'spec'

gulp.task 'prepublish', ['compile'], ->