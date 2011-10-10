var Shout, exec, sys;
sys = require('sys');
exec = require('child_process').exec;
Shout = {
  green: function(name) {
    return exec("shout -d '&nbsp;' --group stalker --expires-in 300 green '" + name + "' '" + name + "'");
  },
  red: function(name, msg) {
    return exec("shout -d '&nbsp;' --group stalker red '" + name + "' '" + name + ": " + (JSON.stringify(msg)) + "'");
  },
  report: function(host, summary) {
    if (summary.success) {
      return Shout.green("" + host + "_" + summary.test);
    } else {
      return Shout.red("" + host + "_" + summary.test, summary.errors);
    }
  }
};
exports.Shout = Shout;