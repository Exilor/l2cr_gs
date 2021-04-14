abstract class MessageId
  macro inherited
    private MAP = {} of Int32 => self

    getter id, name = "", param_count = 0

    private def initialize(id : Int32)
      @id = id
      MAP[id] = self
    end

    private def initialize(name : String, id : Int32)
      @name = name
      @id = id
      @param_count = count_params(name)
      MAP[id] = self
    end

    def self.get(id : Int32) : self
      MAP.fetch(id) { new(id) }
    end

    def self.get?(id : Int32) : self?
      MAP[id]?
    end
  end

  def to_s(io : IO)
    io.print({{@type.stringify + "::"}}, @name.empty? ? @id : @name)
  end

  def inspect(io : IO)
    to_s(io)
  end

  private def count_params(str)
    return 0 if str.empty?

    count = 0

    0.upto(str.bytesize &- 2) do |i|
      case str.unsafe_byte_at(i)
      when 67, 83 # "C", "S"
        case c2 = str.unsafe_byte_at(i &+ 1)
        when 48..57 # 0..9
          count = Math.max(count, c2 &- 48)
        end
      end
    end

    count.to_i!
  end

  private macro add(name, id)
    {{name.id}} = new({{name.stringify}}, {{id}})
    {{name.id}}
  end
end
