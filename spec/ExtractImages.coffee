noflo = require 'noflo'
chai = require 'chai' unless chai
path = require 'path'
Extract = require '../components/ExtractImages.coffee'
temp = require 'temp'
fs = require 'fs'

describe 'ExtractImages component', ->
  c = null
  ins = null
  dir = null
  out = null
  nothing = null
  beforeEach ->
    c = Extract.getComponent()
    ins = noflo.internalSocket.createSocket()
    dir = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    nothing = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.inPorts.dir.attach dir
    c.outPorts.out.attach out
    c.outPorts.nothing.attach nothing

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'extracting images from Word documents', ->
    it 'shouldn\'t find images for a simple file', (done) ->
      temp.mkdir 'file', (err, tempPath) ->
        out.on 'data', (data) ->
          chai.expect(true).to.equal false
        nothing.on 'data', () ->
          chai.expect(true).to.equal true
          done()
        dir.send tempPath
        ins.send path.resolve __dirname, 'fixtures/file.doc'
        ins.disconnect()
    it 'should find images from file', (done) ->
      @timeout 10000
      temp.mkdir 'murphy', (err, tempPath) ->
        files = []
        out.on 'data', (data) ->
          files.push data
        nothing.on 'data', (data) ->
          chai.expect(true).to.equal false
        out.on 'disconnect', ->
          chai.expect(files.length).to.be.above 5
          for f in files
            chai.expect(fs.existsSync(f)).to.equal true
          done()
        dir.send tempPath
        ins.send path.resolve __dirname, 'fixtures/trm-design-project-murphy.docx'
        ins.disconnect()
