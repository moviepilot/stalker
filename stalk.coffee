_             = require './vendor/underscore-min'
Shout         = require('./lib/shout').Shout
Stalker       = require('./lib/stalker').Stalker
ExampleParser = require('./lib/example_parser').ExampleParser

if process.argv.length < 3
  console.log "Usage: node stalk.js [-v] hostname definition.txt"
  console.log " e.g. node stalk.js -v http://production.host search_queries.txt"
  process.exit 1

filename = _.last(process.argv)
host     = _.first(_.rest(process.argv, -2))
verbose  = _.include(process.argv, "-v")

tests = ExampleParser.parseFile filename

report = (summary) ->
  result = if summary.success == true then "✔" else "errors: "+JSON.stringify(summary.errors)
  console.log "#{summary.test}: #{result}"
  Shout.report host, summary
  true

stalker = new Stalker(host)
_.map tests, (definition) ->
  stalker.probe definition, report

if verbose
  _.map tests, (d) ->
    console.log d
    console.log "-----------------------------------------------\n"
