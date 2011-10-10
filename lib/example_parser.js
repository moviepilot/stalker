var ExampleParser, VarParser, fs, _;
fs = require('fs');
_ = require('../vendor/underscore-min');
VarParser = require('./var_parser').VarParser;
ExampleParser = (function() {
  function ExampleParser() {}
  ExampleParser.prototype.parse = function(lines) {
    var parsed;
    this.lines = lines;
    this.i = 0;
    this.data = {
      request: {},
      response: {},
      description: ""
    };
    this.current = null;
    parsed = this.parseLine();
    return parsed;
  };
  ExampleParser.prototype.parseLine = function() {
    var match;
    if (match = this.lines[this.i].match(/^##?[ ]*(.*)/)) {
      this.data.description += match[1] + "\n";
    } else if (match = this.lines[this.i].match(/^([A-Z]{3,6})([:]?[ ]+)(.*)$/)) {
      this.parseMethod(match);
    } else if (match = this.lines[this.i].match(/^Response:[ ]?(.*)$/)) {
      this.switchMode(match);
    } else {
      if (this.current) {
        this.parseVars();
      }
    }
    return this.advance();
  };
  ExampleParser.prototype.parseMethod = function(match) {
    this.data.method = match[1];
    this.data.uri = match[3];
    return this.current = "request";
  };
  ExampleParser.prototype.switchMode = function(match) {
    this.current = "response";
    return this.data["response_code"] = match[1];
  };
  ExampleParser.prototype.parseVars = function() {
    var stop, vars;
    stop = (this.current === "request" ? "Response" : null);
    vars = VarParser.parse(this.lines, this.i, stop);
    this.i = vars[0]++;
    return this.data[this.current] = vars[1];
  };
  ExampleParser.prototype.advance = function() {
    this.i++;
    if (this.lines.length > this.i) {
      return this.parseLine();
    } else {
      return this.result();
    }
  };
  ExampleParser.prototype.result = function() {
    return this.data;
  };
  return ExampleParser;
})();
ExampleParser.parseFile = function(fileName) {
  var data, p;
  data = fs.readFileSync(fileName, 'utf8');
  p = new ExampleParser();
  return _.map(data.split("\n##"), function(example) {
    return p.parse(example.split("\n"));
  });
};
exports.ExampleParser = ExampleParser;