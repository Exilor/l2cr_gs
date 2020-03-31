abstract class MessageId
  macro inherited
    private MAP = {} of Int32 => self

    getter id, name = "", param_count = 0

    private def initialize(@id : Int32)
      MAP[id] = self
    end

    private def initialize(@name : String, @id : Int32)
      @param_count = Util.count_params(name)
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
    io << {{@type.stringify + "::"}} << (@name.empty? ? @id : @name)
  end

  def inspect(io : IO)
    io << {{@type.stringify + "("}} << @id << ", " << @name << ')'
  end

  private macro add(name, id)
    {{name.id}} = new({{name.stringify}}, {{id}})
    {{name.id}}
  end
end
