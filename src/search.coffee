###
# User YuanXiangDong
# Date 14-10-14
# aliyun search main
# aliyun开放式搜索的接口实现
####
assert = require "assert"
urlUtil = require 'url'
request = require 'request'
path = require 'path'
cryptoUtil = require './utils/crypto_util'
_ = require "underscore"
urlEncode = require './utils/url_encode'

SIGN_MODE = 1
GET_HTTP_METHOD = "GET"
POST_HTTP_METHOD = "POST"
SEARCH_LIST_SIZE = 40

class SearchManager

  # 构造函数
  # @param options:{}
  #   accessKeyId, 必须
  #   accessKeySecret, 必须
  #   apiURL
  #   version
  #   format
  #   timeout
  #   dataType
  #   indexName
  #   signatureMethod
  #   signatureVersion
  #
  constructor : (searchOptions) ->
    assert searchOptions, "missing options"
    assert searchOptions.accessKeyId, "missing opensearch key id"
    assert searchOptions.accessKeySecret, "missing opensearch key secret"

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
    @signatureVersion = searchOptions.signatureVersion || '1.0'

  # 提交文档
  # @param items [{},{}]
  # @param table_name 表名
  # @return callback(err, data) data 成功：{"status":"OK"} 失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'
  insert : (items, table_name, callback) ->
    assert Array.isArray(items) and items.length>0, "missing options"
    assert table_name, "missing table_name"
    assert _.isFunction(callback), "missing callback"
    url = urlUtil.resolve @serverURL, path.join("index/doc",@indexName)
    #console.dir items
    cmd = 'add'
    query = []
    for val in items
      query.push {
        cmd: cmd
        fields:val
      }
    params =
      action:'push'
      items:JSON.stringify(query)
      table_name: table_name
      sing_mode: "#{SIGN_MODE}"
    @apiCall url, params, POST_HTTP_METHOD, callback
    return

  update : (items, table_name, callback) ->
    @insert items, table_name, callback
    return

  # 搜索文档
  # @public
  # @param {String} id 主键的值
  # @param {String} owner_id 用来分组的键值（即ownerA的不能搜索ownerB的内容）
  # @return callback(err, data)
  #   data  成功：'{"status":"OK","result":{"searchtime":0.008163,"total":3,"num":3,"viewtotal":3,"items":[{"id":"bbbbbb","title":"zhe li shi yi ge biao ti 003","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"ccccccc","title":"zhe li shi yi ge biao ti 005","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"aaaaaaaa","title":"zhe li shi yi ge biao ti 002","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"}],"facet":[]},"errors":[],"tracer":""}'
  #         失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'

  searchById : (id, owner_id, callback) ->
    url = urlUtil.resolve @serverURL, path.join('search')
    params = @loadPublicParams()
    #params = {}
    params['query'] ="config=fromat:json,start:0,hit:#{SEARCH_LIST_SIZE}&&query=id:'#{id}'&&filter=contain(owner_id, \"#{owner_id}\")"
    params['index_name'] = @indexName
    params['Signature'] = cryptoUtil.makeSign(params, GET_HTTP_METHOD, @accessKeySecret)
    options =
      url: "#{url}?#{urlEncode.query2string(params)}"
      method:GET_HTTP_METHOD
      timeout: @timeout
    request options, (err, res, body) ->
      callback err, body
      return
    return

  # 搜索文档
  # @public
  # @param {String} queryStr 搜索的关键字
  # @param {String} owner_id 用来分组的键值（即ownerA的不能搜索ownerB的内容）
  # @return callback(err, data)
  #   data  成功：'{"status":"OK","result":{"searchtime":0.008163,"total":3,"num":3,"viewtotal":3,"items":[{"id":"bbbbbb","title":"zhe li shi yi ge biao ti 003","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"ccccccc","title":"zhe li shi yi ge biao ti 005","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"aaaaaaaa","title":"zhe li shi yi ge biao ti 002","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"}],"facet":[]},"errors":[],"tracer":""}'
  #         失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'

  search : (queryStr, owner_id, callback) ->
    url = urlUtil.resolve @serverURL, path.join('search')
    params = @loadPublicParams()
    params['query'] ="config=fromat:json,start:0,hit:#{SEARCH_LIST_SIZE}&&query=default:#{queryStr}&&filter=contain(owner_id, \"#{owner_id}\")"
    params['index_name'] = @indexName
    params['Signature'] = cryptoUtil.makeSign(params, GET_HTTP_METHOD, @accessKeySecret)
    options =
      url: "#{url}?#{urlEncode.query2string(params)}"
      method:GET_HTTP_METHOD
      timeout: @timeout
    request options, (err, res, body) ->
      callback err, body
      return
    return

  # 提交文档
  # @param ids [id,id]
  # @param table_name 表名
  # @return callback(err, data) data 成功：'{"status":"OK","RequestId":"1413451169068930200630477"}' 失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'
  delete : (ids, table_name, callback) ->
    assert Array.isArray(ids) and ids.length>0, "missing options"
    assert table_name, "missing table_name"
    assert _.isFunction(callback), "missing callback"
    url = urlUtil.resolve @serverURL, path.join("index/doc",@indexName)
    #console.dir items
    cmd = 'delete'
    query = []
    for id in ids
      query.push {
        cmd: cmd
        fields:{
          id:id
        }
      }
    params =
      action:'push'
      items:JSON.stringify(query)
      table_name: table_name
      sing_mode: "#{SIGN_MODE}"
    @apiCall url, params, POST_HTTP_METHOD, callback
    return

  #获得公共参数
  loadPublicParams : () ->
    publicParams = {}
    publicParams.Version = @version
    publicParams.AccessKeyId = @accessKeyId
    publicParams.SignatureMethod = 'HMAC-SHA1'
    publicParams.SignatureVersion = '1.0'
    publicParams.SignatureNonce = cryptoUtil.makeNonce(@accessKeyId, @accessKeySecret)
    #publicParams.Timestamp = new Date().Format("yyyy-MM-ddThh:mm:ssZ")
    publicParams.Timestamp = new Date(new Date().getTime()-28800000).Format("yyyy-MM-ddThh:mm:ssZ")
    return publicParams


  apiCall : (url, params, httpMethod, callback) ->
    queryParams = @loadPublicParams()
    #queryParams.Version = @version
    #queryParams.AccessKeyId = @accessKeyId
    #queryParams.SignatureMethod = 'HMAC-SHA1'
    #queryParams.SignatureVersion = '1.0'
    #queryParams.SignatureNonce = cryptoUtil.makeNonce(@accessKeyId, @accessKeySecret)
    ##queryParams.Timestamp = new Date().Format("yyyy-MM-ddThh:mm:ssZ")
    #queryParams.Timestamp = new Date(new Date().getTime()-28800000).Format("yyyy-MM-ddThh:mm:ssZ")
    queryParams.Signature = cryptoUtil.makeSign(_.extend(queryParams, params), httpMethod, @accessKeySecret)
    options =
      url: "#{url}"
      method:httpMethod
      timeout: @timeout
      form: urlEncode.query2string(_.extend(params, queryParams))
    request options, (err, res, body) ->
      callback err, body
      return
    return

module.exports=SearchManager




