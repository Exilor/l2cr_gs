class Scripts::PaganTeleporters < AbstractNpcAI
  # NPCs
  private TRIOLS_MIRROR_1 = 32039
  private TRIOLS_MIRROR_2 = 32040
  # Locations
  private TRIOLS_LOCS = {
    TRIOLS_MIRROR_1 => Location.new(-12766, -35840, -10856),
    TRIOLS_MIRROR_2 => Location.new(36640, -51218, 718)
  }
  private NPCS = {
    32034, 32035, 32036, 32037, 32039, 32040
  }
  # Items
  private VISITORS_MARK = 8064
  private FADED_VISITORS_MARK = 8065
  private PAGANS_MARK = 8067

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
    add_first_talk_id(TRIOLS_MIRROR_1, TRIOLS_MIRROR_2)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "Close_Door1"
      close_door(19160001, 0)
    when "Close_Door2"
      close_door(19160010, 0)
      close_door(19160011, 0)
    end

    ""
  end

  def on_first_talk(npc, pc)
    if tmp = TRIOLS_LOCS[npc.id]?
      pc.tele_to_location(tmp)
    end

    ""
  end

  def on_talk(npc, pc)
    case npc.id
    when 32034
      unless has_at_least_one_quest_item?(pc, VISITORS_MARK, FADED_VISITORS_MARK, PAGANS_MARK)
        return "noItem.htm"
      end
      open_door(19160001, 0)
      start_quest_timer("Close_Door1", 10_000, nil, nil)
      return "FadedMark.htm"
    when 32035
      open_door(19160001, 0)
      start_quest_timer("Close_Door1", 10_000, nil, nil)
      return "FadedMark.htm"
    when 32036
      unless has_quest_items?(pc, PAGANS_MARK)
        return "noMark.htm"
      end
      start_quest_timer("Close_Door2", 10_000, nil, nil)
      open_door(19160010, 0)
      open_door(19160011, 0)
      return "open_door.htm"
    when 32037
      open_door(19160010, 0)
      open_door(19160011, 0)
      start_quest_timer("Close_Door2", 10_000, nil, nil)
      return "FadedMark.htm"
    end

    super
  end
end
