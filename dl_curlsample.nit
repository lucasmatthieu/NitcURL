module dl_curlsample
import curl

if args.is_empty then
	print "Usage ./<app> <target url> <output name>"
else
	var curlObj = new Curl
	var resp = curlObj.download(args[0], null)
	if resp != null then 
		print resp
	else
		print "Status code == "+curlObj.status_code.to_s
	end
end

