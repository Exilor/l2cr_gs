class Quests::Q00340_SubjugationOfLizardmen < Quest
  # NPCs
  private HIGH_PRIESTESS_LEVIAN = 30037
  private PRIEST_ADONIUS = 30375
  private GUARD_WEISZ = 30385
  private CHEST_OF_BIFRONS = 30989
  # Items
  private TRADE_CARGO = 4255
  private AGNESS_HOLY_SYMBOL = 4256
  private AGNESS_ROSARY = 4257
  private SINISTER_TOTEM = 4258
  # Monster
  private FELIM_LIZARDMAN = 20008
  private FELIM_LIZARDMAN_SCOUT = 20010
  private FELIM_LIZARDMAN_WARRIOR = 20014
  private LANGK_LIZARDMAN_WARRIOR = 20024
  private LANGK_LIZARDMAN_SCOUT = 20027
  private LANGK_LIZARDMAN = 20030
  # Raid Boss
  private SERPENT_DEMON_BIFRONS = 25146
  # Misc
  private MIN_LEVEL = 17

  def initialize
    super(340, self.class.simple_name, "Subjugation Of Lizardmen")

    add_start_npc(GUARD_WEISZ)
    add_talk_id(GUARD_WEISZ, HIGH_PRIESTESS_LEVIAN, PRIEST_ADONIUS, CHEST_OF_BIFRONS)
    add_kill_id(FELIM_LIZARDMAN, FELIM_LIZARDMAN_SCOUT, FELIM_LIZARDMAN_WARRIOR, LANGK_LIZARDMAN_WARRIOR, LANGK_LIZARDMAN_SCOUT, LANGK_LIZARDMAN, SERPENT_DEMON_BIFRONS)
    register_quest_items(TRADE_CARGO, AGNESS_HOLY_SYMBOL, AGNESS_ROSARY, SINISTER_TOTEM)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30385-03.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        html = event
      end
    when "30385-04.html", "30385-08.html"
      html = event
    when "30385-07.html"
      take_items(pc, TRADE_CARGO, -1)
      qs.memo_state = 2
      qs.set_cond(2, true)
      html = event
    when "30385-09.html"
      if get_quest_items_count(pc, TRADE_CARGO) >= 30
        give_adena(pc, 4090, true)
        take_items(pc, TRADE_CARGO, -1)
        qs.memo_state = 1
        html = event
      end
    when "30385-10.html"
      if get_quest_items_count(pc, TRADE_CARGO) >= 30
        give_adena(pc, 4090, true)
        take_items(pc, TRADE_CARGO, -1)
        qs.exit_quest(false, true)
        html = event
      end
    when "30037-02.html"
      qs.memo_state = 5
      qs.set_cond(5, true)
      html = event
    when "30375-02.html"
      qs.memo_state = 3
      qs.set_cond(3, true)
      html = event
    when "30989-02.html"
      if qs.memo_state?(5)
        qs.memo_state = 6
        qs.set_cond(6, true)
        give_items(pc, SINISTER_TOTEM, 1)
        html = event
      else
        html = "30989-03.html"
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when FELIM_LIZARDMAN, FELIM_LIZARDMAN_SCOUT
        if qs.memo_state?(1)
          give_item_randomly(killer, npc, TRADE_CARGO, 1, 30, 0.63, true)
        end
      when FELIM_LIZARDMAN_WARRIOR
        if qs.memo_state?(1)
          give_item_randomly(killer, npc, TRADE_CARGO, 1, 30, 0.68, true)
        end
      when LANGK_LIZARDMAN_WARRIOR
        if qs.memo_state?(3)
          if !has_quest_items?(killer, AGNESS_HOLY_SYMBOL) && rand(100) <= 19
            give_items(killer, AGNESS_HOLY_SYMBOL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          elsif has_quest_items?(killer, AGNESS_HOLY_SYMBOL) && !has_quest_items?(killer, AGNESS_ROSARY) && rand(100) <= 18
            give_items(killer, AGNESS_ROSARY, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when LANGK_LIZARDMAN_SCOUT, LANGK_LIZARDMAN
        if qs.memo_state?(3)
          if !has_quest_items?(killer, AGNESS_HOLY_SYMBOL) && rand(100) <= 18
            give_items(killer, AGNESS_HOLY_SYMBOL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          elsif has_quest_items?(killer, AGNESS_HOLY_SYMBOL) && !has_quest_items?(killer, AGNESS_ROSARY) && rand(100) <= 18
            give_items(killer, AGNESS_ROSARY, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when SERPENT_DEMON_BIFRONS
        add_spawn(CHEST_OF_BIFRONS, npc, true, 30000)
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == GUARD_WEISZ
        html = pc.level >= MIN_LEVEL ? "30385-02.htm" : "30385-01.htm"
      end
    elsif qs.started?
      case npc.id
      when GUARD_WEISZ
        if memo_state == 1
          if get_quest_items_count(pc, TRADE_CARGO) < 30
            html = "30385-05.html"
          else
            html = "30385-06.html"
          end
        elsif memo_state == 2
          html = "30385-11.html"
        elsif memo_state >= 3 && memo_state < 7
          html = "30385-12.html"
        elsif memo_state == 7
          give_adena(pc, 14700, true)
          qs.exit_quest(false, true)
          html = "30385-13.html"
        end
      when HIGH_PRIESTESS_LEVIAN
        if memo_state == 4
          html = "30037-01.html"
        elsif memo_state == 5
          html = "30037-03.html"
        elsif memo_state == 6
          take_items(pc, SINISTER_TOTEM, 1)
          qs.memo_state = 7
          qs.set_cond(7, true)
          html = "30037-04.html"
        elsif memo_state == 7
          html = "30037-05.html"
        end
      when PRIEST_ADONIUS
        if memo_state == 2
          html = "30375-01.html"
        elsif memo_state == 3
          if has_quest_items?(pc, AGNESS_HOLY_SYMBOL, AGNESS_ROSARY)
            take_items(pc, AGNESS_HOLY_SYMBOL, 1)
            take_items(pc, AGNESS_ROSARY, 1)
            qs.memo_state = 4
            qs.set_cond(4, true)
            html = "30375-04.html"
          else
            html = "30375-03.html"
          end
        elsif memo_state == 4
          html = "30375-05.html"
        elsif memo_state >= 5
          html = "30375-06.html"
        end
      when CHEST_OF_BIFRONS
        if memo_state == 5
          html = "30989-01.html"
        end
      end
    elsif qs.completed?
      if npc.id == GUARD_WEISZ
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
