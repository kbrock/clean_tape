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
        node.map! { |n| traverse_body(n, indent + "  ") }
      when Hash
        # don't use node.each. using keys allows you to modify the hash inline
        node.keys.each do |key|
          value = node[key]
          case value
          when Hash
            traverse_body(value, "indent" + "  ")
          when String, Fixnum, TrueClass, FalseClass, NilClass
            node[key] = mapper.fix_field(key, value)
          when Array
            case value.first
            when String, Fixnum, TrueClass, FalseClass, NilClass
              node[key] = mapper.fix_fields(key, value)
            when Hash
              traverse_body(value, "indent" + "  ")
            else
              raise "no! {#{key}: [#{value.first.class}]}"
            end
          else
            raise "no!: {#{key}: #{value.class}}"
          end
        end
      else
        raise "top level #{value.class}}"
      end
      node
    end
  end
end
