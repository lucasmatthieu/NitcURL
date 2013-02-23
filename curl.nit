module curl
import ffcurl


class Curl



	fun cleanup(curl: nullable FFCurl, fle: nullable FFFile, err: nullable CURLCode):nullable String
	do
		if curl != null then curl.easy_clean
		if fle != null then if not fle.clear then return "[ERROR] Something wrong during file cleaning process."
		if err != null then return err.to_s

		return null
	end

	fun get(url: String):nullable String
	do
		var dlObj = new FFCurl.easy_init
		if not dlObj.is_init then return "[ERROR] Unable to init curl"

		var err:CURLCode

		err = dlObj.setopt(new CURLOption.url, url)
		if not err.is_ok then return cleanup(dlObj, null, err)
		
		err = dlObj.setopt(new CURLOption.follow_location, 1)
		if not err.is_ok then return cleanup(dlObj, null, err)

		err = dlObj.setopt(new CURLOption.verbose, 1)
		if not err.is_ok then return cleanup(dlObj, null, err)
		
		var optName = url.basename("")
		var optFile = new FFFile.open(optName.to_cstring)
		if not optFile.is_valid then 
			cleanup(dlObj, optFile, null)
			return "[ERROR] Unable to create file"
		end

		err = dlObj.setopt(new CURLOption.write_data, optFile)
		if not err.is_ok then return cleanup(dlObj, optFile, err)

		err = dlObj.easy_perform
		if not err.is_ok then return cleanup(dlObj, optFile, err)
		
		if not optFile.finish then 
			if not optFile.clean then
				optFile.release
				cleanup(dlObj, null, null)
				return "[ERROR] Unable to close and remove file"
			end
			cleanup(dlObj, null, null)
			return "[ERROR] Unable to close file"
		end

		dlObj.easy_clean

		return null
	end


	fun mail(smtp: String, from: String, to: Array[String], user: String, pwd: String):nullable String
	do
		var dlObj = new FFCurl.easy_init
		if not dlObj.is_init then return "[ERROR] Unable to init curl"

		var err:CURLCode

		err = dlObj.setopt(new CURLOption.url, smtp)
		if not err.is_ok then return cleanup(dlObj, null, err)

		err = dlObj.setopt(new CURLOption.follow_location, 1)
		if not err.is_ok then return cleanup(dlObj, null, err)

		err = dlObj.setopt(new CURLOption.verbose, 1)
		if not err.is_ok then return cleanup(dlObj, null, err)
		# AUTH
		err = dlObj.setopt(new CURLOption.username, user)
		if not err.is_ok then return cleanup(dlObj, null, err)
		
		err = dlObj.setopt(new CURLOption.password, pwd)
		if not err.is_ok then return cleanup(dlObj, null, err)
		
		# INFO
		err = dlObj.setopt(new CURLOption.mail_from, from)
		if not err.is_ok then return cleanup(dlObj, null, err)
		
		err = dlObj.setopt(new CURLOption.mail_rcpt, to)
		if not err.is_ok then return cleanup(dlObj, null, err)


		#err = dlObj.setopt(new CURLOption.write_data, optFile)
		#if not err.is_ok then return cleanup(dlObj, optFile, err)

		err = dlObj.easy_perform
		if not err.is_ok then return cleanup(dlObj, null, err)

		dlObj.easy_clean

		return null
	end


end
