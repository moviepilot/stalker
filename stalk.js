var ExampleParser, Shout, Stalker, filename, host, report, stalker, success, tests, verbose, _;
_ = require('./vendor/underscore-min');
Shout = require('./lib/shout').Shout;
Stalker = require('./lib/stalker').Stalker;
ExampleParser = require('./lib/example_parser').ExampleParser;
if (process.argv.length < 3) {
  console.log("Usage: node stalk.js [-v] hostname definition.txt");
  console.log(" e.g. node stalk.js -v http://production.host search_queries.txt");
  process.exit(1);
}
filename = _.last(process.argv);
host = _.first(_.rest(process.argv, -2));
verbose = _.include(process.argv, "-v");
tests = ExampleParser.parseFile(filename);
success = true;
report = function(summary) {
  var errors, result;
  result = summary.success === true ? "✔" : "✗";
  errors = summary.success === true ? "" : " errors " + JSON.stringify(summary.errors);
  console.log("" + result + " " + summary.test + errors);
  success = success && summary.success;
  Shout.report(host, summary);
  return true;
};
stalker = new Stalker(host, tests, report);
stalker.run();
if (verbose) {
  _.map(tests, function(d) {
    console.log(d);
    return console.log("-----------------------------------------------\n");
  });
}