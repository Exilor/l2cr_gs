class Scripts::Q10289_FadeToBlack < Quest
  # NPC
  private GREYMORE = 32757
  # Items
  private MARK_OF_SPLENDOR = 15527
  private MARK_OF_DARKNESS = 15528
  # Monster
  private ANAYS = 25701

  def initialize
    super(10289, self.class.simple_name, "Fade to Black")

    add_start_npc(GREYMORE)
    add_talk_id(GREYMORE)
    add_kill_id(ANAYS)
    register_quest_items(MARK_OF_SPLENDOR, MARK_OF_DARKNESS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "32757-02.htm"
      html = event
    when "32757-03.htm"
      qs.start_quest
      html = event
    when "32757-06.html"
      if qs.cond?(2) && has_quest_items?(pc, MARK_OF_DARKNESS)
        html = "32757-07.html"
      elsif qs.cond?(3) && has_quest_items?(pc, MARK_OF_SPLENDOR)
        html = "32757-08.html"
      else
        html = event
      end
    when "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22",
         "23", "24", "25", "26", "27", "28", "29", "30"
      if qs.cond?(3) && has_quest_items?(pc, MARK_OF_SPLENDOR)
        # see 32757-08.html for recipe list (all moirai armor 60%)
        case event
        when "11"
          reward_items(pc, 15775, 1)
          give_adena(pc, 420920, true)
        when "12"
          reward_items(pc, 15776, 1)
          give_adena(pc, 420920, true)
        when "13"
          reward_items(pc, 15777, 1)
          give_adena(pc, 420920, true)
        when "14"
          reward_items(pc, 15778, 1)
        when "15"
          reward_items(pc, 15779, 1)
          give_adena(pc, 168360, true)
        when "16"
          reward_items(pc, 15780, 1)
          give_adena(pc, 168360, true)
        when "17"
          reward_items(pc, 15781, 1)
          give_adena(pc, 252540, true)
        when "18"
          reward_items(pc, 15782, 1)
          give_adena(pc, 357780, true)
        when "19"
          reward_items(pc, 15783, 1)
          give_adena(pc, 357780, true)
        when "20"
          reward_items(pc, 15784, 1)
          give_adena(pc, 505100, true)
        when "21"
          reward_items(pc, 15785, 1)
          give_adena(pc, 505100, true)
        when "22"
          reward_items(pc, 15786, 1)
          give_adena(pc, 505100, true)
        when "23"
          reward_items(pc, 15787, 1)
          give_adena(pc, 505100, true)
        when "24"
          reward_items(pc, 15787, 1)
          give_adena(pc, 505100, true)
        when "25"
          reward_items(pc, 15789, 1)
          give_adena(pc, 505100, true)
        when "26"
          reward_items(pc, 15790, 1)
          give_adena(pc, 496680, true)
        when "27"
          reward_items(pc, 15791, 1)
          give_adena(pc, 496680, true)
        when "28"
          reward_items(pc, 15792, 1)
          give_adena(pc, 563860, true)
        when "29"
          reward_items(pc, 15793, 1)
          give_adena(pc, 509040, true)
        when "30"
          reward_items(pc, 15794, 1)
          give_adena(pc, 454240, true)
        end


        marks_of_darkness = get_quest_items_count(pc, MARK_OF_DARKNESS)
        if marks_of_darkness > 0
          add_exp_and_sp(pc, 55983 * marks_of_darkness, 136500 * marks_of_darkness.to_i)
        end
        qs.exit_quest(false, true)
        html = "32757-09.html"
      end
    end


    html
  end

  def on_kill(anays, killer, is_summon)
    if qs = get_random_party_member_state(killer, -1, 3, anays)
      if party = qs.player.party
        rnd = Rnd.rand(party.size)
        idx = 0

        party.members.each do |member|
          reward_player(get_quest_state(member, false), idx == rnd)
          idx += 1
        end
      else
        # if no party, the winner gets it all
        reward_player(qs, true)
      end
    end

    super
  end

  def check_party_member(qs, npc)
    qs.cond < 3
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      q10288 = pc.get_quest_state(Q10288_SecretMission.simple_name)
      if pc.level < 82 || (q10288.nil? || !q10288.completed?)
        html = "32757-00.htm"
      else
        html = "32757-01.htm"
      end
    elsif qs.started?
      case qs.cond
      when 1
        html = "32757-04.html"
      when 2, 3
        html = "32757-05.html"
      end

    else
      html = "32757-10.html"
    end

    html || get_no_quest_msg(pc)
  end

  private def reward_player(qs, lucky)
    if qs && qs.cond?(1)
      give_items(qs.player, lucky ? MARK_OF_SPLENDOR : MARK_OF_DARKNESS, 1)
      qs.set_cond(lucky ? 3 : 2, true)
    end
  end
end
