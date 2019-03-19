class Quests::Q00366_SilverHairedShaman < Quest
  # NPC
  private DIETER = 30111
  # Item
  private SAIRONS_SILVER_HAIR = 5874
  # Misc
  private MIN_LEVEL = 48
  # Mobs
  private MOBS = {
    20986 => 80, # saitnn
    20987 => 73, # saitnn_doll
    20988 => 80  # saitnn_puppet
  }

  def initialize
    super(366, self.class.simple_name, "Silver Haired Shaman")

    add_start_npc(DIETER)
    add_talk_id(DIETER)
    add_kill_id(MOBS.keys)
    register_quest_items(SAIRONS_SILVER_HAIR)
  end

  def check_party_member(member, npc)
    qs = get_quest_state(member, false)
    !!qs && qs.started?
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30111-02.htm"
      st.start_quest
      event
    when "30111-05.html"
      st.exit_quest(true, true)
      event
    when "30111-06.html"
      event
    end
  end

  def on_kill(npc, pc, is_summon)
    if rand(100) < MOBS[npc.id]
      winner = get_random_party_member(pc, npc)
      if winner
        give_item_randomly(winner, npc, SAIRONS_SILVER_HAIR, 1, 0, 1.0, true)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      html = pc.level >= MIN_LEVEL ? "30111-01.htm" : "30111-03.html"
    elsif st.started?
      if has_quest_items?(pc, SAIRONS_SILVER_HAIR)
        item_count = get_quest_items_count(pc, SAIRONS_SILVER_HAIR)
        give_adena(pc, (item_count * 500) + 29000, true)
        take_items(pc, SAIRONS_SILVER_HAIR, -1)
        html = "30111-04.html"
      else
        html = "30111-07.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
