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
owner_id_1 = 'GO2SIsP'
owner_id_2 = 'CSCC3LtU'
model_name_1 = 'animations'
model_name_2 = 'tilemaps'
search = new SearchManager(options)

singleItem = [{
    id:'aaaaaaaa'
    title: '这里是一个标题002',
    owner_id: owner_id_1,
    desc:'这里是文档的详细内容',
    model_name: 'iconpack'
}]

mulitItem = [
  {
    id:'bbbbbb'
    title: '这里是一个标题003',
    owner_id: owner_id_1,
    desc:'这里是文档的详细内容',
    model_name: 'iconpack'
  },
  {
    id:'ccccccc'
    title: '这里是一个标题005',
    owner_id: owner_id_1,
    desc:'这里是文档的详细内容',
    model_name: model_name_1
  },
  {
    id:'ddddddd'
    title: '这里是一个标题005',
    owner_id: owner_id_1,
    desc:'这里是文档的详细内容',
    model_name: model_name_2
  },
  {
    id:'eeeeeee'
    title: '这里是一个标题005',
    owner_id: owner_id_2,
    desc:'这里是文档的详细内容',
    model_name: 'iconpack'
  },
  {
    id:'fffffff'
    title: '这里是一个标题005',
    owner_id: owner_id_2,
    desc:'这里是文档的详细内容',
    model_name: model_name_1
  },
  {
    id:'ggggggg'
    title: '这里是一个标题005',
    owner_id: owner_id_2,
    desc:'这里是文档的详细内容',
    model_name: model_name_2
  }
]

describe "search test", ->

  before () ->
    #TODO before

  describe "insert tests", ->
    it 'insert single', (done) ->
      search.insert singleItem, table_name, (err, data) ->
        console.error "error:#{err}"
        console.dir data
        done()
    it 'insert mulit', (done) ->
      search.insert mulitItem, table_name, (err, data) ->
        console.error "error:#{err}"
        console.dir data
        done()

  describe "update tests", ->
    it 'update single', (done) ->
      search.update singleItem, table_name, (err, data) ->
        console.error "error:#{err}"
        console.dir data
        done()
    it 'update mulit', (done) ->
      search.update mulitItem, table_name, (err, data) ->
        console.error "error:#{err}"
        console.dir data
        done()

  describe 'search tests', ->
    it "search id test", (done) ->
      search.searchById '9', ['owner_id',owner_id_1,'OR','model_name',model_name_1], (err, data) ->
        console.log "err:#{err}"
        console.dir data
        done()
    it "search default test", (done) ->
      search.search '文档', ['owner_id',owner_id_1,'OR','model_name',model_name_2], 1, (err, data) ->
        console.error "error:#{err}"
        console.dir data
        console.dir data.result if (data||{}).status is "OK"
        done()

  #describe "delete tests", ->
  #  it 'delete single', (done) ->
  #    search.delete ['aaaaaaaa'], table_name, (err, data) ->
  #      console.error "error:#{err}"
  #      console.dir data
  #      done()

  #  it 'delete mulit', (done) ->
  #    search.delete ['bbbbbb','ccccccc'], table_name, (err, data) ->
  #      console.error "error:#{err}"
  #      console.dir data
  #      done()



