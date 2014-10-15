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

class SearchManager

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
    @signatureVersion = searchOptions.SignatureVersion || '1.0'

  insert : (items, table_name, callback) ->
    url = urlUtil.resolve @serverURL, path.join("index/doc/",@indexName)
    params =
      action:'push'
      items:JSON.stringify(items)
      table_name: table_name
    @apiCall url, params, "POST", callback

  # 搜索文档
  # @public
  # @param {String} indexName 索引名称（应用名称）
  # @param {Object} queryParams 参数列表
  #
  searchById : (id, owner_id, callback) ->
    url = urlUtil.resolve @serverURL, path.join('search')
    params =
      #query:"config=fromat:json,start:0,hit:20&&query=id:'#{id}'&&filter=contain(owner_id, #{owner_id})"
      query:"query=id:3"
      index_name: @indexName
    @apiCall url, params, "GET", callback

  search : (key, owner_id, callback) ->
    url = urlUtil.resolve @serverURL, path.join('search')
    params =
      query:"config=fromat:json,start:0,hit:20&&query=default:#{key}&&filter=contain(owner_id, #{owner_id})"
      index_name: @indexName
    @apiCall url, params, "GET", callback


  apiCall : (url, params, httpMethod, callback) ->
    queryParams = queryParams || {}
    queryParams.Version = @version
    queryParams.AccessKeyId = @accessKeyId
    queryParams.SignatureMethod = 'HMAC-SHA1'
    queryParams.SignatureVersion = '1.0'
    queryParams.SignatureNonce = cryptoUtil.makeNonce(@accessKeyId, @accessKeySecret)
    queryParams.Timestamp = new Date().Format("yyyy-MM-DDTHH:mm:ssZ")
    queryParams.Signature = cryptoUtil.makeSign(_.extend(queryParams, params), httpMethod, @accessKeySecret)
    console.dir queryParams
    options =
      url: "#{url}?#{urlEncode.query2string(queryParams)}"
      method:httpMethod
      timeout: @timeout
      #form: _.extend params, queryParams
      #form: queryParams

    console.dir options

    request options, (err, res, body) ->
      console.log err
      console.log "================================"
      console.dir body
      callback err, body


module.exports=SearchManager




