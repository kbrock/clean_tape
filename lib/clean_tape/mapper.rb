module CleanTape
  class Mapper
    attr_accessor :mac_fields
    attr_accessor :ip_fields
    attr_accessor :domain_fields
    attr_accessor :host_fields
    attr_accessor :url_fields

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
      return value if value.nil? || (value.kind_of?(String) && value.empty?)
      if mac?(name)
        fix_mac(value)
      elsif ip?(name)
        fix_ip(value)
      elsif domain?(name)
        fix_domain(value)
      elsif url?(name)
        fix_url(value)
      else
        value
      end
    end

    def mac?(name)
      mac_fields.include?(name)
    end

    def fix_mac(value)
      m = value.match(/^(?:[0-9a-fA-F]{2}[:-]){4}([0-9a-fA-F]{2})([:-])([0-9a-fA-F]{2})$/i)
      (["00"] * 4 + [m[1], m[3]]).join(m[2])
    end

    def ip?(name)
      ip_fields.include?(name)
    end

    def fix_ip(value)
      value.gsub(/\d+\.\d+\.(\d+\.\d+)/, "192.168.\\1")
    end

    def domain?(name)
      domain_fields.include?(name)
    end

    def fix_domain(value)
      value
    end

    def host?(name)
      host_fields.include?(name)
    end

    def fix_host(value)
      value
    end

    def url?(name)
      url_fields.include?(name)
    end

    def fix_url(value)
      value
    end
  end
end
