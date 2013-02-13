module curl
import ffcurl


class Curl



	fun cleanup(curl: nullable FFCurl, fle: nullable FFFile, err: nullable CURLCode):nullable String
	do
		if curl != null then curl.easy_clean

		if fle != null then
			if fle.is_valid then print "here too"
		end

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

		err = dlObj.setopt(new CURLOption.verbose, 0)
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

		if not optFile.close == 0 then 
			cleanup(dlObj, optFile, null)
			return "[ERROR] Unable to close file" 
		end

		dlObj.easy_clean

		return null
	end

end
