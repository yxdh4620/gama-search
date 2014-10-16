###
# utils/crypto_util 的测试类
###

should = require 'should'
debug = require('debug')('gama-search::tests::crypto_util_test')
cryptoUtil = require '../utils/crypto_util'
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

accessKeyId = 'testid'
accessKeySecret = 'testsecret'

params =
  Version:'v2'
  AccessKeyId:accessKeyId
  SignatureMethod:'HMAC-SHA1'
  Timestamp:'2014-07-14T01:34:55Z'
  SignatureVersion:'1.0'
  SignatureNonce:'14053016951271226'
  fetch_fields:'title;gmt_modified'
  format:'json'
  index_name:'ut_3885312'
  query:'config=format:json,start:0,hit:20&&query=default:'

#params =
#  AccessKeyId: 'aaa',
#  SignatureMethod: 'HMAC-SHA1',
#  SignatureNonce: '14134420315149832',
#  SignatureVersion: '1.0',
#  Timestamp: '2014-10-16T06:47:11Z',
#  Version: 'v2',
#  action: 'push',
#  index_name: 'test',
#  table_name: 'main'



describe "crypto_util test", ->

  before () ->
    #TODO before

  describe "tests", ->

    it 'makeNonce test', (done) ->
      nonce = cryptoUtil.makeNonce accessKeyId, accessKeySecret
      console.log "nonce:#{nonce}"
      done()

    it 'makeSign test', (done) ->
      str = cryptoUtil.makeSign(params, 'POST', accessKeySecret)
      console.log "str:#{str}"
      console.log str is urlEncode.encode('UZI0BW9cYD737iUzCRZawcQ07O4=')
      done()

