class EffectHandler::TrapRemove < AbstractEffect
  @power : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    if params.empty?
      raise ArgumentError.new("effect without power")
    end

    @power = params.get_i32("power")
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    trap = info.effected
    return unless trap.is_a?(L2TrapInstance)
    return if trap.looks_dead?
    effector = info.effector

    unless trap.can_be_seen?(effector)
      if effector.player?
        effector.send_packet(SystemMessageId::INCORRECT_TARGET)
      end

      return
    end

    return if trap.level > @power

    OnTrapAction.new(trap, effector, TrapAction::DISARMED).async(trap)

    trap.unsummon

    if effector.player?
      effector.send_packet(SystemMessageId::A_TRAP_DEVICE_HAS_BEEN_STOPPED)
    end
  end
end
