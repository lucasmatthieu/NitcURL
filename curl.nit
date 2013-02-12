module curl
import ffcurl



class Curl

	fun get(url: String)
	do
		var dlObj = new FFCurl.easy_init
		dlObj.easy_setopt(url)
		dlObj.debugger=true
		dlObj.easy_perform
		dlObj.easy_clean
	end

end
