class Scripts::TeleportToUndergroundColiseum < AbstractNpcAI
  # NPCs
  private COLISEUM_HELPER = 32491
  private PADDIES = 32378
  private MANAGERS = {
    32377,
    32513,
    32514,
    32515,
    32516
  }

  # Locations
  private COLISEUM_LOCS = {
    Location.new(-81896, -49589, -10352),
    Location.new(-82271, -49196, -10352),
    Location.new(-81886, -48784, -10352),
    Location.new(-81490, -49167, -10352)
  }

  private RETURN_LOCS = {
    Location.new(-59161, -56954, -2036),
    Location.new(-59155, -56831, -2036),
    Location.new(-59299, -56955, -2036),
    Location.new(-59224, -56837, -2036),
    Location.new(-59134, -56899, -2036)
  }

  private MANAGERS_LOCS = {
    {
      Location.new(-84451, -45452, -10728),
      Location.new(-84580, -45587, -10728)
    },
    {
      Location.new(-86154, -50429, -10728),
      Location.new(-86118, -50624, -10728)
    },
    {
      Location.new(-82009, -53652, -10728),
      Location.new(-81802, -53665, -10728)
    },
    {
      Location.new(-77603, -50673, -10728),
      Location.new(-77586, -50503, -10728)
    },
    {
      Location.new(-79186, -45644, -10728),
      Location.new(-79309, -45561, -10728)
    }
  }

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(MANAGERS)
    add_start_npc(COLISEUM_HELPER, PADDIES)
    add_first_talk_id(COLISEUM_HELPER)
    add_talk_id(MANAGERS)
    add_talk_id(COLISEUM_HELPER, PADDIES)
  end

  def on_adv_event(event, npc, player)
    return unless player

    if event.ends_with?(".htm")
      return event
    elsif event == "return"
      player.tele_to_location(RETURN_LOCS.sample(random: Rnd), false)
    elsif event.num?
      val = event.to_i - 1
      player.tele_to_location(MANAGERS_LOCS[val].sample(random: Rnd), false)
    end

    nil
  end

  def on_talk(npc, player)
    if MANAGERS.includes?(npc.id)
      player.tele_to_location(RETURN_LOCS.sample(random: Rnd), false)
    else
      player.tele_to_location(COLISEUM_LOCS.sample(random: Rnd), false)
    end

    nil
  end

  def on_first_talk(npc, player)
    "32491.htm"
  end
end
