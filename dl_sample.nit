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

# Download file sample using the Curl module.
module dl_sample

import curl

if args.is_empty then
	print "Usage {sys.program_name} <target url> <output name>"
else
	var curl = new Curl
	curl.verbose = false

	# Parameters
	var resp: nullable String = null
	if args.length == 1 then
		resp = curl.download_to_file(args[0], null)
	else if args.length == 2 then
		resp = curl.download_to_file(args[0], args[1])
	end

	# Errors
	if resp != null then print resp

	# Responses
	if curl.status_code != null then print "Status code : {curl.status_code.to_s}"
	if curl.headers != null then print "Content type : {curl.headers["Content-Type"]}"
  if curl.speed_download != null then print "Speed download : {curl.speed_download.to_s}"
  if curl.size_download != null then print "Size download : {curl.size_download.to_s}"
  if curl.total_time != null then print "Total time : {curl.total_time.to_s}"
end
