_ = require 'lodash'
url = require 'url'
debug = require('debug')('nanocyte-mass-runner:flow-master')
request = require 'request'
MeshbluHttp = require 'meshblu-http'

class FlowMaster
  constructor: (options={}) ->
    {@uuid, @token, @octobluServer, @octobluPort, @meshbluServer, @meshbluPort, @nanocytePort, @nanocyteServer, @templateUuid} = options
    @protocol = if @octobluPort == 143 then 'https' else 'http'
    @octobluUrl = url.format hostname: @octobluServer, port: @octobluPort, protocol: @protocol
    @protocol = if @nanocytePort == 143 then 'https' else 'http'
    @nanocyteUrl = url.format hostname: @nanocyteServer, port: @nanocytePort, protocol: @protocol
    @meshbluHttp = new MeshbluHttp uuid: @uuid, token: @token, server: @meshbluServer, port: @meshbluPort

  request: (url, method, callback=->) =>
    requestOptions =
      url: url
      method: method
      json: true
      auth:
        username: @uuid
        password: @token
    request requestOptions, (error, response, body) =>
      return callback error if error?
      callback null, body

  import: (callback=->)=>
    debug 'importing flow'
    @request "#{@octobluUrl}/api/templates/#{@templateUuid}/flows", "POST", callback

  updateDevice: (flowId, triggerServiceUuid, callback=->) =>
    @meshbluHttp.updateDangerously flowId, $set: { sendWhitelist: [triggerServiceUuid] }, callback

  getFlows: (callback=->) =>
    debug 'getting all flows'
    @request "#{@octobluUrl}/api/flows", 'GET', callback

  deploy: (flowId, callback=->)=>
    debug 'deploying'
    @request "#{@nanocyteUrl}/flows/#{flowId}/instances", 'POST', callback

module.exports = FlowMaster
