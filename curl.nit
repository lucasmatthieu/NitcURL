module curl
import ffcurl

class Curl
	super FFCurlCallbacks

	var verbose:Bool writable
	var status_code:nullable Int
	var body_str:String
	var headers:nullable HashMap[String, String]
  var speed_download:nullable Int
  var size_download:nullable Int
  var total_time:nullable Int
	private var i_file:nullable OFile

	init 
	do
		status_code=null
		body_str=""
		verbose=false
		headers=null
    speed_download=null
    size_download=null
    total_time=null
		i_file=null
	end

	# Cleaning
	fun cleanup(curl: nullable FFCurl, fle: nullable OFile, err: nullable CURLCode):nullable String
	do
		if curl != null then curl.easy_clean
		if fle != null then if not fle.close then return "[ERROR] Something wrong while trying to close the file."
		if err != null then return err.to_s
		return null
	end

	# Behaviors
	fun get(url: String):nullable String
	do
		var dlObj = new FFCurl.easy_init
		if not dlObj.is_init then return "[ERROR] Unable to init curl"

		var err:CURLCode

		err = dlObj.easy_setopt(new CURLOption.url, url)
		if not err.is_ok then return cleanup(dlObj, null, err)
		
		err = dlObj.easy_setopt(new CURLOption.follow_location, 1)
		if not err.is_ok then return cleanup(dlObj, null, err)

		err = dlObj.easy_setopt(new CURLOption.verbose, self.verbose)
		if not err.is_ok then return cleanup(dlObj, null, err)
		
		err = dlObj.register_callback(self, new CURLCallbackType.header)
		if not err.is_ok then return cleanup(dlObj, null, err)

		err = dlObj.register_callback(self, new CURLCallbackType.body)
		if not err.is_ok then return cleanup(dlObj, null, err)

		err = dlObj.easy_perform
		if not err.is_ok then return cleanup(dlObj, null, err)

    var st_code = dlObj.easy_getinfo_long(new CURLInfoLong.response_code)
		if not st_code == null then self.status_code = st_code.response

		cleanup(dlObj, null, null)

		return null
	end

	fun download(url: String, output_name: nullable String):nullable String
	do
		var dlObj = new FFCurl.easy_init
		if not dlObj.is_init then return "[ERROR] Unable to init curl"

		var err:CURLCode
		
		err = dlObj.easy_setopt(new CURLOption.url, url)
		if not err.is_ok then return cleanup(dlObj, null, err)

		err = dlObj.easy_setopt(new CURLOption.follow_location, 1)
		if not err.is_ok then return cleanup(dlObj, null, err)

		err = dlObj.easy_setopt(new CURLOption.verbose, self.verbose)
		if not err.is_ok then return cleanup(dlObj, null, err)

		var optName:nullable String
		if not output_name == null then 
			optName = output_name
		else if not url.substring(url.length-1, url.length) == "/" then
			optName = url.basename("") 
		else
			cleanup(dlObj, null, null)
			return "[ERROR] Unable to treat url to get basename"
		end

		self.i_file = new OFile.open(optName.to_cstring)
		if not self.i_file.is_valid then 
			cleanup(dlObj, self.i_file, null)
			return "[ERROR] Unable to create file"
		end

		err = dlObj.register_callback(self, new CURLCallbackType.header)
		if not err.is_ok then return cleanup(dlObj, self.i_file, err)

		err = dlObj.register_callback(self, new CURLCallbackType.stream)
		if not err.is_ok then return cleanup(dlObj, self.i_file, err)

		err = dlObj.easy_perform
		if not err.is_ok then return cleanup(dlObj, self.i_file, err)		

    var st_code = dlObj.easy_getinfo_long(new CURLInfoLong.response_code)
    if not st_code == null then self.status_code = st_code.response

    var speed = dlObj.easy_getinfo_double(new CURLInfoDouble.speed_download)
    if not speed == null then self.speed_download = speed.response

    var size = dlObj.easy_getinfo_double(new CURLInfoDouble.size_download)
    if not size == null then self.size_download = size.response

    var time = dlObj.easy_getinfo_double(new CURLInfoDouble.total_time)
    if not time == null then self.total_time = time.response

		cleanup(dlObj, self.i_file, null)

		return null
	end

	# Callbacks
	redef fun header_callback(line: String)
	do
		if self.headers == null then self.headers = new HashMap[String, String]
		var splitted = line.split_with(':')
		if splitted.length > 1 then
			var key = splitted.shift
			self.headers[key] = splitted.to_s
		end
	end

	redef fun body_callback(line: String)
	do
		self.body_str += line
	end

	redef fun stream_callback(buffer: String, size: Int, count: Int)
	do
		self.i_file.write(buffer, size, count)
	end

end
