class L2ResidenceTeleportZone < L2ZoneRespawn
  getter residence_id = 0

  def set_parameter(name, value)
    if name == "residenceId"
      @residence_id = value.to_i
    else
      super
    end
  end

  def on_enter(char)
    char.inside_no_summon_friend_zone = true
  end

  def on_exit(char)
    char.inside_no_summon_friend_zone = false
  end

  def oust_all_players
    players_inside do |pc|
      if pc.online?
        pc.tele_to_location(spawn_loc, 200)
      end
    end
  end
end
