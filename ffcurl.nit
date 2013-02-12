module ffcurl


in "C header" `{
	
// INCLUDES

	#include <stdio.h>
	#include <stdlib.h>
	#include <curl/curl.h>
	#include <assert.h>
	/*  #include "Prefix.h" */


// CUSTOM TYPES

	/* // File infos structure.
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
	*/


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
	static size_t callback_write_todisk( void *buffer, size_t size, size_t nmenb, void *stream)
	{
		FILE *tgFile;
		tgFile = (FILE*)stream;
		
		if(!tgFile)
			return -1;

		return fwrite( buffer, size, nmenb, tgFile);
	}


`}	



extern FFFile `{ FILE* `}

	new `{
		return self=NULL;
	`}


	fun open(str: CString): FFFile `{

		self = fopen(str, "wb");
		if(!self)
			return NULL;

		return self;
	`}


	fun close `{
		if(self != NULL)
			fclose(self);
	`}

end


extern FFCurl `{ CURL * `}


	################################
	new easy_init `{

		CURL *self;
		self = curl_easy_init();
		return self;
	`}
	
	#################################
	fun easy_clean `{
		curl_easy_cleanup( recv );
		//free(recv);
	`}





	fun setopt(opt: CURLOption, obj: Object)
	do
		if obj.isa(Int)
		then
			i_setopt_int(opt, obj.as(Int))
		else if obj.isa(String)
		then
			i_setopt_string(opt, obj.as(String))
		else if obj.isa(FFFile)
		then
			i_setopt_file(opt, obj.as(FFFile))
		else
			abort
		end
	end


	fun i_setopt_int(opt: CURLOption, num: Int) `{	
		curl_easy_setopt( recv, opt, num);
	`}

	fun i_setopt_string(opt: CURLOption, str: String) import String::to_cstring `{
		char *rStr = NULL;
		rStr = String_to_cstring(str);
		curl_easy_setopt( recv, opt, rStr);
	`}

	fun i_setopt_file(opt: CURLOption,fl: FFFile) `{
		curl_easy_setopt( recv, opt, (FILE*)fl);
	`}


	fun f_setopt_writetodisk_callback `{
		curl_easy_setopt( recv, CURLOPT_WRITEFUNCTION, callback_write_todisk);
	`}


	
	################################
	#  WARNING : 1 is return for error | 0 is valid execution
	fun easy_perform : Int
	`{		
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




end

