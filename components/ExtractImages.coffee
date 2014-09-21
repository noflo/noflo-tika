noflo = require 'noflo'
{spawn} = require "child_process"
path = require 'path'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Extract images from a document'
  c.tikaPath = path.resolve __dirname, '../jar/tika-app-1.6.jar'

  c.inPorts.add 'in',
    description: 'Source file path'
    datatype: 'string'
    required: yes
  c.inPorts.add 'dir',
    description: 'Directory for extracted images'
    required: yes
  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'in'
    params: 'dir'
    out: 'out'
    async: true
    forwardGroups: true
  , (filePath, groups, out, callback) ->
    tika = spawn 'java', [
      '-jar'
      c.tikaPath
      '-z'
      "--extract-dir=#{c.params.dir}"
      filePath
    ]
    out.beginGroup filePath
    tika.stdout.setEncoding 'utf-8'
    error = ''
    tika.stdout.on 'data', (data) ->
      match = data.match /Extracting\s\'(.*)\'.*/
      return unless match
      out.send match[1]
    tika.stderr.on "data", (data) ->
      error += data
    tika.on 'exit', (code) ->
      if code > 0
        callback new Error error
        return
      out.endGroup()
      do callback

  c
