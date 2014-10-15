###
# utils/url_encode 的测试类
###

should = require 'should'
debug = require('debug')('gama-search::tests::url_encode_test')
urlEncode = require '../utils/url_encode'

###
action=push&Version=v2&AccessKeyId=$accessKeyId&Signature=$signature&
    SignatureMethod=HMAC-SHA1&Timestamp=$timestamp&SignatureVersion=1.0&
        SignatureNonce=$signatureNonce&
            items=[{"cmd": "ADD",
                "fields":{
                    "id":"8dac2812baa0b2",
                        "title":"这里是一个标题",
                            "body":"这里是文档的详细内容"}}]"
###

params =
  action:'push'
  Version:'v2'
  AccessKeyId:''
  SignatureMethod:'HMAC-SHA1'
  SignatureVersion:'1.0'
  items : '[{"cmd": "ADD",
    "fields":{
      "id":"8dac2812baa0b2",
      "title":"这里是一个标题",
    "body":"这里是文档的详细内容"}}]'

describe "url_encode test", ->

  before () ->
    #TODO before

  describe "tests", ->

    it 'encode test', (done) ->
      encode = urlEncode.encode '"console'
      console.log "encode:#{encode}"
      done()

    it 'query2string test', (done) ->
      str = urlEncode.query2string(params)
      console.log "str:#{str}"
      done()

