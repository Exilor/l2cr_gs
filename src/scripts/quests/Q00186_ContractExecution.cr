class Scripts::Q00186_ContractExecution < Quest
  # NPCs
  private MAESTRO_NIKOLA = 30621
  private RESEARCHER_LORAIN = 30673
  private BLUEPRINT_SELLER_LUKA = 31437
  # Items
  private LORAINES_CERTIFICATE = 10362
  private METALLOGRAPH_RESEARCH_REPORT = 10366
  private LETO_LIZARDMAN_ACCESSORY = 10367
  # Misc
  private MIN_LEVEL = 41
  private MAX_LEVEL_FOR_EXP_SP = 47
  # Monsters
  private MONSTERS = {
    20577 => 40, # Leto Lizardman
    20578 => 44, # Leto Lizardman Archer
    20579 => 46, # Leto Lizardman Soldier
    20580 => 88, # Leto Lizardman Warrior
    20581 => 50, # Leto Lizardman Shaman
    20582 => 100 # Leto Lizardman Overlord
  }

  def initialize
    super(186, self.class.simple_name, "Contract Execution")

    add_start_npc(RESEARCHER_LORAIN)
    add_talk_id(RESEARCHER_LORAIN, BLUEPRINT_SELLER_LUKA, MAESTRO_NIKOLA)
    add_kill_id(MONSTERS.keys)
    register_quest_items(METALLOGRAPH_RESEARCH_REPORT, LETO_LIZARDMAN_ACCESSORY)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30673-03.htm"
      if pc.level >= MIN_LEVEL && has_quest_items?(pc, LORAINES_CERTIFICATE)
        qs.start_quest
        qs.memo_state = 1
        give_items(pc, METALLOGRAPH_RESEARCH_REPORT, 1)
        take_items(pc, LORAINES_CERTIFICATE, -1)
        html = event
      end
    when "30621-02.html"
      if qs.memo_state?(1)
        html = event
      end
    when "30621-03.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = event
      end
    when "31437-03.html"
      if qs.memo_state?(2) && has_quest_items?(pc, LETO_LIZARDMAN_ACCESSORY)
        html = event
      end
    when "31437-04.html"
      if qs.memo_state?(2) && has_quest_items?(pc, LETO_LIZARDMAN_ACCESSORY)
        qs.memo_state = 3
        html = event
      end
    when "31437-06.html"
      if qs.memo_state?(3)
        give_adena(pc, 105083, true)
        if pc.level < MAX_LEVEL_FOR_EXP_SP
          add_exp_and_sp(pc, 285935, 18711)
        end
        qs.exit_quest(false, true)
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.memo_state?(2) && Util.in_range?(1500, npc, killer, false)
      if Rnd.rand(100) < MONSTERS[npc.id]
        unless has_quest_items?(killer, LETO_LIZARDMAN_ACCESSORY)
          give_items(killer, LETO_LIZARDMAN_ACCESSORY, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == RESEARCHER_LORAIN
        if pc.quest_completed?(Q00184_ArtOfPersuasion.simple_name)
          if has_quest_items?(pc, LORAINES_CERTIFICATE)
            html = pc.level >= MIN_LEVEL ? "30673-01.htm" : "30673-02.htm"
          end
        end
      end
    elsif qs.started?
      case npc.id
      when RESEARCHER_LORAIN
        if memo_state >= 1
          html = "30673-04.html"
        end
      when MAESTRO_NIKOLA
        if memo_state == 1
          html = "30621-01.html"
        elsif memo_state == 2
          html = "30621-04.html"
        end
      when BLUEPRINT_SELLER_LUKA
        if memo_state == 2
          if has_quest_items?(pc, LETO_LIZARDMAN_ACCESSORY)
            html = "31437-02.html"
          else
            html = "31437-01.html"
          end
        elsif memo_state == 3
          html = "31437-05.html"
        end
      else
        # [automatically added else]
      end

    elsif qs.completed?
      if npc.id == RESEARCHER_LORAIN
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
