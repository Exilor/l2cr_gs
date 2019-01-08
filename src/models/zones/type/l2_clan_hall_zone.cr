class L2ClanHallZone < L2ResidenceZone
  def set_parameter(name, value)
    if name == "clanHallId"
      self.residence_id = value.to_i

      if hall = ClanHallManager.get_clan_hall_by_id(residence_id)
        hall.zone = self
      else
        warn "Clan hall with ID #{residence_id} not found."
      end
    else
      super
    end
  end

  def on_enter(char)
    if char.player?
      char.inside_clan_hall_zone = true
      unless hall = ClanHallManager.get_auctionable_hall_by_id(residence_id)
        return
      end

      char.send_packet(AgitDecoInfo.new(hall))
    end
  end

  def on_exit(char)
    if char.player?
      char.inside_clan_hall_zone = false
    end
  end
end
