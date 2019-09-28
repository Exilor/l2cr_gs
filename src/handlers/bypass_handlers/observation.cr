module BypassHandler::Observation
  extend self
  extend BypassHandler

  private LOCATIONS = {
    # Gludio
    {-18347, 114000, -2360, 500},
    {-18347, 113255, -2447, 500},
    # Dion
    {22321, 155785, -2604, 500},
    {22321, 156492, -2627, 500},
    # Giran
    {112000, 144864, -2445, 500},
    {112657, 144864, -2525, 500},
    # Innadril
    {116260, 244600, -775, 500},
    {116260, 245264, -721, 500},
    # Oren
    {78100, 36950, -2242, 500},
    {78744, 36950, -2244, 500},
    # Aden
    {147457, 9601, -233, 500},
    {147457, 8720, -252, 500},
    # Goddard
    {147542, -43543, -1328, 500},
    {147465, -45259, -1328, 500},
    # Rune
    {20598, -49113, -300, 500},
    {18702, -49150, -600, 500},
    # Schuttgart
    {77541, -147447, 353, 500},
    {77541, -149245, 353, 500},
    # Coliseum
    {148416, 46724, -3000, 80},
    {149500, 46724, -3000, 80},
    {150511, 46724, -3000, 80},
    # Dusk
    {-77200, 88500, -4800, 500},
    {-75320, 87135, -4800, 500},
    {-76840, 85770, -4800, 500},
    {-76840, 85770, -4800, 500},
    {-79950, 85165, -4800, 500},
    # Dawn
    {-79185, 112725, -4300, 500},
    {-76175, 113330, -4300, 500},
    {-74305, 111965, -4300, 500},
    {-75915, 110600, -4300, 500},
    {-78930, 110005, -4300, 500}
  }

  def use_bypass(command, pc, target)
    unless target.is_a?(L2ObservationInstance)
      return false
    end

    if pc.has_summon?
      pc.send_packet(SystemMessageId::NO_OBSERVE_WITH_PET)
      return false
    end

    if pc.on_event?
      pc.send_message("Cannot observe while participating in an event")
      return false
    end

    cmd = command.split.first.downcase
    begin
      param = command.split[1].to_i
    rescue e
      warn e
      return false
    end

    if param < 0
      return false
    end

    unless loc_cost = LOCATIONS[param]?
      return false
    end

    loc = Location.new(*loc_cost)
    cost = loc_cost[3].to_i64

    case cmd
    when "observesiege"
      if SiegeManager.get_siege(loc)
        do_observe(pc, target, loc, cost)
      else
        pc.send_packet(SystemMessageId::ONLY_VIEW_SIEGE)
      end

      return true
    when "observeoracle", "observe"
      do_observe(pc, target, loc, cost)
      return true
    end

    false
  end

  private def do_observe(pc, npc, pos, cost)
    if pc.reduce_adena("Broadcast", cost, npc, true)
      pc.enter_observer_mode(pos)
      pc.send_packet(ItemList.new(pc, false))
    end

    pc.action_failed
  end

  def commands
    {"observesiege", "observeoracle", "observe"}
  end
end
