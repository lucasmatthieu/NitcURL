module mail_sample
import mail

# mail.headers
# mail.headers_body
# mail.from
# mail.to
# mail.cc
# mail.bcc
# mail.subject
# mail.body
# mail.verbose
#
# mail.send
# mail.smtp
# mail.destroy

var mail = new Mail
# Networks
mail.smtp("smtp.gmail.com:465", "monkeymattluc@gmail.com", "nitlanguage", true)
mail.verbose = false
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






