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

# Mail sender sample using the Mail module
module mail_sample

import mail

var mail = new Mail
var err: nullable CURLCode

# Networks
err = mail.set_outgoing_server("smtps://smtp.gmail.com:465", "monkeymattluc@gmail.com", "nitlanguage")
if err != null then print err.to_s
mail.verbose = true

# Headers
var headers_body = new HashMap[String, String]
headers_body["Content-Type:"] = "text/html; charset=\"UTF-8\""
headers_body["Content-Transfer-Encoding:"] = "quoted-printable"
mail.headers_body = headers_body
mail.from = "Matthieu Lucas"
mail.to = ["lucas.matthieu@courrier.uqam.ca"]
mail.cc = ["lage.stefan@courrier.uqam.ca"]
mail.bcc = null

# Content
mail.body = "<h1>Here you can write HTML stuff.</h1>"
mail.subject = "Hello From My Nit Program"
print "Mail Sended : {mail.send}"

# GC
mail.destroy






