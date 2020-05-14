class Calculator
  include Synchronizable

  def initialize
    @functions = Slice(AbstractFunction).empty
  end

  def initialize(c : Calculator)
    @functions = c.@functions
  end

  def initialize(func : AbstractFunction)
    @functions = Slice.new(1, func.as(AbstractFunction))
  end

  def_equals @functions
  delegate size, empty?, to: @functions

  def add_func(func : AbstractFunction)
    sync do
      funcs = @functions
      tmp = Pointer(AbstractFunction).malloc(funcs.size &+ 1)

      order = func.order

      i = 0
      while i < funcs.size && order >= funcs[i].order
        tmp[i] = funcs[i]
        i &+= 1
      end

      tmp[i] = func

      while i < funcs.size
        tmp[i &+ 1] = funcs[i]
        i &+= 1
      end

      @functions = tmp.to_slice(funcs.size + 1)
    end
  end

  def remove_func(func : AbstractFunction)
    sync do
      funcs = @functions
      tmp = Pointer(AbstractFunction).malloc(funcs.size &- 1)

      i = 0
      while i < funcs.size &- 1 && func != funcs[i]
        tmp[i] = funcs[i]
        i &+= 1
      end

      if i == funcs.size
        return
      end
      i &+= 1
      while i < funcs.size
        tmp[i &- 1] = funcs[i]
        i &+= 1
      end

      if funcs.size == 1
        @functions = Slice(AbstractFunction).empty
      else
        @functions = tmp.to_slice(funcs.size &- 1)
      end
    end
  end

  def remove_owner(owner : Object) : Array(Stats)
    sync do
      modified_stats = [] of Stats

      @functions.each do |func|
        if func.owner == owner
          modified_stats << func.stat
          remove_func(func)
        end
      end

      modified_stats
    end
  end

  def calc(caster : L2Character, target : L2Character?, skill : Skill?, value : Float64) : Float64
    @functions.reduce(value) { |v, f| f.calc(caster, target, skill, v) }
  end
end
