module curl


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


#extern FileInfos `{ struct ScFileInfos* `} 

extern CURL `{ NitCURL * `}


	################################

	#fun CURLE_OK : Int do return once ( CURLE_OK_intern )
	#private fun CURLE_OK_intern : Int `{ return CURLE_OK; `}
	


	################################
	new easy_init `{

		NitCURL *self;
		self = malloc(sizeof(NitCURL*));
		self->curl = curl_easy_init();

		return self;
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

	
	#################################
	fun easy_clean `{
		curl_easy_cleanup( recv->curl );
		//free(recv);
	`}






	fun get(address: String)
	do

	# TO BE COMPLETED

	end



	# ! Others methods
	# - Debugger
	fun debugger(dbg : Bool) `{
		
		/* CURLOPT can be replaced by CURLOPT_DEBUGFUNCTION 
		* and pointer to function to choose which infos we 
		* want to log.
		*/
		if(dbg) curl_easy_setopt( recv->curl, CURLOPT_VERBOSE, 1L);
		else curl_easy_setopt( recv->curl, CURLOPT_VERBOSE, 0L);

	`}


end

