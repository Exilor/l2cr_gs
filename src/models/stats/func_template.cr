require "./abstract_function"
require "../../enums/stat_function"

struct FuncTemplate
  @order : Int32
  @constructor : AbstractFunction.class

  getter stat, order, value

  def initialize(attach_cond : Condition?, apply_cond : Condition?, function_name : String, order : Int32, stat : Stats, value : Float64)
    @attach_cond = attach_cond
    @apply_cond = apply_cond
    @stat = stat
    @value = value
    function = StatFunction.parse(function_name)

    @order = order >= 0 ? order : function.order

    @constructor = {% begin %}
      case "Func#{function.name}"
      {% for sub in %w(Add Div Enchant EnchantHp Mul Set Sub) %}
        when "Func{{sub.id}}"
          Func{{sub.id}}
      {% end %}
      else
        raise "Constructor for Func#{function.name} not found"
      end
    {% end %}
  end

  def get_func(caster : L2Character, target : L2Character?, skill : Skill?, owner) : AbstractFunction?
    get_func(caster, target, skill, nil, owner)
  end

  def get_func(caster : L2Character, target : L2Character?, item : L2ItemInstance?, owner) : AbstractFunction?
    get_func(caster, target, nil, item, owner)
  end

  def get_func(caster : L2Character, target : L2Character?, skill : Skill?, item : L2ItemInstance?, owner) : AbstractFunction?
    cond = @attach_cond

    if cond && !cond.test(caster, target, skill, item.try &.template)
      return
    end

    # Using ::new directly conflicts with subclasses with a 0-arity #initialize
    func = @constructor.allocate
    func.public_initialize(@stat, @order, owner, @value, @apply_cond)
    func
  end
end
