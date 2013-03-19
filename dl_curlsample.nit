module dl_curlsample
import curl

if args.is_empty then
	print "Usage ./<app> <target url> <output name>"
else
	var curlObj = new Curl
	var resp: nullable String
	if args.length == 1 then 
		resp = curlObj.download(args[0], null)
	else if args.length == 2 then
		resp = curlObj.download(args[0], args[1])
	else
		resp = null
		print "Usage ./<app> <target url> <output name>"
	end

	if not resp == null then print resp
	if not curlObj.status_code == null then print "Status code : "+curlObj.status_code.to_s
end
