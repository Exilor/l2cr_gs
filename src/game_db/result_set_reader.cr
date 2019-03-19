struct ResultSetReader
    private alias KeyType = String | Int::Primitive
    private alias ValueType = DB::Any | Int8 | Int16

    private record Entry, column_name : String, value : ValueType

    def initialize(rs : DB::ResultSet)
      @data = Slice(Entry).new(rs.column_count) do |i|
        Entry.new(rs.column_name(i), rs.read(ValueType))
      end
    end

    {% for name in %w(i8 i16 i32 i64 u8 u16 u32 u64 f32 f64) %}
      {% prefix = name.starts_with?('i') ? "Int".id : (name.starts_with?('u') ? "UInt".id : "Float".id) %}
      {% type = "#{prefix}#{name[1..-1].id}".id %}

      def get_{{name.id}}(key : KeyType) : {{type}}
        value = get(key)

        if value.nil?
          return 0{{name.id}}
        end

        value.as(Number::Primitive).to_{{name.id}}
      end
    {% end %}

    def get_string(key : KeyType) : String
      get(key).as(String)
    end

    def get_string?(key : KeyType) : String?
      get(key).as(String?)
    end

    def get_time(key : KeyType) : Time
      get(key).as(Time)
    end

    def get_time?(key : KeyType) : Time?
      get(key).as(Time?)
    end

    def get_bytes(key : KeyType) : Bytes
      get_string(key).bytes.to_slice
    end

    def get_bool(key : KeyType) : Bool
      # coerce "1" -> true, 1 -> true, "true" => true ?
      case val = get(key)
      when Bool
        val
      when Int
        val == 1
      when String
        case val.casecmp
        when "true"
          true
        when "false"
          false
        else
          raise "Invalid Bool #{val.inspect}"
        end
      else
        raise "Invalid Bool: #{val.inspect}"
      end
    end

    # def get_bool?(key : KeyType) : Bool?
    #   get(key).as(Bool?)
    # end

    private def get(key : String)
      @data.each do |pair|
        if pair.column_name.casecmp?(key)
          return pair.value
        end
      end

      raise KeyError.new("Column #{key.inspect} wasn't selected or doesn't exist")
    end

    private def get(idx : Int)
      @data[idx - 1].value
    end
  end
