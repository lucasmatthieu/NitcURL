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

# HTTP Post request sample using the Curl module.
module post_sample

import curl

var curl = new Curl
curl.verbose = false

# Url
var url = "172.16.217.134/post.php"
# Datas
var datas = new HashMap[String, String]
datas["Bugs Bunny"] = "Daffy Duck"
datas["Batman"] = "Robin likes special characters @#ùà!è§'(\"é&://,;<>∞~*"

# Request
var resp = curl.http_post(url, datas)
# Answer
if resp != null then print resp
# Content Type
if curl.headers != null then print "Content-Type : {curl.headers["Content-Type"]}"
# Status code
if curl.status_code != null then print "Status code : {curl.status_code.to_s}"
# Body
if curl.body_str != null then print "Body : {curl.body_str.as(not null)}"



