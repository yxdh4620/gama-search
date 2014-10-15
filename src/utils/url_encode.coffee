###
# User YuanXiangDong
# Date 14-10-14
# url parmas encode util
###
debug = require('debug')('gama-search::utils::url_encode')

dontNeedEncoding = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_.~'


#URL encoding
exports.encode = (str) ->
  out = []
  for i in [0...str.length]
    #console.log "length:#{str.length} i:#{i}"
    char = str[i]
    if dontNeedEncoding.indexOf(char) >=0
      #char = '+' if char is ' '
      out.push char
    else
      buf = new Buffer(char).toString('hex').toUpperCase()
      jlen = buf.length/2
      for j in [0...jlen]
        out.push "%#{buf.substring(j*2, (j+1)*2)}"
  s = out.join('')
  debug 'encode', s
  return s

#将所需的参数装换为URL String
exports.query2string = (params) ->
  str = ''
  for key, val of params
    str += "#{exports.encode(key)}=#{exports.encode(val)}&"
  str = str.substring(0, str.length-1)#+exports.encode("的")
  debug 'query2string', str
  return str


#do ->
#  console.log exports.encode '*abc;dfasdfas"fkasd;klfjaksjfkjkj '
#  console.log exports.query2string {name:'cike', 'user':'lili'}
#  console.log new Date().toISOString()

