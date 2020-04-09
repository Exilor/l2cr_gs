abstract class EnumClass
  macro inherited
    extend Indexable({{@type.stringify.split("::").last.id}})
    include Comparable(self)

    @@enum_members = Slice(self).empty

    getter to_i = -1
    getter to_s = ""
    protected setter to_i, to_s

    def_equals_and_hash @to_i

    {% for name in %w(i8 i16 i32 i64 u8 u16 u32 u64 f32 f64) %}
      {% prefix = name.starts_with?('i') ? "Int".id : (name.starts_with?('u') ? "UInt".id : "Float".id) %}
      {% type = "#{prefix}#{name[1..-1].id}".id %}

      def to_{{name.id}} : {{type}}
        to_i.to_{{name.id}}
      end
    {% end %}

    def to_f : Float64
      to_f64
    end

    def <=>(other : self) : Int32
      to_i <=> other.to_i
    end

    def mask : UInt32
      1u32 << to_i
    end

    def dup : self
      self
    end

    def clone : self
      self
    end

    def inspect(io : IO) : Nil
      io << {{@type.stringify + "::"}} << @to_s
    end

    def to_s(io : IO) : Nil
      io << @to_s
    end

    def self.mask : UInt64
      (1u64 << size) - 1
    end

    def self.size : Int32
      @@enum_members.size
    end

    def self.unsafe_fetch(index : Int) : self
      @@enum_members.unsafe_fetch(index)
    end

    def self.parse?(str : String) : self?
      find { |m| m.to_s.compare(str, true) == 0 }
    end

    def self.parse(str : String) : self
      parse?(str) ||
      raise ArgumentError.new("unknown #{self} with name #{str.inspect}")
    end

    private def self.add_member(member : self)
      @@enum_members = @@enum_members.add(member)
    end
  end

  private macro add(__name__, *args, **opts, &block)
    {{__name__.id}} = allocate
    {{__name__.id}}.to_i = @@enum_members.size
    {{__name__.id}}.to_s = {{__name__.stringify}}


    add_member({{__name__.id}})

    def {{__name__.stringify.underscore.id}}? : Bool
      same?({{__name__.id}})
    end

    {% if !args.empty? && !opts.empty? %}
      {{__name__.id}}.initialize({{*args}}, {{**opts}}) {{ block }}
    {% elsif !args.empty? %}
      {{__name__.id}}.initialize({{*args}}) {{ block }}
    {% else %}
      {{__name__.id}}.initialize({{**opts}}) {{ block }}
    {% end %}
  end
end
