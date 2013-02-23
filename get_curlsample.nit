module get_curlsample
import curl

if args.is_empty then
	abort
else
	print "P:"+args[0]
	var curlObj = new Curl
	var resp = curlObj.get(args[0])
	if resp != null then print resp
	
end

