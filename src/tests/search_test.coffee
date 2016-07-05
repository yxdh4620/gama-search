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
console.dir config
con = config.openSearch || {}
console.dir con
options =
  accessKeyId: con.accessKeyId
  accessKeySecret: con.accessKeySecret
  apiURL:con.host
  indexName:con.appName
  pageSize: con.pageSize

fieldName = 'search_name'
table_name = 'main'
owner_id_1 = 'GO2SIsP'
owner_id_2 = 'FOtmGSC'
model_name_1 = 'Animation'
model_name_2 = 'Tilemap'
search = new SearchManager(options)

#singleItem = [{
#    id:'aaaaaaaa'
#    title: '这里是一个标题002',
#    owner_id: owner_id_1,
#    desc:'这里是文档的详细内容',
#    model_name: 'iconpack'
#}]
#
#mulitItem = [
#  {
#    id:'bbbbbb'
#    title: '这里是一个标题003',
#    owner_id: owner_id_1,
#    desc:'这里是文档的详细内容',
#    model_name: 'iconpack'
#  },
#  {
#    id:'ccccccc'
#    title: '这里是一个标题005',
#    owner_id: owner_id_1,
#    desc:'这里是文档的详细内容',
#    model_name: model_name_1
#  },
#  {
#    id:'ddddddd'
#    title: '这里是一个标题005',
#    owner_id: owner_id_1,
#    desc:'这里是文档的详细内容',
#    model_name: model_name_2
#  },
#  {
#    id:'eeeeeee'
#    title: '这里是一个标题005',
#    owner_id: owner_id_2,
#    desc:'这里是文档的详细内容',
#    model_name: 'iconpack'
#  },
#  {
#    id:'fffffff'
#    title: '这里是一个标题005',
#    owner_id: owner_id_2,
#    desc:'这里是文档的详细内容',
#    model_name: model_name_1
#  },
#  {
#    id:'ggggggg'
#    title: '这里是一个标题005',
#    owner_id: owner_id_2,
#    desc:'这里是文档的详细内容',
#    model_name: model_name_2
#  }
#]

singleItem = [
  {
    id: '6gUxv34',
    owner_id: 'FOtmGSC',
    permalink: 'test1/test2',
    model_name: 'Animation',
    created_at: '2014-09-09T02:53:59.012Z',
    item: '{"id":"6gUxv34","model_name":"Animation","owner_id":"FOtmGSC","title":"0010.png","desc":"","compiled_assets":{},"tags":[]}'
  }
]

mulitItem = [
  {
    id: '6gUxv34',
    owner_id: 'FOtmGSC',
    permalink: 'test1/test2',
    model_name: 'Animation',
    created_at: '2014-09-09T02:53:59.012Z',
    item: '{"id":"6gUxv34","model_name":"Animation","owner_id":"FOtmGSC","title":"0010.png","desc":"","compiled_assets":{},"tags":[]}' },
  {
    id: 'CQ33vri',
    owner_id: 'FOtmGSC',
    permalink: 'test1/test2',
    model_name: 'Figure',
    created_at: '2014-09-09T04:46:12.646Z',
    item: '{"id":"CQ33vri","model_name":"Figure","owner_id":"FOtmGSC","title":"untitled","desc":"","compiled_assets":{},"tags":[],"poses":[{"name":"act","_id":"540e86142994e1090fd0e8f5","flips":[0,0,0,0,0,0,0,0],"animations":["","","","","","","",""]}]}'
  },
  {
    id: 'IWGi3JC',
    owner_id: 'FOtmGSC',
    permalink: 'test1/test2',
    model_name: 'Figure',
    created_at: '2014-09-09T02:54:51.838Z',
    item: '{"id":"IWGi3JC","model_name":"Figure","owner_id":"FOtmGSC","title":"untitled","desc":"","compiled_assets":{},"tags":[],"poses":[{"name":"act","_id":"540e6bfba4cc02c705be7382","flips":[0,0,1,0,0,0,0,0],"animations":["96zRxm4","","96zRxm4","","","","",""]}]}'
  },
  {
    id: '8OuLxgQ',
    owner_id: 'FOtmGSC',
    permalink: 'test1/test2',
    model_name: 'Tilemap',
    created_at: '2014-09-09T02:57:18.544Z',
    item: '{"id":"8OuLxgQ","model_name":"Tilemap","owner_id":"FOtmGSC","title":"XFjXLifh-tilemaps-3hLQqBp-source.jpg","desc":"","compiled_assets":{},"tags":[]}'
  }
]

