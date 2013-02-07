module curlsample
import curl


# Initializing curl obj
var dlObj = new CURL.easy_init
# Downloading ...
dlObj.easy_setopt("http://papercom.fr/apache.zip")
dlObj.debugger(true)
dlObj.easy_perform
dlObj.easy_clean
