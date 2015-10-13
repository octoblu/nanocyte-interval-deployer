FlowMaster    = require './flow-master'
MeshbluConfig = require 'meshblu-config'
debug         = require('debug')('nanocyte-mass-runner:runner')

class Runner
  constructor: ->
    meshbluConfig = new MeshbluConfig
    meshbluConfigJSON = meshbluConfig.toJSON()

    @options =
      uuid: meshbluConfigJSON.uuid
      token: meshbluConfigJSON.token
      meshbluServer: meshbluConfigJSON.server
      meshbluPort: meshbluConfigJSON.port
      octobluServer: process.env.OCTOBLU_SERVER
      octobluPort: process.env.OCTOBLU_PORT
      nanocyteServer: process.env.NANOCYTE_SERVER
      nanocytePort: process.env.NANOCYTE_PORT
      templateUuid: process.env.TEMPLATE_UUID
      intervalServiceUuid: process.env.INTERVAL_SERVICE_UUID
    debug 'options', @options

  deployAndClick: =>
    flowJSON = require './meshblu.json'
    flowId = flowJSON.uuid
    triggerId = flowJSON.triggerId
    master = new FlowMaster @options
    master.deploy flowId, (error) =>
      return console.error 'error deploying flow', error if error?
      setTimeout =>
        master.clickTrigger flowId, triggerId, (error, response) =>
          return console.error error if error?
          debug 'clicked trigger'
      , 1000

  clickAllTriggers: =>
    master = new FlowMaster @options
    master.clickAllTriggers()

  run: (callback=->)=>
    master = new FlowMaster @options
    master.import (error, flow) =>
      debug "tried to import flow", error, flow
      return console.error 'error importing flow', error if error?
      flowId = flow.flowId
      debug "imported flow"
      master.updateDevice flowId, @options.intervalServiceUuid, (error) =>
        debug "Imported device", error
        return console.error 'error updating the device', error if error?

        master.deploy flowId, (error) =>
          return console.error "Error deploying device", error if error?
          callback null

module.exports = Runner
