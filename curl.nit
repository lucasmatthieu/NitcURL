module curl
import ffcurl


class Curl

	fun get(url: String)
	do
		var dlObj = new FFCurl.easy_init
		
		dlObj.setopt(new CURLOption.url, url)
		dlObj.setopt(new CURLOption.follow_location, 1)
		dlObj.setopt(new CURLOption.verbose, 1)

		var optFile = new FFFile
		optFile = optFile.open("apache.zip".to_cstring)
		if optFile == null then abort

		dlObj.setopt(new CURLOption.write_data, optFile)
		dlObj.easy_perform

		optFile.close

		dlObj.easy_clean
	end

end
