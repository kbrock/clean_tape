module CleanTape
  class Mapper
    attr_accessor :mac_fields
    attr_accessor :ip_fields
    attr_accessor :domain_fields
    attr_accessor :host_fields
    attr_accessor :urls_fields

    def initialize
      self.mac_fields = []
      self.ip_fields = []
      self.domain_fields = []
      self.host_fields = []
      self.urls_fields = []
    end

    def fix_fields(name, values)
      if values.kind_of?(Array)
        values.map { |value| fix_field(name, value) }
      else
        fix_field(name, values)
      end
    end

    def fix_field(name, value)
      if mac_fields.include?(name)
        fix_mac(value)
      elsif ip_fields.include?(name)
        fix_ip(value)
      elsif domain_fields.include?(name)
        fix_domain(value)
      elsif urls_fields.include?(name)
        fix_urls(value)
      else
        value
      end
    end

    def fix_mac(value)
      m = value.match(/^(?:[0-9a-fA-F]{2}[:-]){4}([0-9a-fA-F]{2})([:-])([0-9a-fA-F]{2})$/i)
      (["00"] * 4 + [m[1], m[3]]).join(m[2])
    end

    def fix_ip(value)
      value.gsub(/\d+\.\d+\.(\d+\.\d+)/, "192.168.\\1")
    end

    def fix_domain(value)
      value
    end

    def fix_host(value)
      value
    end

    def fix_urls(value)
      value
    end
  end
end
