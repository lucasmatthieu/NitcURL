
module curl


in "C header" `{
	
		#include <stdio.h>
		#include <stdlib.h>
		#include <curl/curl.h>
		/*  #include "Prefix.h" */

`}



extern CURL `{ CURL * `}

	new easy_init `{

		CURL * self = NULL;
		self = curl_easy_init();
		return self;
	
	`}	


	fun easy_setopt(url : String) import String::to_cstring `{

		char * r_url = NULL;
		r_url = String_to_cstring(url);

		curl_easy_setopt( recv, CURLOPT_URL, r_url); /* check for CURLE_UNSUPPORTED_PROTOCOL */

	`}


	# WARNING : 1 is return for error | 0 is valid execution
	fun easy_perform : Int `{

		CURLcode res;
		res = curl_easy_perform( recv );
		
		/* Error checking */
		if(res != CURLE_OK)
		{
			fprintf(stderr, "curl_easy_perform() failed : %s\n", curl_easy_strerror(res));
			return 1;
		}
		else
			return res;

	`}


	fun easy_cleanup `{

		curl_easy_cleanup( recv );

	`}

end


# Initializing curl obj
var webObj = new CURL.easy_init

# Setting option to request
webObj.easy_setopt("http://papercom.fr")

# Launching request
webObj.easy_perform

# Cleaning curl obj
webObj.easy_cleanup



