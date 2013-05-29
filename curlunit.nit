module curlunit
import ffcurl
import mail

fun errorManager(err: CURLCode) do if not err.is_ok then print err

var curl = new FFCurl.easy_init
if not curl.is_init then print "wrong init"

var error:CURLCode
error = curl.easy_setopt(new CURLOption.url, args[0])
errorManager(error)

error = curl.easy_setopt(new CURLOption.verbose, 1)
errorManager(error)

error = curl.easy_perform
errorManager(error)


# Long set
var info :nullable CURLInfoResponseLong
info = curl.easy_getinfo_long(new CURLInfoLong.header_size)
assert infoResp:info != null 
print "GetinfoLong :: Header size :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.response_code)
assert infoResp:info != null 
print  "GetinfoLong :: Response code :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.http_connectcode)
assert infoResp:info != null 
print  "GetinfoLong :: http_connectcode :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.filetime)
assert infoResp:info != null 
print  "GetinfoLong :: filetime :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.redirect_count)
assert infoResp:info != null 
print  "GetinfoLong :: redirect_count :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.request_size)
assert infoResp:info != null 
print  "GetinfoLong :: request_size :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.ssl_verifyresult)
assert infoResp:info != null 
print  "GetinfoLong :: ssl_verifyresult :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.httpauth_avail)
assert infoResp:info != null 
print  "GetinfoLong :: httpauth_avail :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.proxyauth_avail)
assert infoResp:info != null 
print  "GetinfoLong :: proxyauth_avail :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.os_errno)
assert infoResp:info != null 
print  "GetinfoLong :: os_errno :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.primary_port)
assert infoResp:info != null 
print  "GetinfoLong :: primary_port :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.num_connects)
assert infoResp:info != null 
print  "GetinfoLong :: num_connects :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.local_port)
assert infoResp:info != null 
print  "GetinfoLong :: local_port :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.lastsocket)
assert infoResp:info != null 
print  "GetinfoLong :: lastsocket :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.condition_unmet)
assert infoResp:info != null 
print  "GetinfoLong :: condition_unmet :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.rtsp_client_cseq)
assert infoResp:info != null 
print  "GetinfoLong :: rtsp_client_cseq :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.rtsp_server_cseq)
assert infoResp:info != null 
print  "GetinfoLong :: rtsp_server_cseq :"+info.response.to_s

info = curl.easy_getinfo_long(new CURLInfoLong.rtsp_cseq_recv)
assert infoResp:info != null 
print  "GetinfoLong :: rtsp_cseq_recv :"+info.response.to_s

# Double
var infoDouble:nullable CURLInfoResponseDouble
infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.total_time)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: total_time :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.namelookup_time)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: namelookup_time :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.connect_time)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: connect_time :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.appconnect_time)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: appconnect_time :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.pretransfer_time)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: pretransfer_time :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.starttransfer_time)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: starttransfer_time :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.redirect_time)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: redirect_time :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.size_upload)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: size_upload :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.size_download)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: size_download :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.speed_download)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: speed_download :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.speed_upload)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: speed_upload :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.content_length_download)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: content_length_download :"+infoDouble.response.to_s

infoDouble = curl.easy_getinfo_double(new CURLInfoDouble.content_length_upload)
assert infoResp:infoDouble != null 
print  "GetinfoDouble :: content_length_upload :"+infoDouble.response.to_s

# String set
var infoStr:nullable CURLInfoResponseString
infoStr = curl.easy_getinfo_chars(new CURLInfoChars.content_type)
assert infoResp:infoStr != null 
print "GetinfoStr :: Content type :"+infoStr.response

infoStr = curl.easy_getinfo_chars(new CURLInfoChars.effective_url)
assert infoResp:infoStr != null 
print  "GetinfoStr :: Effective url  :"+infoStr.response

infoStr = curl.easy_getinfo_chars(new CURLInfoChars.redirect_url)
assert infoResp:infoStr != null 
print  "GetinfoStr :: Redirect url :"+infoStr.response

infoStr = curl.easy_getinfo_chars(new CURLInfoChars.primary_ip)
assert infoResp:infoStr != null 
print  "GetinfoStr :: primary_ip :"+infoStr.response

infoStr = curl.easy_getinfo_chars(new CURLInfoChars.local_ip)
assert infoResp:infoStr != null 
print  "GetinfoStr :: local_ip :"+infoStr.response

infoStr = curl.easy_getinfo_chars(new CURLInfoChars.ftp_entry_path)
assert infoResp:infoStr != null 
print  "GetinfoStr :: ftp_entry_path :"+infoStr.response

infoStr = curl.easy_getinfo_chars(new CURLInfoChars.private_data)
assert infoResp:infoStr != null 
print  "GetinfoStr :: private_data :"+infoStr.response

infoStr = curl.easy_getinfo_chars(new CURLInfoChars.rtsp_session_id)
assert infoResp:infoStr != null 
print  "GetinfoStr :: rtsp_session_id :"+infoStr.response

# CURLSList set
var infoList:nullable CURLInfoResponseArray
infoList = curl.easy_getinfo_slist(new CURLInfoSList.ssl_engines)
assert infoResp:infoList != null 
print "GetSList :: ssl_engines :"+infoList.response.to_s

infoList = curl.easy_getinfo_slist(new CURLInfoSList.cookielist)
assert infoResp:infoList != null 
print "GetSList :: cookielist :"+infoList.response.to_s

# CURLSList to Array
var mailList:CURLSList
mailList = new CURLSList.with_str("titi")
mailList.append("toto")
mailList.append("toto2")
mailList.append("toto3")
mailList.append("toto4")
mailList.append("toto9")
if mailList.is_init then 
  var content = mailList.to_a
  print "CURLSList to array - content : {content.to_s}"
  print "CURLSList to array - length : {content.length.to_s}"
  mailList.destroy
else
  print "CURLSList to array : CURLSList wrong init"
end

# CURLSList from Array
var mailRecipientsArray = new Array[String]
mailRecipientsArray.add("tata")
mailRecipientsArray.add("tata2")
var mailRecipientsList: CURLSList = mailRecipientsArray.to_curlslist
if mailRecipientsList.is_init then 
  print "Array to CURLSList - content: {mailRecipientsList.to_a.to_s}"
  print "Array to CURLSList - length : {mailRecipientsList.to_a.length.to_s}"
  mailRecipientsList.destroy
else
  print "CURLSList to array : CURLSList wrong init"
end
