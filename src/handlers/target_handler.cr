module TargetHandler
  include Loggable

  private HANDLERS = EnumMap(TargetType, self).new
  private EMPTY_TARGET_LIST = [] of L2Object

  def self.load
    {% for const in @type.constants %}
      obj = {{const.id}}
      if obj.is_a?(self)
        register(obj)
      end
    {% end %}
  end

  def self.register(handler : self)
    HANDLERS[handler.target_type] = handler
  end

  def self.[](type : TargetType) : self?
    HANDLERS[type]?
  end

  # abstract def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
  # abstract def target_type : TargetType

  private def add_summon(caster : L2Character, owner : L2PcInstance, radius : Int32, dead : Bool) : L2Character?
    if summon = owner.summon
      add_character(caster, summon, radius, dead)
    end
  end

  private def add_character(caster : L2Character, target : L2Character, radius : Int32, dead : Bool) : L2Character?
    return if dead != target.dead?
    if radius > 0 && !Util.in_range?(radius, caster, target, true)
      return
    end
    target
  end
end

require "./target_handlers/*"
