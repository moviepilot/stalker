VarParser =

  parse: (lines, start, stopword) ->
    @lines = lines
    @current = null
    @data = {}
    @i = start
    @stop = stopword
    ret = @parseLine()
    ret

  parseLine: ->
    if @stop and @lines[@i].substr(0, @stop.length).toLowerCase() == @stop.toLowerCase()
      return [ @i - 1, @data ]
    else if match = @lines[@i].match(/^([\w]+)\: *(.*)$/)
      @parseSectionHeader match
    else if match = @lines[@i].match(/^    (.*)$/)
      @parseSample match
    else if match = @lines[@i].match(/^[ ]+([\w-]+)\: *([^ ]?.*)$/)
      @parseValue match
    else

    @advance()

  parseSectionHeader: (match) ->
    @current = match[1].toLowerCase()

  parseValue: (match) ->
    @data[@current] = @data[@current] or {}
    @data[@current][match[1]] = match[2]

  parseSample: (match) ->
    @data[@current] = @data[@current] or ""
    @data[@current] += match[1] + "\n"

  advance: ->
    @i++
    if @lines.length > @i
      @parseLine()
    else
      @result()

  result: ->
    [ @i, @data ]

exports.VarParser = VarParser
