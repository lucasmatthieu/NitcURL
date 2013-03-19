module mail_curlsample
import curl

var curl = new Curl
var rcpt = ["lucasmatthieu@gmail.com"]
curl.mail("smtps://smtp.gmail.com:465", "yourmail",rcpt,"usermail", "userpwd")
