module mail
import ffcurl

class Mail
  super FFCurlCallbacks

  var headers: nullable HashMap[String, String] writable
  var headers_body: nullable HashMap[String, String] writable
  var from: nullable String writable
  var to: nullable Array[String] writable
  var cc: nullable Array[String] writable
  var bcc: nullable Array[String] writable
  var subject: nullable String writable
  var body: nullable String writable
  var verbose: Bool writable
  private var curl: nullable FFCurl

  init
  do
    curl = new FFCurl.easy_init
    if not curl.is_init then curl = null

    headers = null
    headers_body = null
    from = null
    to = null
    subject = null
    body = null
    verbose = false
  end

  private fun add_conventional_space(str: String):String do return "{str}\n" end
  private fun add_pair_to_content(str: String, att: String, val: nullable String):String
  do
    if val != null then return "{str}{att}{val}\n"
    return "{str}{att}\n"
  end

  fun send:Bool
  do
    var err: CURLCode
    var content = ""

    # Headers
    if headers != null then
      for h_key, h_val in headers.as(not null) do
        content = add_pair_to_content(content, h_key, h_val)
      end
    end

    # Recipients
    var gRec = new Array[String]
    if to != null and to.length > 0 then
      content = add_pair_to_content(content, "To:", to.join(","))
      gRec.append(to.as(not null))
    end
    if cc != null and cc.length > 0 then
      content = add_pair_to_content(content, "Cc:", cc.join(","))
      gRec.append(cc.as(not null))
    end
    if bcc != null and bcc.length > 0 then gRec.append(bcc.as(not null))

    if gRec.length < 1 then return false
    err = curl.easy_setopt(new CURLOption.mail_rcpt, gRec.to_curlslist)
    if not err.is_ok then return false

    # From
    if not from == null then
      content = add_pair_to_content(content, "From:", from)
      err = curl.easy_setopt(new CURLOption.mail_from, from.as(not null))
      if not err.is_ok then return false
    end

    # Subject
    content = add_pair_to_content(content, "Subject:", subject)

    # Headers body
    if headers_body != null then
      for h_key, h_val in headers_body.as(not null) do
        content = add_pair_to_content(content, h_key, h_val)
      end
    end

    # Body
    content = add_conventional_space(content)
    content = add_pair_to_content(content, "", body) 
    content = add_conventional_space(content)
    err = curl.register_callback(self, once new CURLCallbackType.read)
    if not err.is_ok then return false
    err = curl.register_read_datas_callback(self, content)
    if not err.is_ok then return false

    # Verbose
    err = curl.easy_setopt(new CURLOption.verbose, verbose)
    if not err.is_ok then return false

    # Send
    return curl.easy_perform.is_ok
  end

  fun smtp(host: String, user: nullable String, pwd: nullable String, secure: Bool):nullable CURLCode
  do
    var err: CURLCode

    # Redirect
    err = curl.easy_setopt(new CURLOption.follow_location, 1)
    if not err.is_ok then return err

    # Url
    if secure then host = "smtps://{host}" else host = "smtp://{host}"
    err = curl.easy_setopt(new CURLOption.url, host)
    if not err.is_ok then return err

    # Credentials
    if not user == null and not pwd == null then
      err = curl.easy_setopt(new CURLOption.username, user)
      if not err.is_ok then return err
      err = curl.easy_setopt(new CURLOption.password, pwd)
      if not err.is_ok then return err
    end

    return null
  end

  fun destroy do curl.easy_clean end
end
