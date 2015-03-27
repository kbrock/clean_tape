module CleanTape
  class Tape
    VCR = "VCR 2.9.3"
    DATE = "Sat, 01 Jan 2000 00:00:00 GMT"
    COOKIE_SESSION = "xxx"
    ETAG = "c15ce0b593ab74018a5162399548a38d"

    attr_accessor :filename
    attr_accessor :verbose
    attr_accessor :body_cleaner

    def initialize(filename, verbose, body_cleaner)
      self.filename = filename
      self.verbose  = verbose
      self.body_cleaner = body_cleaner
    end

    # yaml: http_interactions[], recorded_with

    # yaml/recorded_with
    def clean_recorded_with(value = VCR)
      f["recorded_with"] = value
    end

    # yaml/http_interactions[]: request, response, recorded_at

    def sort
      f["http_interactions"].sort_by! do |r|
        # body tends to be nil for requests
        %w(uri method body).map { |k| r["request"][k] || ""}
      end
      self
    end

    # yaml/http_interactions[]/recorded_at
    def clean_recorded_at(value = DATE)
      interactions_swap("recorded_at") { |_k| value }
    end

    # yaml/http_interactions[]/request: ["method", "uri", "body", "headers"]

    # method (string)
    def clean_request_headers
      interactions.each do |i|
        h = i["request"]["headers"]
        h.delete("User-Agent") # this seems to change for some reason
        # may want to whitelist keep instead
        # keep: "Accept" "Accept-Encoding" "Content-Type"
      end
    end

    def clean_request_body
      # interactions.each do |i|
      #   if i["request"]["method"].upcase != "GET"
      #     h = i["request"]["body"]
      #   end
      # end
    end

    def clean_request_uris(hostname, username, password)
      interactions.each do |i|
        uri = URI.parse(i["request"]["uri"])
        uri.hostname = hostname
        uri.user = username if uri.user
        uri.password = password if uri.password

        i["request"]["uri"] = uri.to_s
      end
      self
    end

    # yaml/http_interactions[]/response: ["status", "headers", "body", "http_version"]

    # status hash
    # http_version (nil for me) may want to clean out

    def clean_response_headers
      interactions.each do |i|
        h = i["response"]["headers"]
        # ?
        %w(Cache-Control).each { |k| h.delete(k) }
        %w(Server X-Ua-Compatible X-Request-Id X-Runtime X-Rack-Cache X-Powered-By).each { |k| h.delete(k) }

        hardcode(h, "Date", DATE)
        # Etags change based upon contents
        # but the client may depend upon them
        # not sure best route here
        # e.g.: '"c15ce0b593ab74018a5162399548a38d"'
        hardcode(h, "Etag", ETAG)

        # e.g.: Set-Cookie ["_session_id=cd19c03593ace0ca6c3b3d4b350538e6; path=/; HttpOnly"]
        h["Set-Cookie"].map! do |c|
          c.gsub(/(_session_id=)[^;]*;/, "\\1#{COOKIE_SESSION};")
        end if h["Set-Cookie"]
      end
    end

    def clean_response_body
      interactions.each do |i|
        # body can come with encoding or not.
        if i["response"]["body"].kind_of?(Hash)
          i["response"]["body"]["string"]= body_cleaner.clean(i["response"]["body"]["string"])
        else
          i["response"]["body"] = body_cleaner.clean(i["response"]["body"])
        end
      end
    end

    ## -

    def save(backup = '-bak')
      if backup
        backupfile = "#{filename}#{backup}"
        if File.exists?(backupfile)
          puts "backup #{backupfile} already exists" if verbose
        else
          puts "#{filename} => #{backupfile}" if verbose
          FileUtils.copy(filename, backupfile)
        end
      end

      File.write(filename,f.to_yaml)
    end

    private

    def f
      @f ||= YAML.load_file(filename)
    end

    def interactions_swap(name)
      interactions.each do |i|
        i[name] = yield(i[name])
      end
      self
    end

    def interactions
      f["http_interactions"]
    end

    def hardcode(h, key, value)
      if h[key].kind_of?(Array)
        h[key] = [value]
      elsif h[key].kind_of?(String)
        h[key] = value
      end
    end
  end
end
