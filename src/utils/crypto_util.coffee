###
# 加密工具类
# User YuanXiangDong
# Date 14-10-14
###

crypto = require 'crypto'
debug = require('debug')('gama-search::utils::crypto_util')
urlEncode = require './url_encode'

dateYearRegexp = /(y+)/
Date.prototype.Format = (fmt) ->
  o = {
    "M+" : this.getMonth()+1,                 #//月份
    "d+" : this.getDate(),                    #//日
    "h+" : this.getHours(),                   #//小时
    "m+" : this.getMinutes(),                 #//分
    "s+" : this.getSeconds(),                 #//秒
    "q+" : Math.floor((this.getMonth()+3)/3), #//季度
    "S"  : this.getMilliseconds()             #//毫秒
  }
  if(/(y+)/.test(fmt))
    fmt=fmt.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length))
  for k, val of o
    if(new RegExp("(#{k})").test(fmt))
      fmt = fmt.replace(RegExp.$1, if RegExp.$1.length==1 then (o[k]) else (("00"+ o[k]).substr((""+ o[k]).length)))
  return fmt

exports.md5 = (str) ->
  md5sum = crypto.createHash 'md5'
  md5sum.update str, Buffer.isBuffer(str) ? 'binary' : 'utf8'
  return md5sum.digest 'hex'

exports.hmac = (str, key) ->
  hmacsum = crypto.createHmac 'sha1', key
  hmacsum.update str
  return hmacsum.digest().toString('base64')


# 创建Nonce信息
# @param {String} accessKeyId(clientId)
# @param {String} accessKeySecret(clientSecret)
# @return {String} Nonce
exports.makeNonce = () ->
  time = parseInt(new Date().getTime())
  random = Math.floor(Math.random()*(9999-1000+1)+1000)
  return "#{time}#{random}"

#exports.makeNonce = (accessKeyId, accessKeySecret) ->
#  time = parseInt(new Date().getTime()/1000)
#  return exports.md5("#{accessKeyId}#{accessKeySecret}#{time}")+".#{time}"


# 根据参数创建签名信息
# @param {Object} 参数Hash
# @param {String} 提交请求的HTTP方式（GET or POST）
# @param {String} accessKeySecret(clientSecret)
# @return {String} 签名字符串
exports.makeSign = (params, httpMethod, accessKeySecret) ->
  q = ''
  if params?
    if params.sign_mode is "1" and params.items?
      delete params.items
    #console.dir params
    keys = Object.keys params
    keys.sort()
    _p = {}
    for i in [0...keys.length]
      key = keys[i]
      _p[key] = params[key]
  #console.dir _p
  q = "#{httpMethod}&#{urlEncode.encode('/')}&#{urlEncode.encode(urlEncode.query2string(_p))}"
  #console.log "q:#{q}"
  sign = exports.hmac "#{q}", "#{accessKeySecret}&"
  #return urlEncode.encode sign
  return sign

#exports.makeSign = (params, accessKeySecret) ->
#  q = ''
#  if params?
#    if params.sign_mode is '1' and params.items?
#      delete params.items
#    keys = Object.keys params
#    keys.sort()
#    _p = {}
#    for i in [0...keys.length]
#      key = keys[i]
#      _p[key] = params[key]
#
#  q = urlEncode.query2string(_p)
#  return exports.md5 "#{q}#{accessKeySecret}"


#do ->
#  console.log exports.makeNonce('afadfasfasdfadsf', 'adsfasdfasdfasdf')
#
#  console.log exports.makeSign {name:'gama', value:'inc'}, 'afasdfsafasfdadsf'
#


