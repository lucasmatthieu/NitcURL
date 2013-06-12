# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2013 Matthieu Lucas <lucasmatthieu@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Network functionnalities based on Curl_c module.
module curl

import curl_c

class Curl
	super CCurlCallbacks
	var verbose: Bool writable
	var status_code: nullable Int
	var body_str: nullable String
  var httpheaders: nullable HashMap[String, String] writable
	var headers: nullable HashMap[String, String]
  var speed_download: nullable Int
  var size_download: nullable Int
  var total_time: nullable Int
	private var i_file: nullable OFile
  private var error_init_msg: String

	init
	do
    verbose = false
		status_code = null
		body_str = null
    httpheaders = null
		headers = null
    speed_download = null
    size_download = null
    total_time = null
		i_file = null
    error_init_msg = "Unable to init curl"
	end

	# Clean curl instance and opened file if exists
	private fun cleanup(curl: nullable CCurl, fle: nullable OFile, err: nullable CURLCode):nullable String
	do
		if curl != null then curl.easy_clean
		if fle != null then if not fle.close then return "Something wrong while trying to close the file."
		if err != null then return err.to_s
		return null
	end

  # Get request to received data from a specified resource
	fun get_content(url: String):nullable String
	do
		var curl_obj = new CCurl.easy_init
		if not curl_obj.is_init then return self.error_init_msg

		var err:CURLCode

    if self.httpheaders != null then
      var httpheaders_joined = self.httpheaders.join_pair_to_array(": ")
      err = curl_obj.easy_setopt(new CURLOption.httpheader, httpheaders_joined.to_curlslist)
      if not err.is_ok then return cleanup(curl_obj, null, err)
    end

		err = curl_obj.easy_setopt(new CURLOption.url, url)
		if not err.is_ok then return cleanup(curl_obj, null, err)
		
		err = curl_obj.easy_setopt(new CURLOption.follow_location, 1)
		if not err.is_ok then return cleanup(curl_obj, null, err)

		err = curl_obj.easy_setopt(new CURLOption.verbose, self.verbose)
		if not err.is_ok then return cleanup(curl_obj, null, err)
		
		err = curl_obj.register_callback(self, new CURLCallbackType.header)
		if not err.is_ok then return cleanup(curl_obj, null, err)

		err = curl_obj.register_callback(self, new CURLCallbackType.body)
		if not err.is_ok then return cleanup(curl_obj, null, err)

		err = curl_obj.easy_perform
		if not err.is_ok then return cleanup(curl_obj, null, err)

    var st_code = curl_obj.easy_getinfo_long(new CURLInfoLong.response_code)
		if not st_code == null then self.status_code = st_code.response

		cleanup(curl_obj, null, null)

		return null
	end

  # Execute HTTP Post request
  fun http_post(url: String, datas: HashMap[String, String]):nullable String
  do
    var curl_obj = new CCurl.easy_init
		if not curl_obj.is_init then return self.error_init_msg

    var err: CURLCode

    if self.httpheaders != null then
      var httpheaders_joined = self.httpheaders.join_pair_to_array(": ")
      err = curl_obj.easy_setopt(new CURLOption.httpheader, httpheaders_joined.to_curlslist)
      if not err.is_ok then return cleanup(curl_obj, null, err)
    end

    err = curl_obj.easy_setopt(new CURLOption.url, url)
		if not err.is_ok then return cleanup(curl_obj, null, err)

		err = curl_obj.easy_setopt(new CURLOption.follow_location, 1)
		if not err.is_ok then return cleanup(curl_obj, null, err)

		err = curl_obj.easy_setopt(new CURLOption.verbose, self.verbose)
		if not err.is_ok then return cleanup(curl_obj, null, err)

    var postdatas = datas.to_url_encoded(curl_obj)
    err = curl_obj.easy_setopt(new CURLOption.postfields, postdatas)
    if not err.is_ok then return cleanup(curl_obj, null, err)

		err = curl_obj.register_callback(self, new CURLCallbackType.header)
		if not err.is_ok then return cleanup(curl_obj, null, err)

		err = curl_obj.register_callback(self, new CURLCallbackType.body)
		if not err.is_ok then return cleanup(curl_obj, null, err)

    err = curl_obj.easy_perform
		if not err.is_ok then return cleanup(curl_obj, null, err)		

    var st_code = curl_obj.easy_getinfo_long(new CURLInfoLong.response_code)
    if not st_code == null then self.status_code = st_code.response

		cleanup(curl_obj, null, null)

    return null
  end

  # Download file from specified resource to a given output file name
	fun download_to_file(url: String, output_name: nullable String):nullable String
	do
		var curl_obj = new CCurl.easy_init
		if not curl_obj.is_init then return self.error_init_msg

		var err:CURLCode

    if self.httpheaders != null then
      var httpheaders_joined = self.httpheaders.join_pair_to_array(": ")
      err = curl_obj.easy_setopt(new CURLOption.httpheader, httpheaders_joined.to_curlslist)
      if not err.is_ok then return cleanup(curl_obj, null, err)
    end
		
		err = curl_obj.easy_setopt(new CURLOption.url, url)
		if not err.is_ok then return cleanup(curl_obj, null, err)

		err = curl_obj.easy_setopt(new CURLOption.follow_location, 1)
		if not err.is_ok then return cleanup(curl_obj, null, err)

		err = curl_obj.easy_setopt(new CURLOption.verbose, self.verbose)
		if not err.is_ok then return cleanup(curl_obj, null, err)

		var optName:nullable String
		if not output_name == null then
			optName = output_name
		else if not url.substring(url.length-1, url.length) == "/" then
			optName = url.basename("")
		else
			cleanup(curl_obj, null, null)
			return "Unable to treat url to get basename"
		end

		self.i_file = new OFile.open(optName.to_cstring)
		if not self.i_file.is_valid then
			cleanup(curl_obj, self.i_file, null)
			return "Unable to create file"
		end

		err = curl_obj.register_callback(self, new CURLCallbackType.header)
		if not err.is_ok then return cleanup(curl_obj, self.i_file, err)

		err = curl_obj.register_callback(self, new CURLCallbackType.stream)
		if not err.is_ok then return cleanup(curl_obj, self.i_file, err)

		err = curl_obj.easy_perform
		if not err.is_ok then return cleanup(curl_obj, self.i_file, err)		

    var st_code = curl_obj.easy_getinfo_long(new CURLInfoLong.response_code)
    if not st_code == null then self.status_code = st_code.response

    var speed = curl_obj.easy_getinfo_double(new CURLInfoDouble.speed_download)
    if not speed == null then self.speed_download = speed.response

    var size = curl_obj.easy_getinfo_double(new CURLInfoDouble.size_download)
    if not size == null then self.size_download = size.response

    var time = curl_obj.easy_getinfo_double(new CURLInfoDouble.total_time)
    if not time == null then self.total_time = time.response

		cleanup(curl_obj, self.i_file, null)

		return null
	end

	# Receive headers from request due to headers callback registering
	redef fun header_callback(line: String)
	do
		if self.headers == null then self.headers = new HashMap[String, String]
		var splitted = line.split_with(':')
		if splitted.length > 1 then
			var key = splitted.shift
			self.headers[key] = splitted.to_s
		end
	end
  # Receive body from request due to body callback registering
	redef fun body_callback(line: String)
	do
    if self.body_str != null then
      self.body_str = "{self.body_str.as(not null)}{line}"
    else
  		self.body_str = line
    end
	end
  # Receive bytes stream from request due to stream callback registering
	redef fun stream_callback(buffer: String, size: Int, count: Int)
	do
		self.i_file.write(buffer, size, count)
	end

end
