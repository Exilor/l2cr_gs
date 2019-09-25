module TargetHandler
  include Loggable

  private HANDLERS = EnumMap(L2TargetType, self).new
  private EMPTY_TARGET_LIST = [] of L2Object

  def self.load
    {% for const in @type.constants %}
      const = {{const.id}}
      if const.is_a?(self)
        register(const)
      end
    {% end %}
  end

  def self.register(handler : self)
    HANDLERS[handler.target_type] = handler
  end

  def self.[](type : L2TargetType) : self?
    HANDLERS[type]?
  end

  # abstract def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
  # abstract def target_type : L2TargetType
end

require "./target_handlers/*"
