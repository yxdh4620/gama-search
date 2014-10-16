###
# search 的测试类
###

should = require 'should'
debug = require('debug')('gama-search::tests::search_test')
config = require './config'
SearchManager = require '../search'

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

###
    @accessKeyId = searchOptions.accessKeyId
    @accessKeySecret = searchOptions.accessKeySecret
    @apiURL = searchOptions.apiURL || 'http://opensearch.aliyuncs.com'
    @version = searchOptions.version || 'v2'
    @format = searchOptions.format || 'json'
    @timeout = searchOptions.timeout || 3000
    @dataType = searchOptions.dataType || 'json'
    #@serverURL = urlUtil.resolve @apiURL, path.join(@version, 'api/')
    @serverURL = @apiURL
    @indexName = searchOptions.indexName || 'test'
    @signatureMethod = searchOptions.signatureMethod||'HMAC-SHA1'
    @signatureVersion = searchOptions.SignatureVersion || '1.0'

###

con = config.opensearch || {}
options =
  accessKeyId: con.accessKeyId
  accessKeySecret: con.accessKeySecret
  apiURL:con.host

table_name = 'main'
owner_id = 'GO2SIsP'
search = new SearchManager(options)

singleItem = [{
  cmd: 'add',
  "fields":{
    title: '这里是一个标题001',
    owner_id: owner_id,
    desc:'这里是文档的详细内容',
    model_name: 'iconpack'
  }
}]

describe "url_encode test", ->

  before () ->
    #TODO before

  describe "insert tests", ->

    it 'insert single', (done) ->
      search.insert singleItem, table_name, (err, data) ->
        done()

  describe 'search tests', ->

    it "search id test", (done) ->
      search.searchById '3', owner_id, (err, data) ->
        console.log "err:#{err}"
        console.dir data
        done()
  #  it "search default test", (done) ->
  #    search.search '搜索', owner_id, (err, data) ->
  #      console.log "err:#{err}"
  #      console.dir data
  #      done()



