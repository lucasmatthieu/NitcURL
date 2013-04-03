module get_sample
import curl

fun usage
do
	print "Usage ./<app> <target url>"
end

if args.is_empty then
	usage
else
	var curl = new Curl
	curl.verbose = false

	# Parameters
	var resp: nullable String = null
	resp = curl.get(args[0])

	# Errors
	if not resp == null then print resp

	# Responses
	if not curl.status_code == null then 
	#	print "Status code : "+curl.status_code.to_s
	end
	if not curl.headers == null then 
		for x in curl.headers.keys do print x+" = "+curl.headers[x]
	end
	if not curl.body_str == "" then
	#	print "Body : "+curl.body_str
	end
end
