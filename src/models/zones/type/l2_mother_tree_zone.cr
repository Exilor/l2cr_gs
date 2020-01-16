class L2MotherTreeZone < L2ZoneType
  @enter_msg = 0
  @leave_msg = 0

  getter mp_regen_bonus = 0
  getter hp_regen_bonus = 0

  def set_parameter(name, value)
    case name
    when "enterMsgId"
      @enter_msg = value.to_i
    when "leaveMsgId"
      @leave_msg = value.to_i
    when "MpRegenBonus"
      @mp_regen_bonus = value.to_i
    when "HpRegenBonus"
      @hp_regen_bonus = value.to_i
    else
      super
    end
  end

  def on_enter(char)
    if char.player?
      char.inside_mother_tree_zone = true
      if @enter_msg != 0
        char.send_packet(SystemMessage[@enter_msg])
      end
    end
  end

  def on_exit(char)
    if char.player?
      char.inside_mother_tree_zone = false
      if @leave_msg != 0
        char.send_packet(SystemMessage[@leave_msg])
      end
    end
  end
end
