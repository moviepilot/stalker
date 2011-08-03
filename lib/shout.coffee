sys           = require('sys')
exec          = require('child_process').exec

Shout =
  green: (name) ->
   exec "shout -d '&nbsp;' --group stalker --expires-in 300 green '#{name}' '#{name}'"
  red: (name, msg) ->
    exec "shout -d '&nbsp;' --group stalker red '#{name}' '#{name}: #{JSON.stringify(msg)}'"
  report: (host, summary) ->
    if summary.success
      Shout.green "#{host}_#{summary.test}"
    else
      Shout.red "#{host}_#{summary.test}", summary.errors


exports.Shout = Shout
