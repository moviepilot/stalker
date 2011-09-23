_ = require '../vendor/underscore-min'

ObjectCompare =

  diff: (needle, haystack) ->
    diff = ObjectCompare.contained_in(needle, haystack)
    diffs = {}
    _.each diff, (d) ->
      joined_key = _.union(d.path, [d.key]).join('][')
      diffs["[#{joined_key}]"] = {
        expected: d.expected,
        actual: d.actual
      }
    diffs

  contained_in: (needle, haystack, history = []) ->
    diffs = []
    _.each needle, (val, key) ->
      expected = if haystack? then haystack[key] else undefined
      return if val == expected
      if (haystack instanceof Array)
        _.each haystack, (he) ->
          arr_diff = ObjectCompare.contained_in(needle, he)
          return if arr_diff.length == 0
      else if (val instanceof Object)
        new_hist = _.union(history, [key])
        diffs.push ObjectCompare.contained_in(val, expected, new_hist)
      else
        diffs.push ObjectCompare.diff_obj(history, key, val, expected)
    _.flatten(diffs)

  diff_obj: (history, key, expected, actual) ->
    return {
      path:     history
      key:      key
      expected: expected
      actual:   actual || null}


exports.ObjectCompare = ObjectCompare

needle = {
  "int": 1
  "obj": {
    "obj->int" : 2
    "obj->string" : "obj->foo"
    }
  "string": "foo"
  "array" : [{"1":1}, {"2":2}]
  }

unordered_needle = {
  "int": 1
  "obj": {
    "obj->int" : 2
    "obj->string" : "obj->foo"
    }
  "string": "foo"
  "array" : [{"2":2}, {"1":1}]
  }

haystack = {
  "int": 1
  "extra-int": 3
  "obj": {
    "obj->int" : 2
    "obj->extra-int" : 4
    "obj->string" : "obj->foo"
    }
  "string": "foo"
  "array" : [{"1":1}, {"2":2}]
  }

broken_needle = {
  "int": 1
  "obj": {
    "obj->int" : 2
    "obj->string" : "obj->foox"
    }
  "string": "foo"
  "array" : [{"1":1}, {"2": 2}]
  }


console.log("needle,           haystack") if _.keys(ObjectCompare.diff(needle, haystack)).length          > 0
console.log("broken_needle,    haystack") if _.keys(ObjectCompare.diff(broken_needle, haystack)).length  == 0
console.log("haystack,         needle"  ) if _.keys(ObjectCompare.diff(haystack, needle)).length         == 0
console.log("needle,           needle"  ) if _.keys(ObjectCompare.diff(needle, needle)).length            > 0
console.log("needle, unordered_needle"  ) if _.keys(ObjectCompare.diff(needle, unordered_needle)).length  > 0
