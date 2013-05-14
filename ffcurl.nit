module ffcurl

in "C header" `{
	#include <stdio.h>
	#include <stdlib.h>
	#include <curl/curl.h>

	typedef enum {
		CURLcallbackTypeHeader,
		CURLcallbackTypeBody,
		CURLcallbackTypeStream
	} CURLcallbackType;

	typedef struct {
		FFCurlCallbacks delegate;
		CURLcallbackType type;
	} CURLCallbackDatas;
`}

in "C body" `{
	size_t nit_curl_callback_func(void *buffer, size_t size, size_t count, CURLCallbackDatas *datas){
		char *line_c = (char*)buffer;
		String line_o = new_String_from_cstring(line_c);
		switch(datas->type){
			case CURLcallbackTypeHeader:
				FFCurlCallbacks_header_callback(datas->delegate, line_o);
				break;
			case CURLcallbackTypeBody:
				FFCurlCallbacks_body_callback(datas->delegate, line_o);
				break;
			case CURLcallbackTypeStream:
				FFCurlCallbacks_stream_callback(datas->delegate, line_o, size, count);
				break;
			default:
				break;
		}
		return count;
	}
`}

extern FFCurl `{ CURL * `}
	# Lifetime
	new easy_init `{ return curl_easy_init(); `}
	fun is_init:Bool `{ return (recv != NULL); `}
	fun easy_clean `{ curl_easy_cleanup( recv ); `}
	fun easy_perform:CURLCode `{ return curl_easy_perform( recv ); `}	

	# Set options
	fun easy_setopt(opt: CURLOption, obj: Object):CURLCode
	do
		if obj isa Int then return i_setopt_int(opt, obj)
		if obj isa Bool and obj == true then return i_setopt_int(opt, 1)
		if obj isa Bool and obj == false then return i_setopt_int(opt, 0)
		if obj isa String then return i_setopt_string(opt, obj)
		if obj isa OFile then return i_setopt_file(opt, obj)
    return once new CURLCode.unknown_option
	end
	private fun i_setopt_file(opt: CURLOption, fl: OFile):CURLCode `{ return curl_easy_setopt( recv, opt, fl); `}
	private fun i_setopt_int(opt: CURLOption, num: Int):CURLCode `{ return curl_easy_setopt( recv, opt, num); `}
	private fun i_setopt_string(opt: CURLOption, str: String):CURLCode import String::to_cstring `{
		char *rStr = String_to_cstring(str);
		return curl_easy_setopt( recv, opt, rStr);
	`}

	# Get infos
  # Chars
  fun easy_getinfo_chars(opt: CURLInfoChars):nullable CURLInfoResponseString
  do
     var answ = new CURLInfoResponseString
     if not i_getinfo_chars(opt, answ).is_ok then return null
     return answ
  end
	private fun i_getinfo_chars(opt: CURLInfoChars, res: CURLInfoResponseString):CURLCode import CURLInfoResponseString::response= `{
		char *r = NULL;
    CURLcode c = curl_easy_getinfo( recv, opt, &r);
    if((c == CURLE_OK) && r != NULL){
      String ro = new_String_from_cstring(r);
	  	CURLInfoResponseString_response__assign( res, ro);
    }
		return c;
	`}
  # Long
  fun easy_getinfo_long(opt: CURLInfoLong):nullable CURLInfoResponseLong
  do
     var answ = new CURLInfoResponseLong
     if not i_getinfo_long(opt, answ).is_ok then return null
     return answ
  end
	private fun i_getinfo_long(opt: CURLInfoLong, res: CURLInfoResponseLong):CURLCode import CURLInfoResponseLong::response= `{
		long *r = NULL;
    r = malloc(sizeof(long));
    CURLcode c = curl_easy_getinfo( recv, opt, r);
    if((c == CURLE_OK) && r != NULL) CURLInfoResponseLong_response__assign( res, (long)*r);
    free(r);
    return c;
	`}
  # Double
  fun easy_getinfo_double(opt: CURLInfoDouble):nullable CURLInfoResponseDouble
  do
     var answ = new CURLInfoResponseDouble
     if not i_getinfo_double(opt, answ).is_ok then return null
     return answ
  end
  private fun i_getinfo_double(opt: CURLInfoDouble, res: CURLInfoResponseDouble):CURLCode import CURLInfoResponseDouble::response= `{
    double *r = NULL;
    r = malloc(sizeof(double));
    CURLcode c = curl_easy_getinfo( recv, opt, r);
    if((c == CURLE_OK) && r != NULL) CURLInfoResponseDouble_response__assign( res, (double)*r);
    free(r);
    return c;
	`}
  # SList
  fun easy_getinfo_slist(opt: CURLInfoSList):nullable CURLInfoResponseSList
  do
    var slist = new CURLSList
    if not i_getinfo_slist(opt, slist).is_ok then return null
    var resp =  new CURLInfoResponseSList(slist)
    #slist.destroy
    return resp
  end
  private fun i_getinfo_slist(opt: CURLInfoSList, answ: CURLSList):CURLCode `{
    return curl_easy_getinfo( recv, opt, answ);
  `}

	# Register delegate callback
	fun register_callback(delegate: FFCurlCallbacks, cbtype: CURLCallbackType):CURLCode
	do
		if cbtype == once new CURLCallbackType.header then
			return i_callback_register(delegate, cbtype)
		else if cbtype == once new CURLCallbackType.body then
			return i_callback_register(delegate, cbtype)
		else if cbtype == once new CURLCallbackType.stream then
			return i_callback_register(delegate, cbtype)
		end
		return once new CURLCode.unknown_option
	end
	private fun i_callback_register(delegate: FFCurlCallbacks, cbtype: CURLCallbackType):CURLCode is extern import FFCurlCallbacks::header_callback,  FFCurlCallbacks::body_callback, FFCurlCallbacks::stream_callback  `{
    CURLCallbackDatas *d = malloc(sizeof(CURLCallbackDatas));
    FFCurlCallbacks_incr_ref(delegate);
    d->type = cbtype;
    d->delegate = delegate;
    CURLcode e;
    switch(cbtype){
      case CURLcallbackTypeHeader:
        e = curl_easy_setopt( recv, CURLOPT_HEADERFUNCTION, &nit_curl_callback_func);
        if(e != CURLE_OK) return e;
        e = curl_easy_setopt( recv, CURLOPT_WRITEHEADER, d);
      break;
      case CURLcallbackTypeBody:
      case CURLcallbackTypeStream:
        e = curl_easy_setopt( recv, CURLOPT_WRITEFUNCTION, &nit_curl_callback_func);
        if(e != CURLE_OK) return e;
        e = curl_easy_setopt( recv, CURLOPT_WRITEDATA, d);
      break;
      default:
      break;
    }
    return e;
  `}
