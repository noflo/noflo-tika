noflo = require 'noflo'
chai = require 'chai' unless chai
path = require 'path'
ToHtml = require '../components/ToHtml.coffee'

describe 'ToHtml component', ->
  c = null
  ins = null
  out = null
  beforeEach ->
    c = ToHtml.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'converting Word documents', ->
    it 'should produce HTML for simple file', (done) ->
      out.on 'data', (data) ->
        console.log data
        done()
      ins.send path.resolve __dirname, 'fixtures/file.doc'
    it 'should produce HTML for file with images', (done) ->
      @timeout 10000
      out.on 'data', (data) ->
        console.log data
        done()
      ins.send path.resolve __dirname, 'fixtures/trm-design-project-murphy.docx'
