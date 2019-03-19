class NpcAI::SeparatedSoul < AbstractNpcAI
  # NPCs
  private SEPARATED_SOULS = {
    32864,
    32865,
    32866,
    32867,
    32868,
    32869,
    32870,
    32891
  }

  # Items
  private WILL_OF_ANTHARAS = 17266
  private SEALED_BLOOD_CRYSTAL = 17267
  private ANTHARAS_BLOOD_CRYSTAL = 17268
  # Misc
  private MIN_LEVEL = 80
  # Locations
  private LOCATIONS = {
    1 => Location.new(117046, 76798, -2696),  # Hunter's Village
    2 => Location.new(99218, 110283, -3696),  # The Center of Dragon Valley
    3 => Location.new(116992, 113716, -3056), # Deep inside Dragon Valley(North)
    4 => Location.new(113203, 121063, -3712), # Deep inside Dragon Valley (South)
    5 => Location.new(146129, 111232, -3568), # Antharas' Lair - Magic Force Field Bridge
    6 => Location.new(148447, 110582, -3944), # Deep inside Antharas' Lair
    7 => Location.new(73122, 118351, -3714),  # Entrance to Dragon Valley
    8 => Location.new(131116, 114333, -3704)  # Entrance of Antharas' Lair
  }

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(SEPARATED_SOULS)
    add_talk_id(SEPARATED_SOULS)
    add_first_talk_id(SEPARATED_SOULS)
  end

  def on_first_talk(npc, player)
    "#{npc.id}.htm"
  end

  def on_adv_event(event, npc, player)
    return unless player

    ask = event.to_i
    case ask
    when 1..8
      if player.level >= MIN_LEVEL
        player.tele_to_location(LOCATIONS[ask], false)
      else
        return "no-level.htm"
      end
    when 23241
      if has_quest_items?(player, WILL_OF_ANTHARAS, SEALED_BLOOD_CRYSTAL)
        take_items(player, WILL_OF_ANTHARAS, 1)
        take_items(player, SEALED_BLOOD_CRYSTAL, 1)
        give_items(player, ANTHARAS_BLOOD_CRYSTAL, 1)
      else
        return "no-items.htm"
      end
    when 23242
      return "separatedsoul.htm"
    end

    super
  end
end