end

extern OFile `{ FILE* `}
  new open(str: NativeString) `{ return fopen(str, "wb"); `}
  fun is_valid:Bool `{ return recv != NULL; `}
  private fun n_write(buffer: NativeString, size: Int, count: Int):Int `{ return fwrite(buffer, size, count, recv); `}
  fun write(buffer: String, size: Int, count: Int):Int
  do
    if not is_valid == false then return n_write(buffer.to_cstring, size, count)
    return 0
  end
  private fun n_close:Int `{ return fclose(recv); `}
  fun close:Bool
  do 
    if not is_valid == false then return n_close == 0
    return false
  end
end

interface FFCurlCallbacks
  fun header_callback(line: String) is abstract
  fun body_callback(line: String) is abstract
  fun stream_callback(buffer: String, size: Int, count: Int) is abstract
end
extern CURLCallbackType `{ CURLcallbackType `}
  new header `{ return CURLcallbackTypeHeader; `}
  new body `{ return CURLcallbackTypeBody; `}
  new stream `{ return CURLcallbackTypeStream; `}
  fun to_i:Int `{ return recv; `} 
end

extern CURLCode `{ CURLcode `}
  new unknown_option `{ return CURLE_UNKNOWN_OPTION; `}
	fun code:Int `{ return recv; `}
	fun is_ok:Bool `{ return recv == CURLE_OK; `}
	fun is_valid_protocol:Bool `{  return recv == CURLE_UNSUPPORTED_PROTOCOL; `}
	fun is_valid_init:Bool `{ return recv == CURLE_FAILED_INIT; `}
	redef fun to_s do return code.to_s end
end

