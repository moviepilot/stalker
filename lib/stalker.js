var ObjectCompare, Stalker, rest, _;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
_ = require('../vendor/underscore-min');
rest = require('../vendor/restler');
ObjectCompare = require('./object_compare').ObjectCompare;
Stalker = (function() {
  function Stalker(host, tests, cb) {
    this.host = host;
    this.tests = tests;
    this.cb = cb;
    this.current = 0;
    this.errors = false;
  }
  Stalker.prototype.run = function() {
    return this.next();
  };
  Stalker.prototype.next = function(summary) {
    var t;
    if (summary == null) {
      summary = false;
    }
    if (summary) {
      this.cb(summary);
    }
    if ((summary != null) && summary.success === false) {
      this.errors = true;
    }
    if (!(t = this.tests[this.current])) {
      return this.exit();
    }
    this.current++;
    return this.probe(t);
  };
  Stalker.prototype.exit = function() {
    var status;
    status = this.errors ? 1 : 0;
    return process.exit(status);
  };
  Stalker.prototype.probe = function(def, cb) {
    var options, uri;
    if (cb == null) {
      cb = false;
    }
    uri = this.host + def.uri;
    options = {
      method: def.method,
      data: JSON.stringify(def.request)
    };
    return rest.request(uri, options).on('complete', __bind(function(data, response) {
      return this.check_response(data, response, def, cb);
    }, this)).on('error', __bind(function(data, response) {
      return this.check_response(data, response, def, cb);
    }, this));
  };
  Stalker.prototype.check_response = function(data, response, def, cb) {
    var summary;
    summary = {
      success: true,
      test: def.uri,
      errors: {}
    };
    this.check_status(summary, response, def);
    this.check_object(summary, data, def);
    if (cb) {
      return cb(summary);
    } else {
      return this.next(summary);
    }
  };
  Stalker.prototype.check_object = function(summary, data, def) {
    var actual, diffs, expected;
    if (def.response.body == null) {
      return true;
    }
    actual = JSON.parse(def.response.body);
    try {
      expected = JSON.parse(data);
      diffs = ObjectCompare.diff(actual, expected);
      if (_.isEmpty(diffs)) {
        return;
      }
      summary.success = false;
      summary.errors.body = diffs;
      return false;
    } catch (e) {
      summary.success = false;
      summary.errors.body = {
        "invalid_syntax": e
      };
      return false;
    }
  };
  Stalker.prototype.check_status = function(summary, response, def) {
    var actual, expected;
    expected = parseInt(def.response_code);
    actual = response.statusCode;
    if (expected === actual) {
      return true;
    }
    summary.errors.status = {
      expected: expected,
      actual: actual || null
    };
    summary.success = false;
    return false;
  };
  return Stalker;
})();
exports.Stalker = Stalker;