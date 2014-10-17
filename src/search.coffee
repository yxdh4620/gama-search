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

#计算搜索的过滤条件
_makeFilter = (filter) ->
  filterStr = ''
  if filter?
    if _.isString(filter)
      filterStr = filter
    else if _.isArray(filter)
      for val, step in filter by 3
          filterStr += "contain(#{val}, \"#{filter[step+1]}\") #{filter[step+2]||''} "
  return filterStr

class SearchManager

  # 构造函数
  # @param options:{}
  #   accessKeyId, 必须
  #   accessKeySecret, 必须
  #   apiURL
  #   pageSize 单页结果数量，默认40条
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
    @pageSize = searchOptions.pageSize || SEARCH_LIST_SIZE


  # 提交文档
  # @param items [{},{}]
  # @param table_name 表名
  # @return callback(err, data) data(json格式) 成功：{"status":"OK"} 失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'
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

  # 提交文档
  # @param items [{},{}]
  # @param table_name 表名
  # @return callback(err, data) data(json格式) 成功：{"status":"OK"} 失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'
  update : (items, table_name, callback) ->
    @insert items, table_name, callback
    return

  # 搜索文档(按id主键进行的搜索，所以没有分页)
  # @public
  # @param {String} id 主键的值
  # @param {Object|String} filter 用来数据过滤 可以为Null(为Null,表示不进行过滤)
  #   String：过滤算法的String格式（用于比较复杂的自定义过滤，具体语法参考：http://help.opensearch.aliyun.com/index.php?title=Filter%E5%AD%90%E5%8F%A5）
  #   Object: 目前只支持filter的contain过滤方式。格式：[字段名, 过滤值, 逻辑判断符('AND','OR'), 字段名, 过滤值]
  # @return callback(err, data)
  #   data(json格式)  成功：'{"status":"OK","result":{"searchtime":0.008163,"total":3,"num":3,"viewtotal":3,"items":[{"id":"bbbbbb","title":"zhe li shi yi ge biao ti 003","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"ccccccc","title":"zhe li shi yi ge biao ti 005","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"aaaaaaaa","title":"zhe li shi yi ge biao ti 002","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"}],"facet":[]},"errors":[],"tracer":""}'
  #         失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'
  searchById : (id, filter, callback) ->
    url = urlUtil.resolve @serverURL, path.join('search')
    params = @loadPublicParams()
    params['query'] ="config=fromat:json,start:0,hit:#{@pageSize}&&query=id:'#{id}'&&filter=#{_makeFilter(filter)}"
    params['index_name'] = @indexName
    params['Signature'] = cryptoUtil.makeSign(params, GET_HTTP_METHOD, @accessKeySecret)
    options =
      url: "#{url}?#{urlEncode.query2string(params)}"
      method:GET_HTTP_METHOD
      timeout: @timeout
    request options, (err, res, body) =>
      body = @_parseResult(body)
      callback err, body
      return
    return

  # 搜索文档
  # @public
  # @param {String} queryStr 搜索的关键字
  # @param {Object|String} filter 用来数据过滤 可以为Null(为Null,表示不进行过滤)
  #   String：过滤算法的String格式（用于比较复杂的自定义过滤，具体语法参考：http://help.opensearch.aliyun.com/index.php?title=Filter%E5%AD%90%E5%8F%A5）
  #   Object: 目前只支持filter的contain过滤方式。格式：[字段名, 过滤值, 逻辑判断符('AND','OR'), 字段名, 过滤值]
  # @return callback(err, data)
  #   data(json格式)  成功：'{"status":"OK","result":{"searchtime":0.008163,"total":3,"num":3,"viewtotal":3,"items":[{"id":"bbbbbb","title":"zhe li shi yi ge biao ti 003","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"ccccccc","title":"zhe li shi yi ge biao ti 005","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"aaaaaaaa","title":"zhe li shi yi ge biao ti 002","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"}],"facet":[]},"errors":[],"tracer":""}'
  #         失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'
  search : (queryStr, filter, page, callback) ->
    page = 1 unless _.isNumber(page) and page>0
    start = (page-1)*@pageSize
    url = urlUtil.resolve @serverURL, path.join('search')
    params = @loadPublicParams()
    #params['query'] = "config=fromat:json,start:#{start},hit:#{@pageSize}&&query=default:#{queryStr}&&filter=contain(owner_id, \"#{owner_id}\") AND contain(model_name, \"tilemaps\")"
    params['query'] = "config=fromat:json,start:#{start},hit:#{@pageSize}&&query=default:#{queryStr}&&filter=#{_makeFilter(filter)}"
    params['index_name'] = @indexName
    params['Signature'] = cryptoUtil.makeSign(params, GET_HTTP_METHOD, @accessKeySecret)
    options =
      url: "#{url}?#{urlEncode.query2string(params)}"
      method:GET_HTTP_METHOD
      timeout: @timeout
    request options, (err, res, body) =>
      unless err
        body = @_parseResult(body, page)
      callback err, body
      return
    return

  # 删除文档
  # @param ids [id,id]
  # @param table_name 表名
  # @return callback(err, data) data(json格式) 成功：'{"status":"OK","RequestId":"1413451169068930200630477"}' 失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'
  delete : (ids, table_name, callback) ->
    assert Array.isArray(ids) and ids.length>0, "missing options"
    assert table_name, "missing table_name"
    assert _.isFunction(callback), "missing callback"
    url = urlUtil.resolve @serverURL, path.join("index/doc",@indexName)
    #console.dir items
    cmd = 'delete'
    query = []
    ids.map (id) ->
      query.push {
        cmd: cmd
        fields:{
          id:id
        }
      }
    console.dir query
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
    publicParams.Timestamp = new Date(new Date().getTime()-28800000).Format("yyyy-MM-ddThh:mm:ssZ")
    return publicParams

  apiCall : (url, params, httpMethod, callback) ->
    queryParams = @loadPublicParams()
    queryParams.Signature = cryptoUtil.makeSign(_.extend(queryParams, params), httpMethod, @accessKeySecret)
    options =
      url: "#{url}"
      method:httpMethod
      timeout: @timeout
      form: urlEncode.query2string(_.extend(params, queryParams))
    request options, (err, res, body) =>
      body = @_parseResult(body)
      callback err, body
      return
    return

  _parseResult : (data, page) ->
    return data unless data
    data = JSON.parse(data)
    return data unless page?
    return data unless data.status is 'OK'
    result = data.result
    return data unless result
    result['page'] = page
    result['pagetotal'] =  parseInt((result.viewtotal+@pageSize-1)/@pageSize)
    data.result = result
    return data

module.exports=SearchManager