extern CURLSList `{ struct curl_slist * `}
  new `{ 
    struct curl_slist *l = NULL;
    l = malloc(sizeof(struct curl_slist));
    l->data = NULL;
    l->next = NULL;
    return l; 
  `}
  fun is_init:Bool `{ return (recv != NULL); `}
  fun append(key: String) import String::to_cstring `{
     char *k = String_to_cstring(key);
     recv = curl_slist_append(recv, k);
  `}
  private fun i_data_reachable(c: CURLSList):Bool `{ return (c != NULL && c->data != NULL); `}
  private fun i_next_reachable(c: CURLSList):Bool `{ return (c != NULL && c->next != NULL); `}
  private fun i_data(c: CURLSList):String `{ return new_String_from_cstring(c->data); `}
  private fun i_next(c: CURLSList):CURLSList `{ return c->next; `}
  fun to_array:Array[String]
  do
    var r = new Array[String]
    if not is_init == true then return r
    if not i_next_reachable(self) == true then return r
    var current = i_next(self)
    loop
      if not i_data_reachable(current) == true then break
      r.add(i_data(current))
      current = i_next(current)
    end
    return r
  end
  fun destroy `{ curl_slist_free_all(recv); `}
end

class CURLInfoResponseSList
  var response:CURLSList
end
class CURLInfoResponseLong
  var response:Int=0
end
class CURLInfoResponseDouble
  var response:Int=0
end
class CURLInfoResponseString
  var response:String = ""
end
extern CURLInfoSList `{ CURLINFO `}
  new ssl_engines `{ return CURLINFO_SSL_ENGINES; `}
  new cookielist `{ return CURLINFO_COOKIELIST; `}
end
extern CURLInfoLong `{ CURLINFO `}
  new response_code `{ return CURLINFO_RESPONSE_CODE; `}
  new header_size `{ return CURLINFO_HEADER_SIZE; `}
  new http_connectcode `{ return CURLINFO_HTTP_CONNECTCODE; `}
  new filetime `{ return CURLINFO_FILETIME; `}
  new redirect_count `{ return CURLINFO_REDIRECT_COUNT; `}
  new request_size `{ return CURLINFO_REQUEST_SIZE; `}
  new ssl_verifyresult `{ return CURLINFO_SSL_VERIFYRESULT; `}
  new httpauth_avail `{ return CURLINFO_HTTPAUTH_AVAIL; `}
  new proxyauth_avail `{ return CURLINFO_PROXYAUTH_AVAIL; `}
  new os_errno `{ return CURLINFO_OS_ERRNO; `}
  new num_connects `{ return CURLINFO_NUM_CONNECTS; `}
  new primary_port `{ return CURLINFO_PRIMARY_PORT; `}
  new local_port `{ return CURLINFO_LOCAL_PORT; `}
  new lastsocket `{ return CURLINFO_LASTSOCKET; `}
  new condition_unmet `{ return CURLINFO_CONDITION_UNMET; `}
  new rtsp_client_cseq `{ return CURLINFO_RTSP_CLIENT_CSEQ; `}
  new rtsp_server_cseq `{ return CURLINFO_RTSP_SERVER_CSEQ; `}
  new rtsp_cseq_recv `{ return CURLINFO_RTSP_CSEQ_RECV; `}
end
extern CURLInfoDouble `{ CURLINFO `}
  new total_time `{ return CURLINFO_TOTAL_TIME; `}
  new namelookup_time `{ return CURLINFO_NAMELOOKUP_TIME; `}
  new connect_time `{ return CURLINFO_CONNECT_TIME; `}
  new appconnect_time `{ return CURLINFO_APPCONNECT_TIME; `}
  new pretransfer_time `{ return CURLINFO_PRETRANSFER_TIME; `}
  new starttransfer_time `{ return CURLINFO_STARTTRANSFER_TIME; `}
  new redirect_time `{ return CURLINFO_REDIRECT_TIME; `}
  new size_upload `{ return CURLINFO_SIZE_UPLOAD; `}
  new size_download `{ return CURLINFO_SIZE_DOWNLOAD; `}
  new speed_download `{ return CURLINFO_SPEED_DOWNLOAD; `}
  new speed_upload `{ return CURLINFO_SPEED_UPLOAD; `}
  new content_length_download `{ return CURLINFO_CONTENT_LENGTH_DOWNLOAD; `}
  new content_length_upload `{ return CURLINFO_CONTENT_LENGTH_UPLOAD; `}
