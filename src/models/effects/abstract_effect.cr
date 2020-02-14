require "../../handlers/effect_handler"

abstract class AbstractEffect
  include AbstractEventListener::Owner
  include Loggable
  include Packets::Outgoing

  getter name : String
  getter ticks = 0
  getter func_templates : Array(FuncTemplate)?

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    @attach_cond = attach_cond
    @name = set.get_string("name")
  end

  def self.create_effect(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet?) : self
    name = set.get_string("name")

    unless handler = EffectHandler[name]
      raise "No effect handler for \"#{name}\""
    end

    handler.new(attach_cond, apply_cond, set, params)
  end

  def attach(template : FuncTemplate)
    (@func_templates ||= [] of FuncTemplate) << template
  end

  def ticks_multiplier : Float64
    (ticks * Config.effect_tick_ratio) / 1000
  end

  def calc_success(info : BuffInfo) : Bool
    true
  end

  def effect_type : EffectType
    EffectType::NONE
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

  def check_condition(object) : Bool
    true
  end

  def instant? : Bool
    false
  end

  def get_stat_funcs(caster : L2Character, target : L2Character, skill : Skill) : Indexable(AbstractFunction)
    if templates = @func_templates
      ret = nil

      templates.each do |template|
        if fn = template.get_func(caster, target, skill, self)
          ret ? ret << fn : (ret = [fn] of AbstractFunction)
        end
      end

      if ret && !ret.empty?
        return ret
      end
    end

    Slice(AbstractFunction).empty
  end
end
