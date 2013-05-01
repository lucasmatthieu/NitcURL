module curlunit
import ffcurl


fun errorManager(err: CURLCode) do if not err.is_ok then print err

var curl = new FFCurl.easy_init
if not curl.is_init then print "wrong init"

var error:CURLCode
error = curl.easy_setopt(new CURLOption.url, "http://papercom.fr")
errorManager(error)

error = curl.easy_setopt(new CURLOption.verbose, 1)
errorManager(error)

error = curl.easy_perform
errorManager(error)

var info :nullable CURLInfoResponse 

# Int set
info = curl.easy_getinfo(new CURLInfo.header_size)
assert infoResp:info != null 
if not info.response == null then print "Getinfo :: Header size :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.response_code)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: Response code :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.http_connectcode)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: http_connectcode :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.filetime)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: filetime :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.redirect_count)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: redirect_count :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.request_size)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: request_size :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.ssl_verifyresult)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: ssl_verifyresult :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.httpauth_avail)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: httpauth_avail :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.proxyauth_avail)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: proxyauth_avail :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.os_errno)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: os_errno :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.primary_port)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: primary_port :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.num_connects)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: num_connects :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.local_port)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: local_port :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.lastsocket)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: lastsocket :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.condition_unmet)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: condition_unmet :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.rtsp_client_cseq)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: rtsp_client_cseq :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.rtsp_server_cseq)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: rtsp_server_cseq :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.rtsp_cseq_recv)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: rtsp_cseq_recv :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.total_time)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: total_time :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.namelookup_time)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: namelookup_time :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.connect_time)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: connect_time :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.appconnect_time)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: appconnect_time :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.pretransfer_time)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: pretransfer_time :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.starttransfer_time)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: starttransfer_time :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.redirect_time)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: redirect_time :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.size_upload)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: size_upload :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.size_download)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: size_download :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.speed_download)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: speed_download :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.speed_upload)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: speed_upload :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.content_length_download)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: content_length_download :"+info.response.as(Int).to_s

info = curl.easy_getinfo(new CURLInfo.content_length_upload)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: content_length_upload :"+info.response.as(Int).to_s

# String set
info = curl.easy_getinfo(new CURLInfo.content_type)
assert infoResp:info != null 
if not info.response == null then print "Getinfo :: Content type :"+info.response.as(String)

info = curl.easy_getinfo(new CURLInfo.effective_url)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: Effective url  :"+info.response.as(String)

info = curl.easy_getinfo(new CURLInfo.redirect_url)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: Redirect url :"+info.response.as(String)
	
info = curl.easy_getinfo(new CURLInfo.primary_ip)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: primary_ip :"+info.response.as(String)

info = curl.easy_getinfo(new CURLInfo.local_ip)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: local_ip :"+info.response.as(String)

info = curl.easy_getinfo(new CURLInfo.ftp_entry_path)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: ftp_entry_path :"+info.response.as(String)

info = curl.easy_getinfo(new CURLInfo.private_data)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: private_data :"+info.response.as(String)

info = curl.easy_getinfo(new CURLInfo.rtsp_session_id)
assert infoResp:info != null 
if not info.response == null then print  "Getinfo :: rtsp_session_id :"+info.response.as(String)


