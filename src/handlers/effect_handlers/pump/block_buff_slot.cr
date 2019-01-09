class EffectHandler::BlockBuffSlot < AbstractEffect
  @slots : Array(AbnormalType)?

  def initialize(attach_cond, apply_cond, set, params)
    super

    temp = params.get_string("slot", nil)

    if temp && !temp.empty?
      @slots = temp.split(';').map { |s| AbnormalType.parse(s) }.uniq!
    end
  end

  def on_start(info)
    if slots = @slots
      info.effected.effect_list.add_blocked_buff_slots(slots)
    end
  end

  def on_exit(info)
    if slots = @slots
      info.effected.effect_list.remove_blocked_buff_slots(slots)
    end
  end
end
