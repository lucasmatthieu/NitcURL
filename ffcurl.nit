module ffcurl


in "C header" `{
	
// INCLUDES

	#include <stdio.h>
	#include <stdlib.h>
	#include <curl/curl.h>
	#include <assert.h>
	/*  #include "Prefix.h" */


// CUSTOM TYPES

	// File infos structure.
	typedef struct scFileInfos {
		FILE *file;
		char *filename;
		char *url;
	} ScFileInfos;
	
	// SELF instance type.
	typedef struct nitCURL {
		CURL *curl;
		void *infos;
	} NitCURL;



`}

in "C body" `{

	// This method allow you to get file name from url path
	// Return pointer to an ScFileInfos struct with correct infos.
	// - YOU got the responsibility to release it.
	ScFileInfos *fileName(char *origPath)
	{
		ScFileInfos *fileInfosStct;
		fileInfosStct = malloc(sizeof(ScFileInfos));
		
		// We store origPath
		int urlLgth = strlen(origPath);
		fileInfosStct->url = malloc((urlLgth+1) * sizeof(char));
		strcpy(fileInfosStct->url, origPath);
		
		

		// Analysing until meet '/'.
		unsigned int orLg= strlen(origPath);
		int i, j; j=0;
		char *preFinal;
		preFinal = malloc(sizeof(char));
	
		for(i=orLg-1; i>=0; i--)
		{
			if(origPath[i] == '/')
			{
				preFinal[j] = '\0';
				break;
			}

			preFinal[j] = origPath[i];
			preFinal = realloc(preFinal, (j+2)*sizeof(char));
			j++;
		}

		// Means that last char was '/'
		if(!j)
		{	
			free(preFinal);
			fileInfosStct->filename = NULL;
			return fileInfosStct;
		}


		// Rebuilding in correct order final str. and 
		// storing into our struct.
		int k, m, l; 
		k=strlen(preFinal);
		m=k;
		fileInfosStct->filename = malloc((k+1)*sizeof(char));
		
		k--;
		for(l=0; l<m; l++)
		{
			fileInfosStct->filename[l]=preFinal[k];
			k--;
		}
		

		// Freeing temporary chars.
		free(preFinal);
		
		return fileInfosStct;
	}



	// Callback method of file downloading
	// 
	static size_t scfile_callback_datawrite( void *buffer, size_t size, size_t nmenb, void *stream )
	{
		ScFileInfos *fileInfos;
		fileInfos = (ScFileInfos*)stream;
		
		if(fileInfos && !fileInfos->file)
		{
			fileInfos->file = fopen(fileInfos->filename, "wb");
			if(!fileInfos->file)
				return -1;
		}

		return fwrite( buffer, size, nmenb, fileInfos->file);
	}


`}	







extern FFCurl `{ NitCURL * `}


	################################
	new easy_init `{

		NitCURL *self;
		self = malloc(sizeof(NitCURL*));
		self->curl = curl_easy_init();

		return self;
	`}
	
	#################################
	fun easy_clean `{
		curl_easy_cleanup( recv->curl );
		//free(recv);
	`}


	################################
	fun easy_setopt(url : String) import String::to_cstring `{
		
		char *tUrl = NULL;
		tUrl = String_to_cstring(url);
		
		ScFileInfos * fileInfos = (ScFileInfos*)fileName(tUrl);


		// Setting target url
		curl_easy_setopt( recv->curl, CURLOPT_URL, fileInfos->url );

		// Setting ON redirection
		curl_easy_setopt( recv->curl, CURLOPT_FOLLOWLOCATION, 1L );

		// Setting callback method
		curl_easy_setopt( recv->curl, CURLOPT_WRITEFUNCTION, scfile_callback_datawrite);
		
		// Giving pointer of file infos struct to get callback
		curl_easy_setopt( recv->curl, CURLOPT_WRITEDATA, fileInfos );

		// Preventing from empty path
		//curl_easy_setopt( recv->curl, CURLOPT_NOBODY, 1L);

	
		recv->infos = fileInfos;
	`}


	
	################################
	#  WARNING : 1 is return for error | 0 is valid execution
	fun easy_perform : Int
	`{		
		CURLcode res;
		res = curl_easy_perform( recv->curl );
		
		/* Error checking */
		if(res != CURLE_OK)
		{
			fprintf(stderr, "curl_easy_perform() failed : %s\n", curl_easy_strerror(res));
			return 1;
		}
		else
			return res;


		ScFileInfos *fileInfos = recv->infos;
		if(fileInfos->file != NULL)
			fclose(fileInfos->file);

	`}




	# ! Others methods
	# - Debugger
	# CURLOPT can be replaced by CURLOPT_DEBUGFUNCTION 
	# and pointer to function to choose which infos we 
	#  want to log.
	fun debugger= (v:Bool) `{ curl_easy_setopt(recv->curl, CURLOPT_VERBOSE, v); `}

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
#	new  `{ return CURLOPT_USERNAME; `}
#	new  `{ return CURLOPT_PASSWORD; `}
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
#	new  `{ return CURLOPT_MAIL_FROM; `}
#	new  `{ return CURLOPT_MAIL_RCPT; `}
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

