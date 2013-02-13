module curlsample
import curl

if args.is_empty then
	abort
else
	print "P:"+args[0]
	var curlObj = new Curl
	curlObj.get(args[0])
end