describe "search test", ->

  before () ->
    #TODO before

  #describe "insert tests", ->
  #  it 'insert single', (done) ->
  #    search.insert singleItem, table_name, (err, data) ->
  #      console.error "error:#{err}"
  #      console.dir data
  #      done()
  #  it 'insert mulit', (done) ->
  #    search.insert mulitItem, table_name, (err, data) ->
  #      console.error "error:#{err}"
  #      console.dir data
  #      done()

  #describe "update tests", ->
  #  it 'update single', (done) ->
  #    search.update singleItem, table_name, (err, data) ->
  #      console.error "error:#{err}"
  #      console.dir data
  #      done()
  #  it 'update mulit', (done) ->
  #    search.update mulitItem, table_name, (err, data) ->
  #      console.error "error:#{err}"
  #      console.dir data
  #      done()

  describe 'search tests', ->
  #  it "search id test", (done) ->
  #    search.searchById 'GvsQB4Q', ['owner_id',owner_id_1,'OR','model_name',model_name_1], (err, data) ->
  #      console.log "err:#{err}"
  #      console.dir data
  #      done()

    it "search multi id test", (done) ->
      search.searchByMultipleId "id:'989541712' OR id:'992232784'", null, (err, data) ->
      #search.searchByMultipleId [989541712,992232784], null, (err, data) ->
        console.log "err:#{err}"
        console.dir data
        console.dir data.result if (data||{}).status is "OK"
        done()

    it "search default test", (done) ->
      search.search 'a', fieldName, null, 1, 2, (err, data) ->
        console.error "error:#{err}"
        console.dir data
        console.dir data.result if (data||{}).status is "OK"
        done()

    it "advancedSearch tests", (done)->
      subQuerys =
        filter:['kind','a']
        sort: 'score'

      others =
        fetch_fields:['aid', 'score']
      search.advancedSearch '呼', fieldName, 1, {filter:['kind','a'],sort:'score'}, {fetch_fields:['aid','score', 'search_name']}, 2, (err, data) ->
        console.error "error:#{err}"
        console.dir data
        console.dir data.result if (data||{}).status is "OK"
        done()

  #  it "search kind sort test", (done) ->
  #    search.search 'a', 'kind', 'score=0', 1, (err, data) ->
  #      console.error "error:#{err}"
  #      console.dir data
  #      console.dir data.result if (data||{}).status is "OK"
  #      done()


    #it "search default test", (done) ->
    #  search.search 'Tilemap', 'item', ['owner_id',owner_id_2,'AND','model_name',model_name_2], 1, (err, data) ->
    #    console.error "error:#{err}"
    #    console.dir data
    #    console.dir data.result if (data||{}).status is "OK"
    #    done()

    #it "advancedSearch tests", (done)->
    #  subQuerys =
    #    filter:['owner_id',owner_id_2,'AND','model_name',model_name_2]
    #    aggregate:"group_key:model_name,agg_fun:count()"
    #  #  sort: "+model_name"
    #  #  distinct: "dist_key:model_name"
    #  others =
    #    fetch_fields:['id','model_name','item']
    #    summary:"summary_field:item"

    #  search.advancedSearch 'Tilemap', 'item',  1, subQuerys, others, (err, data) ->
    #    console.error "error:#{err}"
    #    console.dir data
    #    console.dir data.result if (data||{}).status is "OK"
    #    done()

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



