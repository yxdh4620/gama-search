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
urllib = require 'urllib'

SIGN_MODE = 1
GET_HTTP_METHOD = "GET"
SEARCH_LIST_SIZE = 40

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
    url = urlUtil.resolve @serverURL, "index/doc"
    console.dir items
    params =
      action:'push'
      items:JSON.stringify(items)
      table_name: table_name
    @apiCall url, params, "GET", callback

  # 搜索文档
  # @public
  # @param {String} indexName 索引名称（应用名称）
  # @param {Object} queryParams 参数列表
  #
  searchById : (id, owner_id, callback) ->
    url = urlUtil.resolve @serverURL, path.join('search')
    params = @loadPublicParams()
    params['query'] ="config=fromat:json,start:0,hit:#{SEARCH_LIST_SIZE}&&query=id:'#{id}'&&filter=contain(owner_id, \"#{owner_id}\")"
    params['index_name'] = @indexName
    params['Signature'] = cryptoUtil.makeSign(params, GET_HTTP_METHOD, @accessKeySecret)

    options =
      url: "#{url}?#{urlEncode.query2string(params)}"
      method:GET_HTTP_METHOD
      timeout: @timeout

    request options, (err, res, body) ->
      callback err, body

  search : (key, owner_id, callback) ->
    url = urlUtil.resolve @serverURL, path.join('search')
    params = @loadPublicParams()
    params['query'] ="config=fromat:json,start:0,hit:#{SEARCH_LIST_SIZE}&&query=default:#{key}&&filter=contain(owner_id, \"#{owner_id}\")"
    params['index_name'] = @indexName
    params['Signature'] = cryptoUtil.makeSign(params, GET_HTTP_METHOD, @accessKeySecret)
    options =
      url: "#{url}?#{urlEncode.query2string(params)}"
      method:GET_HTTP_METHOD
      timeout: @timeout

    request options, (err, res, body) ->
      callback err, body

  loadPublicParams : () ->
    publicParams = {}
    publicParams.Version = @version
    publicParams.AccessKeyId = @accessKeyId
    publicParams.SignatureMethod = 'HMAC-SHA1'
    publicParams.SignatureVersion = '1.0'
    publicParams.SignatureNonce = cryptoUtil.makeNonce(@accessKeyId, @accessKeySecret)
    publicParams.Timestamp = new Date().Format("yyyy-MM-ddThh:mm:ssZ")
    return publicParams


  apiCall : (url, params, httpMethod, callback) ->
    queryParams = queryParams || {}
    queryParams.Version = @version
    queryParams.AccessKeyId = @accessKeyId
    queryParams.SignatureMethod = 'HMAC-SHA1'
    queryParams.SignatureVersion = '1.0'
    queryParams.SignatureNonce = cryptoUtil.makeNonce(@accessKeyId, @accessKeySecret)
    queryParams.Timestamp = new Date().Format("yyyy-MM-ddThh:mm:ssZ")
    queryParams.Signature = cryptoUtil.makeSign(_.extend(queryParams, params), httpMethod, @accessKeySecret)
    #console.dir queryParams
    options =
      url: "#{url}?#{urlEncode.query2string(_.extend(params, queryParams))}"
      method:httpMethod
      timeout: @timeout
      #form: urlEncode.query2query(_.extend(params, queryParams))
      #body: urlEncode.query2string(_.extend(params, queryParams))
      #form: queryParams

    console.dir options

    request options, (err, res, body) ->
      console.log err
      console.log "================================"
      console.dir body
      callback err, body

    #options =
    #  method:httpMethod
    #  data: urlEncode.query2query(_.extend(params, queryParams))
    #  dataType:'json'

    #console.dir options
    #urllib.request url, options, (err, data, res) ->
    #  console.log err
    #  console.dir data
    #  return callback err, data

module.exports=SearchManager




