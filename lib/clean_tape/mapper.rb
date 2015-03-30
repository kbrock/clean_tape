module CleanTape
  class Mapper
    DOMAIN = "example.com"

    MAC_REGEX = /^(?:[0-9a-fA-F]{2}[:-]){4}([0-9a-fA-F]{2})([:-])([0-9a-fA-F]{2})$/i
    IP_REGEX = /^\d+\.\d+\.(\d+\.\d+)$/ # very lacking and not ipv6 compatible
    HOST_REGEX = /[.]com$/
    URL_REGEX = %r{^https?://}

    attr_accessor :mac_fields
    attr_accessor :ip_fields
    attr_accessor :domain_fields
    attr_accessor :host_fields
    attr_accessor :url_fields
    attr_accessor :guess

    def initialize
      # some time in the future this will be defined by others
      self.mac_fields = %w(mac)
      self.ip_fields = %w(ip ip_address)
      self.domain_fields = %w(domain_name)
      self.host_fields = []
      self.url_fields = %w(url)
    end

    def fix_fields(name, values)
      if values.nil?
        values
      elsif values.kind_of?(Array)
        values.map { |value| fix_field(name, value) }
      else
        fix_field(name, values)
      end
    end

    def fix_field(name, value)
      return value if value.nil? || !!(value.kind_of?(String) && value.empty?)
      if mac?(name)
        fix_mac(value)
      elsif ip?(name)
        fix_ip(value)
      elsif host?(name)
        fix_host(value)
      elsif domain?(name)
        fix_domain(value)
      elsif url?(name)
        fix_url(value)
      elsif !guess # if we don't want to guess, just return the value
        value
      elsif mac?(name, value) # now guess
        fix_mac(value)
      elsif ip?(name, value)
        fix_ip(value)
      elsif host?(name, value) # no way to determine domain v host, just do host
        fix_host(value)
      elsif url?(name, value)
        fix_url(value)
      else
        value
      end
    end

    def mac?(name, value = nil)
      mac_fields.include?(name) || !!(value && value.to_s.match(MAC_REGEX))
    end

    def fix_mac(value)
      m = value.match(MAC_REGEX)
      (["00"] * 4 + [m[1], m[3]]).join(m[2])
    end

    def ip?(name, value = nil)
      ip_fields.include?(name) || !!(value && value.to_s.match(IP_REGEX))
    end

    def fix_ip(value)
      value.gsub(IP_REGEX, "192.168.\\1")
    end

    def domain?(name, value = nil)
      domain_fields.include?(name)
    end

    def fix_domain(value)
      DOMAIN  if value && !value.empty?
    end

    def host?(name, value = nil)
      host_fields.include?(name) || !!(value && value.to_s.match(HOST_REGEX))
    end

    def fix_host(value)
      "#{value.split(".").first}.#{DOMAIN}" if value && !value.empty?
    end

    def url?(name, value = nil)
      url_fields.include?(name) || !!(value && value.to_s.match(URL_REGEX))
    end

    def fix_url(value)
      value
    end
  end
end