end
extern CURLInfoChars `{ CURLINFO `}
	new content_type `{ return CURLINFO_CONTENT_TYPE; `}
  new effective_url `{ return CURLINFO_EFFECTIVE_URL; `}
  new redirect_url `{ return CURLINFO_REDIRECT_URL; `}
  new primary_ip `{ return CURLINFO_PRIMARY_IP; `}
  new local_ip `{ return CURLINFO_LOCAL_IP; `}
  new ftp_entry_path `{ return CURLINFO_FTP_ENTRY_PATH; `}
  new rtsp_session_id `{ return CURLINFO_RTSP_SESSION_ID; `}
  new private_data `{ return CURLINFO_PRIVATE; `}
end

extern CURLStatusCode `{ int `}
	new proceed `{ return 100; `}
	new switching_protocols `{ return 101; `}
	new ok `{ return 200; `}
	new created `{ return 201; `}
	new accepted `{ return 202; `}
	new non_authoritative_information `{ return 203; `}
	new no_content `{ return 204; `}
	new reset_content `{ return 205; `}
	new partial_content `{ return 206; `}
	new multiple_choices `{ return 300; `}
	new moved_permanently `{ return 301; `}
	new moved_temporarily `{ return 302; `}
	new see_other `{ return 303; `}
	new not_modified `{ return 304; `}
	new use_proxy `{ return 305; `}
	new bad_request `{ return 400; `}
	new unauthorized `{ return 401; `}
	new payment_required `{ return 402; `}
	new forbidden `{ return 403; `}
	new not_found `{ return 404; `}
	new method_not_allowed `{ return 405; `}
	new not_acceptable `{ return 406; `}
	new proxy_authentication_required `{ return 407; `}
	new request_timeout `{ return 408; `}
	new conflict `{ return 409; `}
	new gone `{ return 410; `}
	new length_required `{ return 411; `}
	new precondition_failed `{ return 412; `}
	new request_entity_too_large `{ return 413; `}
	new request_uri_too_large `{ return 414; `}
	new unsupported_media_type `{ return 415; `}
	new internal_server_error `{ return 500; `}
	new not_implemented `{ return 501; `}
	new bad_gateway `{ return 502; `}
	new service_unavailable `{ return 503; `}
	new gateway_timeout `{ return 504; `}
	new http_version_not_supported `{ return 505; `}
	fun to_i:Int `{ return recv; `} 
end
extern CURLOption `{ CURLoption `}
	new write_function `{ return CURLOPT_WRITEFUNCTION; `}
	new write_data `{ return CURLOPT_WRITEDATA; `}
#	new  `{ return CURLOPT_FILE; `}
	new url `{ return CURLOPT_URL; `}
#	new  `{ return CURLOPT_PORT; `}
#	new  `{ return CURLOPT_PROXY; `}
#	new  `{ return CURLOPT_USERPWD; `}
#	new  `{ return CURLOPT_PROXYUSERPWD; `}
#	new  `{ return CURLOPT_RANGE; `}
#	new  `{ return CURLOPT_INFILE; `}
#	new  `{ return CURLOPT_ERRORBUFFER; `}
#	new  `{ return CURLOPT_WRITEFUNCTION; `}
#	new  `{ return CURLOPT_READFUNCTION; `}
#	new  `{ return CURLOPT_TIMEOUT; `}
#	new  `{ return CURLOPT_INFILESIZE; `}
#	new  `{ return CURLOPT_POSTFIELDS; `}
#	new  `{ return CURLOPT_REFERER; `}
#	new  `{ return CURLOPT_FTPPORT; `}
#	new  `{ return CURLOPT_USERAGENT; `}
#	new  `{ return CURLOPT_LOW_SPEED_LIMIT; `}
#	new  `{ return CURLOPT_LOW_SPEED_TIME; `}
#	new  `{ return CURLOPT_RESUME_FROM; `}
#	new  `{ return CURLOPT_COOKIE; `}
#	new  `{ return CURLOPT_HTTPHEADER; `}
#	new  `{ return CURLOPT_HTTPPOST; `}
#	new  `{ return CURLOPT_SSLCERT; `}
#	new  `{ return CURLOPT_KEYPASSWD; `}
#	new  `{ return CURLOPT_CRLF; `}
#	new  `{ return CURLOPT_QUOTE; `}
#	new  `{ return CURLOPT_WRITEHEADER; `}
#	new  `{ return CURLOPT_COOKIEFILE; `}
#	new  `{ return CURLOPT_SSLVERSION; `}
#	new  `{ return CURLOPT_TIMECONDITION; `}
#	new  `{ return CURLOPT_TIMEVALUE; `}
#	new  `{ return CURLOPT_CUSTOMREQUEST; `}
#	new  `{ return CURLOPT_STDERR; `}
#	new  `{ return CURLOPT_POSTQUOTE; `}
#	new  `{ return CURLOPT_WRITEINFO; `} /* DEPRECATED, do not use! */
	new verbose `{ return CURLOPT_VERBOSE; `}      # talk a lot
	new header `{ return CURLOPT_HEADER; `}       # throw the header out too
	new no_progress `{ return CURLOPT_NOPROGRESS; `}   # shut off the progress meter
	new no_body `{ return CURLOPT_NOBODY; `}       # use HEAD to get http document
	new fail_on_error `{ return CURLOPT_FAILONERROR; `}  # no output on http error codes >= 300
	new upload `{ return CURLOPT_UPLOAD; `}       # this is an upload
	new post `{ return CURLOPT_POST; `}         # HTTP POST method
	new dir_list_only `{ return CURLOPT_DIRLISTONLY; `}  # bare names when listing directories
	new append `{ return CURLOPT_APPEND; `}       # Append instead of overwrite on upload!
