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
	if curl.status_code != null then print "Status code : {curl.status_code.to_s}"
	if curl.headers != null then
    for h_key, h_val in curl.headers.as(not null) do
        print "{h_key} = {h_val}"
    end
  end
  #if curl.body_str.length > 0 then print "Body : {curl.body_str}"
end
