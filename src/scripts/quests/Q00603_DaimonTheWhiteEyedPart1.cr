class Scripts::Q00603_DaimonTheWhiteEyedPart1 < Quest
  # NPC
  private EYE_OF_ARGOS = 31683
  private TABLET_1 = 31548
  private TABLET_2 = 31549
  private TABLET_3 = 31550
  private TABLET_4 = 31551
  private TABLET_5 = 31552
  # Items
  private SPIRIT_OF_DARKNESS = 7190
  private BROKEN_CRYSTAL = 7191
  # Monsters
  private MONSTER_CHANCES = {
    21297 => 0.5,   # Canyon Bandersnatch Slave
    21299 => 0.519, # Buffalo Slave
    21304 => 0.673  # Grendel Slave
  }
  # Reward
  private UNFINISHED_CRYSTAL = 7192
  # Misc
  private MIN_LVL = 73

  def initialize
    super(603, self.class.simple_name, "Daimon the White-Eyed - Part 1")

    add_start_npc(EYE_OF_ARGOS)
    add_talk_id(EYE_OF_ARGOS, TABLET_1, TABLET_2, TABLET_3, TABLET_4, TABLET_5)
    add_kill_id(MONSTER_CHANCES.keys)
    register_quest_items(SPIRIT_OF_DARKNESS, BROKEN_CRYSTAL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31683-03.htm"
      if qs.created?
        qs.set("tablet_#{TABLET_1}", 0)
        qs.set("tablet_#{TABLET_2}", 0)
        qs.set("tablet_#{TABLET_3}", 0)
        qs.set("tablet_#{TABLET_4}", 0)
        qs.set("tablet_#{TABLET_5}", 0)
        qs.start_quest
        html = event
      end
    when "31548-02.html", "31549-02.html", "31550-02.html", "31551-02.html",
         "31552-02.html"
      if qs.cond < 6
        give_items(pc, BROKEN_CRYSTAL, 1)
        qs.set("TABLET_#{npc.not_nil!.id}", 1)
        qs.set_cond(qs.cond + 1, true)
        html = event
      end
    when "31683-06.html"
      if qs.cond?(6) && get_quest_items_count(pc, BROKEN_CRYSTAL) >= 5
        take_items(pc, BROKEN_CRYSTAL, -1)
        qs.set_cond(7, true)
        html = event
      end
    when "31683-10.html"
      if qs.cond?(8)
        if get_quest_items_count(pc, SPIRIT_OF_DARKNESS) >= 200
          take_items(pc, SPIRIT_OF_DARKNESS, -1)
          give_items(pc, UNFINISHED_CRYSTAL, 1)
          qs.exit_quest(true, true)
          html = event
        else
          html = "31683-11.html"
        end
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case qs.state
    when State::CREATED
      if npc.id == EYE_OF_ARGOS
        html = pc.level < MIN_LVL ? "31683-02.html" : "31683-01.htm"
      end
    when State::STARTED
      if npc.id == EYE_OF_ARGOS
        case qs.cond
        when 1..5
          html = "31683-04.html"
        when 6
          html = "31683-05.html"
        when 7
          html = "31683-07.html"
        when 8
          html = "31683-08.html"
        else
          # [automatically added else]
        end

      elsif qs.get_int("TABLET_#{npc.id}") == 0
        html = "#{npc.id}-01.html"
      else
        html = "#{npc.id}-03.html"
      end
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, 7, 3, npc)
      if give_item_randomly(qs.player, npc, SPIRIT_OF_DARKNESS, 1, 200, MONSTER_CHANCES[npc.id], true)
        qs.set_cond(8, true)
      end
    end

    super
  end
end
