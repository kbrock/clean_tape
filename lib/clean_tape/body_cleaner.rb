module CleanTape
  class BodyCleaner
    attr_accessor :mapper
    attr_accessor :parser

    def initialize(parser)
      self.mapper = Mapper.new
      self.parser = parser
    end

    def clean(value)
      if value
        body = parser.load(value)
        # assignment shouldn't be necessary (is changing inplace)
        body = traverse_body(body)
        parser.dump(body)
      end
    end

    # assume node is array or hash
    # assume array has hashes
    # assume hash values are hashes, strings, or arrays
    def traverse_body(node, indent="")
      case node
      when Array
        puts "#{indent}["
        node.map! { |n| traverse_body(n, indent + "  ") }
        puts "#{indent}]"
      when Hash
        # don't use node.each. using keys allows you to modify the hash inline
        puts "#{indent}{"
        node.keys.each do |key|
          value = node[key]
          case value
          when Array
            puts "#{indent}#{key}: ["
            if value.first.kind_of?(Array) || value.first.kind_of?(Hash)
              traverse_body(value, indent + "  ")
            elsif value.first == nil
            else
              raise "no!: #{value.first.class}"
            end
            puts "#{indent}]"
          when Hash
            puts "#{indent}#{key}: {"
            if value.kind_of?(Hash)
              traverse_body(value, indent + "  ")
            elsif value.kind_of?(Array)
              if value.first.kind_of?(Hash)
                traverse_body(value, indent + " ")
              else
                puts "#{indent}#{key}: "
              end
            else # convert
            end
            puts "#{indent}}"

          when String, Fixnum
            puts "#{indent}#{key}: #{value}"
          when NilClass
          else
            puts "#{indent}#{key}: #{value.class.name}"
          end
          # sanitize_ip domain (host)
        end
        puts "#{indent}}"
      when String
        puts "#{indent}string: #{node}"
      else
        puts "#{indent}unknown node[#{node.class}]: #{node}"
      end
      node
    end
  end
end
