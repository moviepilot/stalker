_             = require '../vendor/underscore-min'
rest          = require '../vendor/restler'
ObjectCompare = require('./object_compare').ObjectCompare

class Stalker
  constructor: (@host) ->

  probe: (def, cb) ->
    uri = @host+def.uri
    options = 
      method: def.method
      data:   JSON.stringify(def.request)
    rest.request(uri, options).on('complete', (data, response) =>
      @check_response data, response, def, cb
    ).on('error', (data, response) =>
      @check_response data, response, def, cb
    )

  check_response: (data, response, def, cb) ->
    summary = {success: true, test: def.uri, errors: {}}
    @check_status summary, response, def
    @check_object summary, data, def

    cb summary

  check_object: (summary, data, def) ->
    return true unless def.response.body?
    actual = JSON.parse(def.response.body)
    try
      expected = JSON.parse data
      diffs = ObjectCompare.diff(actual, expected)
      return if _.isEmpty(diffs)
      summary.success = false
      summary.errors.body = diffs
      false
    catch e
      summary.success = false
      summary.errors.body = {"invalid_syntax" : e}
      false

  check_status: (summary, response, def) ->
    expected = parseInt(def.response_code)
    actual   = response.statusCode
    return true if expected == actual
    summary.errors.status = {expected: expected, actual: actual || null}
    summary.success = false
    false

exports.Stalker = Stalker
