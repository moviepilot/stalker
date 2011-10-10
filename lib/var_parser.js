var VarParser;
VarParser = {
  parse: function(lines, start, stopword) {
    var ret;
    this.lines = lines;
    this.current = null;
    this.data = {};
    this.i = start;
    this.stop = stopword;
    ret = this.parseLine();
    return ret;
  },
  parseLine: function() {
    var match;
    if (this.stop && this.lines[this.i].substr(0, this.stop.length).toLowerCase() === this.stop.toLowerCase()) {
      return [this.i - 1, this.data];
    } else if (match = this.lines[this.i].match(/^([\w]+)\: *(.*)$/)) {
      this.parseSectionHeader(match);
    } else if (match = this.lines[this.i].match(/^    (.*)$/)) {
      this.parseSample(match);
    } else if (match = this.lines[this.i].match(/^[ ]+([\w-]+)\: *([^ ]?.*)$/)) {
      this.parseValue(match);
    } else {

    }
    return this.advance();
  },
  parseSectionHeader: function(match) {
    return this.current = match[1].toLowerCase();
  },
  parseValue: function(match) {
    this.data[this.current] = this.data[this.current] || {};
    return this.data[this.current][match[1]] = match[2];
  },
  parseSample: function(match) {
    this.data[this.current] = this.data[this.current] || "";
    return this.data[this.current] += match[1] + "\n";
  },
  advance: function() {
    this.i++;
    if (this.lines.length > this.i) {
      return this.parseLine();
    } else {
      return this.result();
    }
  },
  result: function() {
    return [this.i, this.data];
  }
};
exports.VarParser = VarParser;