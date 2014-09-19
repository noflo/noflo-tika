noflo = require 'noflo'
chai = require 'chai' unless chai
path = require 'path'
ToHtml = require '../components/ToHtml.coffee'

describe 'ToHtml component', ->
  c = null
  ins = null
  out = null
  error = null
  beforeEach ->
    c = ToHtml.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out
    c.outPorts.error.attach error

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'converting Word documents', ->
    it 'should produce HTML for simple file', (done) ->
      error.on 'data', (err) ->
        console.log err
        done()
      out.on 'data', (data) ->
        #console.log data
        done()
      ins.send path.resolve __dirname, 'fixtures/file.doc'
    it 'should produce HTML for file with images', (done) ->
      @timeout 10000
      error.on 'data', (err) ->
        console.log err
        done()
      out.on 'data', (data) ->
        #console.log data
        done()
      ins.send path.resolve __dirname, 'fixtures/trm-design-project-murphy.docx'
