class EffectHandler::TransformHangover < AbstractEffect
  def on_action_time(info : BuffInfo) : Bool
    true
  end
end
