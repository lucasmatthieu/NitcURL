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

# Get content sample using the Curl module.
module get_sample

import curl

if args.is_empty then
  print "Usage {sys.program_name} <target url>"
else
	var curl = new Curl
	curl.verbose = false

  # Custom Headers
  var custom_head = new HashMap[String, String]
  custom_head["Accept"] = "moo"
  curl.httpheaders = custom_head

	# Request
	var resp: nullable String = null
	resp = curl.get_content(args[0])

	# Errors
	if not resp == null then print resp

	# Responses
  # - Status code
	if curl.status_code != null then print "Status code : {curl.status_code.to_s}"
  # - Headers
	if curl.headers != null then
    for h_key, h_val in curl.headers.as(not null) do
        print "{h_key} = {h_val}"
    end
  end
  # - Body
  if curl.body_str != null then print "Body : {curl.body_str.as(not null)}"
end