#	new  `{ return CURLOPT_NETRC; `}
	new follow_location `{ return CURLOPT_FOLLOWLOCATION; `}  # use Location: Luke!
	new transfert_text `{ return CURLOPT_TRANSFERTEXT; `} # transfer data in text/ASCII format
	new put `{ return CURLOPT_PUT; `}          # HTTP PUT */
#	new  `{ return CURLOPT_PROGRESSFUNCTION; `}
#	new  `{ return CURLOPT_PROGRESSDATA; `}
#	new  `{ return CURLOPT_AUTOREFERER; `}
#	new  `{ return CURLOPT_PROXYPORT; `}
#	new  `{ return CURLOPT_POSTFIELDSIZE; `}
#	new  `{ return CURLOPT_HTTPPROXYTUNNEL; `}
#	new  `{ return CURLOPT_INTERFACE; `}
#	new  `{ return CURLOPT_KRBLEVEL; `}
#	new  `{ return CURLOPT_SSL_VERIFYPEER; `}
#	new  `{ return CURLOPT_CAINFO; `}
#	new  `{ return CURLOPT_MAXREDIRS; `}
#	new  `{ return CURLOPT_FILETIME; `}
#	new  `{ return CURLOPT_TELNETOPTIONS; `}
#	new  `{ return CURLOPT_MAXCONNECTS; `}
#	new  `{ return CURLOPT_CLOSEPOLICY; `} /* DEPRECATED, do not use! */
#	new  `{ return CURLOPT_FRESH_CONNECT; `}
#	new  `{ return CURLOPT_FORBID_REUSE; `}
#	new  `{ return CURLOPT_RANDOM_FILE; `}
#	new  `{ return CURLOPT_EGDSOCKET; `}
#	new  `{ return CURLOPT_CONNECTTIMEOUT; `}
#	new  `{ return CURLOPT_HEADERFUNCTION; `}
#	new  `{ return CURLOPT_HTTPGET; `}
#	new  `{ return CURLOPT_SSL_VERIFYHOST; `}
#	new  `{ return CURLOPT_COOKIEJAR; `}
#	new  `{ return CURLOPT_SSL_CIPHER_LIST; `}
#	new  `{ return CURLOPT_HTTP_VERSION; `}
#	new  `{ return CURLOPT_FTP_USE_EPSV; `}
#	new  `{ return CURLOPT_SSLCERTTYPE; `}
#	new  `{ return CURLOPT_SSLKEY; `}
#	new  `{ return CURLOPT_SSLKEYTYPE; `}
#	new  `{ return CURLOPT_SSLENGINE; `}
#	new  `{ return CURLOPT_SSLENGINE_DEFAULT; `}
#	new  `{ return CURLOPT_DNS_USE_GLOBAL_CACHE; `} /* DEPRECATED, do not use! */
#	new  `{ return CURLOPT_DNS_CACHE_TIMEOUT; `}
#	new  `{ return CURLOPT_PREQUOTE; `}
#	new  `{ return CURLOPT_DEBUGFUNCTION; `}
#	new  `{ return CURLOPT_DEBUGDATA; `}
#	new  `{ return CURLOPT_COOKIESESSION; `}
#	new  `{ return CURLOPT_CAPATH; `}
#	new  `{ return CURLOPT_BUFFERSIZE; `}
#	new  `{ return CURLOPT_NOSIGNAL; `}
#	new  `{ return CURLOPT_SHARE; `}
#	new  `{ return CURLOPT_PROXYTYPE; `}
#	new  `{ return CURLOPT_ACCEPT_ENCODING; `}
#	new  `{ return CURLOPT_PRIVATE; `}
#	new  `{ return CURLOPT_HTTP200ALIASES; `}
#	new  `{ return CURLOPT_UNRESTRICTED_AUTH; `}
#	new  `{ return CURLOPT_FTP_USE_EPRT; `}
#	new  `{ return CURLOPT_HTTPAUTH; `}
#	new  `{ return CURLOPT_SSL_CTX_FUNCTION; `}
#	new  `{ return CURLOPT_SSL_CTX_DATA; `}
#	new  `{ return CURLOPT_FTP_CREATE_MISSING_DIRS; `}
#	new  `{ return CURLOPT_PROXYAUTH; `}
#	new  `{ return CURLOPT_FTP_RESPONSE_TIMEOUT; `}
#	new  `{ return CURLOPT_IPRESOLVE; `}
#	new  `{ return CURLOPT_MAXFILESIZE; `}
#	new  `{ return CURLOPT_INFILESIZE_LARGE; `}
#	new  `{ return CURLOPT_RESUME_FROM_LARGE; `}
#	new  `{ return CURLOPT_MAXFILESIZE_LARGE; `}
#	new  `{ return CURLOPT_NETRC_FILE; `}
#	new  `{ return CURLOPT_USE_SSL; `}
#	new  `{ return CURLOPT_POSTFIELDSIZE_LARGE; `}
#	new  `{ return CURLOPT_TCP_NODELAY; `}
#	new  `{ return CURLOPT_FTPSSLAUTH; `}
#	new  `{ return CURLOPT_IOCTLFUNCTION; `}
#	new  `{ return CURLOPT_IOCTLDATA; `}
#	new  `{ return CURLOPT_FTP_ACCOUNT; `}
#	new  `{ return CURLOPT_COOKIELIST; `}
#	new  `{ return CURLOPT_IGNORE_CONTENT_LENGTH; `}
#	new  `{ return CURLOPT_FTP_SKIP_PASV_IP; `}
#	new  `{ return CURLOPT_FTP_FILEMETHOD; `}
#	new  `{ return CURLOPT_LOCALPORT; `}
#	new  `{ return CURLOPT_LOCALPORTRANGE; `}
#	new  `{ return CURLOPT_CONNECT_ONLY; `}
#	new  `{ return CURLOPT_CONV_FROM_NETWORK_FUNCTION; `}
#	new  `{ return CURLOPT_CONV_TO_NETWORK_FUNCTION; `}
#	new  `{ return CURLOPT_CONV_FROM_UTF8_FUNCTION; `}
#	new  `{ return CURLOPT_MAX_SEND_SPEED_LARGE; `}
#	new  `{ return CURLOPT_MAX_RECV_SPEED_LARGE; `}
#	new  `{ return CURLOPT_FTP_ALTERNATIVE_TO_USER; `}
#	new  `{ return CURLOPT_SOCKOPTFUNCTION; `}
#	new  `{ return CURLOPT_SOCKOPTDATA; `}
#	new  `{ return CURLOPT_SSL_SESSIONID_CACHE; `}
#	new  `{ return CURLOPT_SSH_AUTH_TYPES; `}
#	new  `{ return CURLOPT_SSH_PUBLIC_KEYFILE; `}
#	new  `{ return CURLOPT_SSH_PRIVATE_KEYFILE; `}
#	new  `{ return CURLOPT_FTP_SSL_CCC; `}
#	new  `{ return CURLOPT_TIMEOUT_MS; `}
#	new  `{ return CURLOPT_CONNECTTIMEOUT_MS; `}
#	new  `{ return CURLOPT_HTTP_TRANSFER_DECODING; `}
#	new  `{ return CURLOPT_HTTP_CONTENT_DECODING; `}
#	new  `{ return CURLOPT_NEW_FILE_PERMS; `}
#	new  `{ return CURLOPT_NEW_DIRECTORY_PERMS; `}
#	new  `{ return CURLOPT_POSTREDIR; `}
#	new  `{ return CURLOPT_SSH_HOST_PUBLIC_KEY_MD5; `}
#	new  `{ return CURLOPT_OPENSOCKETFUNCTION; `}
#	new  `{ return CURLOPT_OPENSOCKETDATA; `}
#	new  `{ return CURLOPT_COPYPOSTFIELDS; `}
#	new  `{ return CURLOPT_PROXY_TRANSFER_MODE; `}
#	new  `{ return CURLOPT_SEEKFUNCTION; `}
#	new  `{ return CURLOPT_SEEKDATA; `}
#	new  `{ return CURLOPT_CRLFILE; `}
#	new  `{ return CURLOPT_ISSUERCERT; `}
#	new  `{ return CURLOPT_ADDRESS_SCOPE; `}
#	new  `{ return CURLOPT_CERTINFO; `}
	new  username `{ return CURLOPT_USERNAME; `}
	new  password `{ return CURLOPT_PASSWORD; `}
