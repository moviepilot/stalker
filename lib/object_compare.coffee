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
      if (haystack instanceof Array and needle instanceof Array)
        found = false
        _.each haystack, (he) ->
          v = if val instanceof Object then val else {test: val}
          h = if he  instanceof Object then he  else {test: he }
          arr_diff = ObjectCompare.contained_in(v, h)
          # console.log "#{JSON.stringify(v)} IN #{JSON.stringify(h)} #{arr_diff.length == 0}"
          found = true if  arr_diff.length == 0
        return if found
        diffs.push ObjectCompare.diff_obj(history, key, val, expected)
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

# needle = {
#   "int": 1
#   "obj": {
#     "obj->int" : 2
#     "obj->string" : "obj->foo"
#     }
#   "string": "foo"
#   "array" : [{"1":1}, {"2":2}]
#   }
# 
# unordered_needle = {
#   "int": 1
#   "obj": {
#     "obj->int" : 2
#     "obj->string" : "obj->foo"
#     }
#   "string": "foo"
#   "array" : [{"2":2}, {"1":1}]
#   }
# 
# haystack = {
#   "int": 1
#   "extra-int": 3
#   "obj": {
#     "obj->int" : 2
#     "obj->extra-int" : 4
#     "obj->string" : "obj->foo"
#     }
#   "string": "foo"
#   "array" : [{"1":1}, {"2":2}]
#   }
# 
# broken_needle = {
#   "int": 1
#   "obj": {
#     "obj->int" : 2
#     "obj->string" : "obj->foox"
#     }
#   "string": "foo"
#   "array" : [{"1":1}, {"2": 2}]
#   }
# 
# broken_array_needle = {
#   "int": 1
#   "obj": {
#     "obj->int" : 2
#     "obj->string" : "obj->foox"
#     }
#   "string": "foo"
#   "array" : [{"1":1}, {"2": 3}]
#   }
# 
# console.log("needle, haystack")
# x = (ObjectCompare.diff(needle, haystack))
# console.log x unless _.keys(x).length == 0
# 
# console.log("broken_needle, haystack")
# x = (ObjectCompare.diff(broken_needle, haystack))
# console.log x if _.keys(x).length == 0
# 
# console.log("broken_array_needle, haystack")
# x = (ObjectCompare.diff(broken_array_needle, haystack))
# console.log x if _.keys(x).length == 0
# 
# console.log("haystack, needle")
# x = (ObjectCompare.diff(haystack, needle))
# console.log x if _.keys(x).length == 0
# 
# console.log("needle, needle")
# x = (ObjectCompare.diff(needle, needle))
# console.log x unless _.keys(x).length == 0
# 
# console.log("needle, unordered_needle")
# x = (ObjectCompare.diff(needle, unordered_needle))
# console.log x unless _.keys(x).length == 0
