var ObjectCompare, _;
_ = require('../vendor/underscore-min');
ObjectCompare = {
  diff: function(needle, haystack) {
    var diff, diffs;
    diff = ObjectCompare.contained_in(needle, haystack);
    diffs = {};
    _.each(diff, function(d) {
      var joined_key;
      joined_key = _.union(d.path, [d.key]).join('][');
      return diffs["[" + joined_key + "]"] = {
        expected: d.expected,
        actual: d.actual
      };
    });
    return diffs;
  },
  contained_in: function(needle, haystack, history) {
    var diffs;
    if (history == null) {
      history = [];
    }
    diffs = [];
    _.each(needle, function(val, key) {
      var expected, found, new_hist;
      expected = haystack != null ? haystack[key] : void 0;
      if (val === expected) {
        return;
      }
      if (haystack instanceof Array && needle instanceof Array) {
        found = false;
        _.each(haystack, function(he) {
          var arr_diff, h, v;
          v = val instanceof Object ? val : {
            test: val
          };
          h = he instanceof Object ? he : {
            test: he
          };
          arr_diff = ObjectCompare.contained_in(v, h);
          if (arr_diff.length === 0) {
            return found = true;
          }
        });
        if (found) {
          return;
        }
        return diffs.push(ObjectCompare.diff_obj(history, key, val, expected));
      } else if (val instanceof Object) {
        new_hist = _.union(history, [key]);
        return diffs.push(ObjectCompare.contained_in(val, expected, new_hist));
      } else {
        return diffs.push(ObjectCompare.diff_obj(history, key, val, expected));
      }
    });
    return _.flatten(diffs);
  },
  diff_obj: function(history, key, expected, actual) {
    return {
      path: history,
      key: key,
      expected: expected,
      actual: actual || null
    };
  }
};
exports.ObjectCompare = ObjectCompare;