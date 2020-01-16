class EffectHandler::BlockBuffSlot < AbstractEffect
  @slots = Slice(AbnormalType).empty

  def initialize(attach_cond, apply_cond, set, params)
    super

    temp = params.get_string("slot", nil)

    if temp && !temp.empty?
      @slots = temp.split(';').map { |s| AbnormalType.parse(s) }.uniq!.to_slice
    end
  end

  def on_start(info)
    unless @slots.empty?
      info.effected.effect_list.add_blocked_buff_slots(@slots)
    end
  end

  def on_exit(info)
    unless @slots.empty?
      info.effected.effect_list.remove_blocked_buff_slots(@slots)
    end
  end
end
