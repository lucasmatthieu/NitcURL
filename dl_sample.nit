module dl_sample
import curl

fun usage
do
	print "Usage ./<app> <target url> <output name>"
end

if args.is_empty then
	usage
else
	var curlObj = new Curl
	curlObj.verbose = false

	# Parameters
	var resp: nullable String = null
	if args.length == 1 then 
		resp = curlObj.download(args[0], null)
	else if args.length == 2 then
		resp = curlObj.download(args[0], args[1])
	else
		usage
	end

	# Errors
	if not resp == null then print resp

	# Responses
	if not curlObj.status_code == null then 
		print "Status code : {curlObj.status_code.to_s}"
	end
	if not curlObj.headers == null then 
		print "Content type : {curlObj.headers["Content-Type"]}"
	end
  if not curlObj.speed_download == null and not curlObj.size_download == null then 
    print "Speed download : {curlObj.speed_download.to_s}"
    print "Size download : {curlObj.size_download.to_s}"
    var elapsTime = curlObj.size_download.as(not null) / curlObj.speed_download.as(not null)
    print "Elapsed time : {elapsTime.to_s}"
	end
  if not curlObj.total_time == null then 
		print "Total time : {curlObj.total_time.to_s}"
  end
end
