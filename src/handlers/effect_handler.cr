require "../models/effects/abstract_effect"

module EffectHandler
  extend self

  private HANDLERS = {} of String => AbstractEffect.class

  def load
    {% for sub in AbstractEffect.all_subclasses %}
      register({{sub.id}})
    {% end %}
  end

  def register(handler : AbstractEffect.class)
    HANDLERS[handler.simple_name] = handler
  end

  def [](effect_name : String) : (AbstractEffect.class)?
    HANDLERS[effect_name]?
  end
end

require "./effect_handlers/**"
