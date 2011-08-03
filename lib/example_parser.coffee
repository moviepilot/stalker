fs            = require 'fs'
_             = require '../vendor/underscore-min'
VarParser     = require('./var_parser').VarParser

class ExampleParser

  parse: (lines) ->
    @lines = lines
    @i = 0
    @data =
      request: {}
      response: {}
      description: ""

    @current = null
    parsed = @parseLine()
    parsed

  parseLine: ->
    if match = @lines[@i].match(/^##?[ ]*(.*)/)
      @data.description += match[1] + "\n"
    else if match = @lines[@i].match(/^([A-Z]{3,6})([:]?[ ]+)(.*)$/)
      @parseMethod match
    else if match = @lines[@i].match(/^Response:[ ]?(.*)$/)
      @switchMode match
    else @parseVars()  if @current
    @advance()

  parseMethod: (match) ->
    @data.method = match[1]
    @data.uri = match[3]
    @current = "request"

  switchMode: (match) ->
    @current = "response"
    @data["response_code"] = match[1]

  parseVars: ->
    stop = (if @current == "request" then "Response" else null)
    vars = VarParser.parse(@lines, @i, stop)
    @i = vars[0]++
    @data[@current] = vars[1]

  advance: ->
    @i++
    if @lines.length > @i
      @parseLine()
    else
      @result()

  result: ->
    @data

ExampleParser.parseFile = (fileName) ->
  data = fs.readFileSync(fileName, 'utf8')
  p = new ExampleParser()
  _.map data.split("\n##"), (example) ->
    p.parse(example.split("\n"))


exports.ExampleParser = ExampleParser
