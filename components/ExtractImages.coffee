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
  c.outPorts.add 'nothing',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'in'
    params: 'dir'
    out: ['out', 'nothing']
    async: true
    forwardGroups: true
  , (filePath, groups, outports, callback) ->
    tika = spawn 'java', [
      '-jar'
      c.tikaPath
      '-z'
      "--extract-dir=#{c.params.dir}"
      filePath
    ]
    out = outports.out
    nothing = outports.nothing

    out.beginGroup filePath
    tika.stdout.setEncoding 'utf-8'
    error = ''
    files = []
    tika.stdout.on 'data', (data) ->
      match = data.match /Extracting\s\'(.*)\'.*/
      return unless match
      files = match[1]
      for file in files.split '\n'
        resolved = path.resolve c.params.dir, file
        out.send resolved
    tika.stderr.on "data", (data) ->
      error += data
    tika.on 'exit', (code) ->
      if code > 0
        callback new Error error
        return
      else
        nothing.send null unless files.length
      out.endGroup()
      do callback

  c