#	new  `{ return CURLOPT_PROXYUSERNAME; `}
#	new  `{ return CURLOPT_PROXYPASSWORD; `}
#	new  `{ return CURLOPT_NOPROXY; `}
#	new  `{ return CURLOPT_TFTP_BLKSIZE; `}
#	new  `{ return CURLOPT_SOCKS5_GSSAPI_SERVICE; `}
#	new  `{ return CURLOPT_SOCKS5_GSSAPI_NEC; `}
#	new  `{ return CURLOPT_PROTOCOLS; `}
#	new  `{ return CURLOPT_REDIR_PROTOCOLS; `}
#	new  `{ return CURLOPT_SSH_KNOWNHOSTS; `}
#	new  `{ return CURLOPT_SSH_KEYFUNCTION; `}
#	new  `{ return CURLOPT_SSH_KEYDATA; `}
	new  mail_from `{ return CURLOPT_MAIL_FROM; `}
	new  mail_rcpt `{ return CURLOPT_MAIL_RCPT; `}
#	new  `{ return CURLOPT_FTP_USE_PRET; `}
#	new  `{ return CURLOPT_RTSP_REQUEST; `}
#	new  `{ return CURLOPT_RTSP_SESSION_ID; `}
#	new  `{ return CURLOPT_RTSP_STREAM_URI; `}
#	new  `{ return CURLOPT_RTSP_TRANSPORT; `}
#	new  `{ return CURLOPT_RTSP_CLIENT_CSEQ; `}
#	new  `{ return CURLOPT_RTSP_SERVER_CSEQ; `}
#	new  `{ return CURLOPT_INTERLEAVEDATA; `}
#	new  `{ return CURLOPT_INTERLEAVEFUNCTION; `}
#	new  `{ return CURLOPT_WILDCARDMATCH; `}
#	new  `{ return CURLOPT_CHUNK_BGN_FUNCTION; `}
#	new  `{ return CURLOPT_CHUNK_END_FUNCTION; `}
#	new  `{ return CURLOPT_FNMATCH_FUNCTION; `}
#	new  `{ return CURLOPT_CHUNK_DATA; `}
#	new  `{ return CURLOPT_FNMATCH_DATA; `}
#	new  `{ return CURLOPT_RESOLVE; `}
#	new  `{ return CURLOPT_TLSAUTH_USERNAME; `}
#	new  `{ return CURLOPT_TLSAUTH_PASSWORD; `}
#	new  `{ return CURLOPT_TLSAUTH_TYPE; `}
#	new  `{ return CURLOPT_TRANSFER_ENCODING; `}
#	new  `{ return CURLOPT_CLOSESOCKETFUNCTION; `}
#	new  `{ return CURLOPT_CLOSESOCKETDATA; `}
#	new  `{ return CURLOPT_GSSAPI_DELEGATION; `}
#	new  `{ return CURLOPT_DNS_SERVERS; `}
#	new  `{ return CURLOPT_ACCEPTTIMEOUT_MS; `}
#	new  `{ return CURLOPT_TCP_KEEPALIVE; `}
#	new  `{ return CURLOPT_TCP_KEEPIDLE; `}
#	new  `{ return CURLOPT_TCP_KEEPINTVL; `}
#	new  `{ return CURLOPT_SSL_OPTIONS; `}
#	new  `{ return CURLOPT_MAIL_AUTH; `}
end
