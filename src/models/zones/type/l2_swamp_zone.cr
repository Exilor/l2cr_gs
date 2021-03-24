class L2SwampZone < L2ZoneType
  @castle_id = 0

  getter move_bonus = 0.0

  def set_parameter(name : String, value : String)
    case name
    when "move_bonus"
      @move_bonus = value.to_f
    when "castleId"
      @castle_id = value.to_i
    else
      super
    end
  end

  def castle : Castle?
    if @castle_id > 0 && @castle.nil?
      @castle = CastleManager.get_castle_by_id(@castle_id)
    end

    @castle
  end

  def on_enter(char)
    if castle = castle()
      unless castle.siege.in_progress? && enabled?
        return
      end

      pc = char.acting_player

      if pc && pc.in_siege? && pc.siege_state == 2
        return
      end

      char.inside_swamp_zone = true

      if char.player? && pc
        pc.broadcast_user_info
      end
    end
  end

  def on_exit(char)
    if char.inside_swamp_zone?
      char.inside_swamp_zone = false

      if char.is_a?(L2PcInstance)
        char.broadcast_user_info
      end
    end
  end
end
