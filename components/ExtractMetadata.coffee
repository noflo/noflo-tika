noflo = require 'noflo'
{spawn} = require "child_process"
path = require 'path'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Extract HTML content from a document'
  c.tikaPath = path.resolve __dirname, '../jar/tika-app.jar'

  c.inPorts.add 'in',
    description: 'Source file path'
    datatype: 'string'
  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'in'
    out: 'out'
    async: true
    forwardGroups: true
  , (filePath, groups, out, callback) ->
    tika = spawn "java", [
      "-jar"
      c.tikaPath
      "-j"
      filePath
    ]
    tika.stdout.setEncoding 'utf-8'
    error = ''
    out.beginGroup filePath
    tika.stdout.on 'data', (data) ->
      try
        out.send JSON.parse data
      catch e
        callback e
    tika.stderr.on "data", (data) ->
      error += data
    tika.on 'exit', (code) ->
      if code > 0
        callback new Error error
        return
      out.endGroup()
      do callback

  c
