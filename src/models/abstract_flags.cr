abstract struct AbstractFlags
  @mask = 0u32

  private macro flags(*names)
    {% for n, i in names %}
      def {{n.id}}? : Bool
        @mask & {{1 << i}} != 0
      end

      def {{n.id}}=(val : Bool)
        val ? (@mask |= {{1 << i}}) : (@mask &= {{~(1 << i)}})
      end
    {% end %}
  end
end
