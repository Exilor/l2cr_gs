require "../../handlers/effect_handler"

abstract class AbstractEffect
  include Loggable
  include Packets::Outgoing

  getter name : String
  getter ticks = 0
  getter func_templates : Array(FuncTemplate)?

  def initialize(@attach_cond : Condition?, @apply_cond : Condition?, @set : StatsSet, @params : StatsSet)
    @name = set.get_string("name")
  end

  def self.create_effect(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet?) : self
    name = set.get_string("name")

    unless handler = EffectHandler[name]
      raise "no such effect handler: #{name.inspect}"

      # set = StatsSet {"name" => name}
      # return NotImplementedEffect.new(attach_cond, apply_cond, set, params)
    end

    handler.new(attach_cond, apply_cond, set, params)
  end

  def attach(template : FuncTemplate)
    (@func_templates ||= [] of FuncTemplate) << template
  end

  def ticks_multiplier : Float64
    (ticks * Config.effect_tick_ratio).fdiv(1000)
  end

  def calc_success(info : BuffInfo) : Bool
    true
  end

  def effect_type : L2EffectType
    L2EffectType::NONE
  end

  def can_start?(info : BuffInfo) : Bool
    true
  end

  def on_start(info : BuffInfo)
    # no-op
  end

  def on_action_time(info : BuffInfo) : Bool
    false
  end

  def on_exit(info : BuffInfo)
    # no-op
  end

  def effect_flags
    EffectFlag::NONE.mask
  end

  def decrease_force
    # no-op
  end

  def increase_effect
    # no-op
  end

  def check_condition(object) : Bool
    true
  end

  def instant? : Bool
    false
  end

  def get_stat_funcs(caster : L2Character, target : L2Character, skill : Skill)
    if func_templates = @func_templates
      temp = nil

      func_templates.each do |template|
        if fn = template.get_func(caster, target, skill, self)
          if temp
            temp << fn
          else
            temp = [fn] of AbstractFunction
          end
        end
      end

      if temp && !temp.empty?
        return temp
      end
    end

    Slice(AbstractFunction).empty
  end
end


class NotImplementedEffect < AbstractEffect
  def initialize(attach_cond, apply_cond, set, params)
    super

    @name = set.get_string("name")
  end

  def on_start(info)
    if info.effected.player?
      debug "Not implemented."
    end
  end

  def to_log(io : IO)
    io << "NotImplementedEffect(#{@name})"
  end
end
