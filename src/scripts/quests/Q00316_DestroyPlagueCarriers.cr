class Scripts::Q00316_DestroyPlagueCarriers < Quest
  # NPC
  private ELLENIA = 30155
  # Items
  private WERERAT_FANG = 1042
  private VAROOL_FOULCLAW_FANG = 1043
  # Misc
  private MIN_LEVEL = 18
  # Monsters
  private VAROOL_FOULCLAW = 27020
  private MONSTER_DROPS = {
    20040 => ItemHolder.new(WERERAT_FANG, 5), # Sukar Wererat
    20047 => ItemHolder.new(WERERAT_FANG, 5), # Sukar Wererat Leader
    VAROOL_FOULCLAW => ItemHolder.new(VAROOL_FOULCLAW_FANG, 7) # Varool Foulclaw
  }

  def initialize
    super(316, self.class.simple_name, "Destroy Plague Carriers")

    add_start_npc(ELLENIA)
    add_talk_id(ELLENIA)
    add_attack_id(VAROOL_FOULCLAW)
    add_kill_id(MONSTER_DROPS.keys)
    register_quest_items(WERERAT_FANG, VAROOL_FOULCLAW_FANG)
  end

  def check_party_member(qs, npc)
    npc.id != VAROOL_FOULCLAW || !qs.has_quest_items?(VAROOL_FOULCLAW_FANG)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "30155-04.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30155-08.html"
      qs.exit_quest(true, true)
      html = event
    when "30155-09.html"
      html = event
    end

    html
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.script_value?(0)
      npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::WHY_DO_YOU_OPPRESS_US_SO))
      npc.script_value = 1
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, -1, 3, npc)
    if qs
      item = MONSTER_DROPS[npc.id]
      limit = npc.id == VAROOL_FOULCLAW ? 1 : 0
      give_item_randomly(qs.player, npc, item.id, 1, limit, 10.0 / item.count, true)
    end

    super
  end

  def on_talk(npc, pc)
    unless qs = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    if qs.created?
      if !pc.race.elf?
        html = "30155-00.htm"
      elsif pc.level < MIN_LEVEL
        html = "30155-02.htm"
      else
        html = "30155-03.htm"
      end
    elsif qs.started?
      if has_at_least_one_quest_item?(pc, registered_item_ids)
        wererats = get_quest_items_count(pc, WERERAT_FANG)
        foulclaws = get_quest_items_count(pc, VAROOL_FOULCLAW_FANG)
        adena = (wererats * 30) + (foulclaws * 10000)
        if wererats + foulclaws >= 10
          adena += 5000
        end
        give_adena(pc, adena, true)
        take_items(pc, -1, registered_item_ids)
        html = "30155-07.html"
      else
        html = "30155-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
