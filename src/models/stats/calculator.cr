struct Calculator
  include Synchronizable

  protected getter functions
  delegate size, empty?, to: @functions

  def initialize
    @functions = [] of AbstractFunction
  end

  def initialize(c : Calculator)
    @functions = c.functions.dup
  end

  def initialize(func : AbstractFunction)
    @functions = [func] of AbstractFunction
  end

  def add_func(func : AbstractFunction)
    sync do
      order = func.order
      index = @functions.bsearch_index { |f| f.order > order }
      @functions.insert(index || -1, func)
    end
  end

  def remove_func(func : AbstractFunction)
    sync { @functions.delete_first(func) }
  end

  def remove_owner(owner : AbstractFunction::OwnerType) : Array(Stats)
    sync do
      result = [] of Stats
      @functions.reject! do |f|
        if f.owner == owner
          result << f.stat
        end
      end
      result
    end
  end

  def calc(caster : L2Character, target : L2Character?, skill : Skill?, value : Float64) : Float64
    @functions.reduce(value) { |v, f| f.calc(caster, target, skill, v) }
  end
end


# class Calculator
#   include Synchronizable

#   def_equals @functions
#   delegate size, empty?, to: @functions

#   def initialize
#     @functions = Slice(AbstractFunction).empty
#   end

#   def initialize(c : Calculator)
#     other_funcs = c.@functions
#     @functions = Slice.new(other_funcs.size) { |i| other_funcs.unsafe_at(i) }
#   end

#   def initialize(func : AbstractFunction)
#     @functions = Slice[func.as(AbstractFunction)]
#   end

#   def add_func(func : AbstractFunction)
#     funcs = @functions
#     tmp = Pointer(AbstractFunction).malloc(funcs.size + 1)

#     order = func.order

#     i = 0
#     while i < funcs.size && order >= funcs.unsafe_at(i).order
#       tmp[i] = funcs.unsafe_at(i)
#       i += 1
#     end

#     tmp[i] = func

#     while i < funcs.size
#       tmp[i + 1] = funcs.unsafe_at(i)
#       i += 1
#     end

#     @functions = Slice.new(tmp, funcs.size + 1)
#   end

#   def remove_func(func : AbstractFunction)
#     funcs = @functions
#     tmp = Pointer(AbstractFunction).malloc(funcs.size - 1)

#     i = 0
#     while i < funcs.size - 1 && func != funcs.unsafe_at(i)
#       tmp[i] = funcs.unsafe_at(i)
#       i += 1
#     end

#     if i == funcs.size
#       return
#     end
#     i += 1
#     while i < funcs.size
#       tmp[i - 1] = funcs.unsafe_at(i)
#       i += 1
#     end

#     if funcs.size == 1
#       @functions = Slice(AbstractFunction).empty
#     else
#       @functions = Slice.new(tmp, funcs.size - 1)
#     end
#   end

#   def remove_owner(owner : Object)
#     modified_stats = [] of Stats

#     @functions.each do |func|
#       if func.owner == owner
#         modified_stats << func.stat
#         remove_func(func)
#       end
#     end

#     modified_stats
#   end

#   def calc(caster, target, skill, value) : Float64
#     @functions.reduce(value) { |v, f| f.calc(caster, target, skill, v) }
#   end
# end










# macro for(*exp, &block)
#   {% if exp[0].is_a?(Assign) || exp[0].is_a?(NilLiteral) %}
#     {{exp[0]}}
#     while {{exp[1]}}
#       {{block.body}}
#       {{exp[2]}}
#     end

#   {% else %}
#     {% in = exp.last.args.first; in2 = in.args.last %}
#     {% variables = exp.stringify.split('(')[0][1..-1].id %}
#     {% block = in.block || in2.block %}
#     {% if in2.is_a?(Call) && in2.block %}
#       {% enumerable = in2.stringify.split(" do\n")[0].id %}
#     {% else %}
#       {% enumerable = in2 %}
#     {% end %}
#     ({{enumerable}}).each { |{{variables}}| {{block.body}} }
#   {% end %}
# end







# class Calculator
#   include Synchronizable

#   def_equals @functions
#   delegate size, empty?, to: @functions

#   def initialize
#     @functions = Slice(AbstractFunction).empty
#   end

#   def initialize(c : Calculator)
#     size = c.@functions.size
#     ptr = Pointer(AbstractFunction).malloc(size)
#     ptr.copy_from(c.@functions.to_unsafe, size)
#     @functions = Slice.new(ptr, size)
#   end

#   def initialize(func : AbstractFunction)
#     @functions = Slice.new(1) { func.as(AbstractFunction) }
#   end

#   def add_func(func : AbstractFunction)
#     sync do
#       funcs = @functions
#       tmp = Pointer(AbstractFunction).malloc(funcs.size + 1)

#       order = func.order

#       for i = 0, i < funcs.size && order >= funcs.unsafe_at(i).order, i += 1 do
#         tmp[i] = funcs.unsafe_at(i)
#       end

#       tmp[i] = func

#       for nil, i < funcs.size, i += 1 do
#         tmp[i + 1] = funcs.unsafe_at(i)
#       end

#       @functions = Slice.new(tmp, funcs.size + 1)
#     end
#   end

#   def remove_func(func : AbstractFunction)
#     sync do
#       funcs = @functions
#       tmp = Pointer(AbstractFunction).malloc(funcs.size - 1)

#       for i = 0, i < funcs.size - 1 && func != funcs.unsafe_at(i), i += 1 do
#         tmp[i] = funcs.unsafe_at(i)
#       end

#       if i == funcs.size
#         return
#       end

#       for i += 1, i < funcs.size, i += 1 do
#         tmp[i - 1] = funcs.unsafe_at(i)
#         i += 1
#       end

#       if funcs.size == 1
#         @functions = Slice(AbstractFunction).empty
#       else
#         @functions = Slice.new(tmp, funcs.size - 1)
#       end
#     end
#   end

#   def remove_owner(owner : Object)
#     modified_stats = [] of Stats

#     @functions.each do |func|
#       if func.owner == owner
#         modified_stats << func.stat
#         remove_func(func)
#       end
#     end

#     modified_stats
#   end

#   def calc(caster, target, skill, value) : Float64
#     @functions.reduce(value) { |v, f| f.calc(caster, target, skill, v) }
#   end
# end
