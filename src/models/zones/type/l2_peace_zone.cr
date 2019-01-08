class L2PeaceZone < L2ZoneType
  def on_enter(char)
    if char.player?
      pc = char.acting_player
      if pc.combat_flag_equipped? && TerritoryWarManager.tw_in_progress?
        TerritoryWarManager.drop_combat_flag(pc, false, true)
      end

      if pc.siege_state != 0 && Config.peace_zone_mode == 1
        return
      end
    end

    if Config.peace_zone_mode != 2
      char.inside_peace_zone = true
    end

    unless allow_store?
      char.inside_no_store_zone = true
    end
  end

  def on_exit(char)
    if Config.peace_zone_mode != 2
      char.inside_peace_zone = false
    end

    unless allow_store?
      char.inside_no_store_zone = false
    end
  end
end
