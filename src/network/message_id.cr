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
    io.print({{@type.stringify + "("}}, @id, ", ", @name, ')')
  end

  private def count_params(str)
    count = 0

    0.upto(str.size &- 2) do |i|
      if str[i].in?('C', 'S')
        c2 = str[i &+ 1]
        if c2.number?
          count = Math.max(count, c2.to_i)
        end
      end
    end

    count
  end

  private macro add(name, id)
    {{name.id}} = new({{name.stringify}}, {{id}})
    {{name.id}}
  end
end
