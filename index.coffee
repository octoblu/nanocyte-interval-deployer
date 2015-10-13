_      = require 'lodash'
Runner = require './runner'
debug  = require('debug')('nanocyte-mass-runner:index')

runner = new Runner
runner.run =>
#
# runAndRun = =>
#   debug 'running now'
#   callback = =>
#     randomNumber = Math.round(Math.random() * 100)
#     debug "running again in #{randomNumber}"
#     _.delay runner.run, randomNumber, callback
#   runner.run callback
#
# _.times 1, runAndRun
