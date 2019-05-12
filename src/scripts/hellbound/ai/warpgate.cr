class Scripts::Warpgate < AbstractNpcAI
  # NPCs
  private WARPGATES = {
    32314,
    32315,
    32316,
    32317,
    32318,
    32319,
  }
  # Locations
  private ENTER_LOC = Location.new(-11272, 236464, -3248)
  private REMOVE_LOC = Location.new(-16555, 209375, -3670)
  # Item
  private MAP = 9994
  # Misc
  private ZONE = 40101

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_start_npc(WARPGATES)
    add_first_talk_id(WARPGATES)
    add_talk_id(WARPGATES)
    add_enter_zone_id(ZONE)
  end

  def on_adv_event(event, npc, player)
    return unless player

    if event == "enter"
      if can_enter?(player)
        player.tele_to_location(ENTER_LOC, true)
      else
        return "Warpgate-03.html"
      end
    elsif event == "TELEPORT"
      player.tele_to_location(REMOVE_LOC, true)
    end

    super
  end

  def on_first_talk(npc, player)
    HellboundEngine.locked? ? "Warpgate-01.html" : "Warpgate-02.html"
  end

  def on_enter_zone(character, zone)
    if character.player?
      pc = character.acting_player

      if !can_enter?(pc) && !pc.override_zone_conditions? && !pc.on_event?
        start_quest_timer("TELEPORT", 1000, nil, pc)
      elsif !pc.minimap_allowed? && has_at_least_one_quest_item?(pc, MAP)
        pc.minimap_allowed = true
      end
    end

    super
  end

  private def can_enter?(player)
    if player.flying?
      return false
    end

    if Config.hellbound_without_quest
      return true
    end

    player.quest_completed?(Scripts::Q00130_PathToHellbound.simple_name) ||
    player.quest_completed?(Scripts::Q00133_ThatsBloodyHot.simple_name)
  end
end
