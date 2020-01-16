class Scripts::Q00501_ProofOfClanAlliance < Quest
  # NPCs
  private SIR_KRISTOF_RODEMAI = 30756
  private STATUE_OF_OFFERING = 30757
  private ATHREA = 30758
  private KALIS = 30759
  # Monsters
  private OEL_MAHUM_WITCH_DOCTOR = 20576
  private HARIT_LIZARDMAN_SHAMAN = 20644
  private VANOR_SILENOS_SHAMAN = 20685
  private BOX_OF_ATHREA_1 = 27173
  private BOX_OF_ATHREA_2 = 27174
  private BOX_OF_ATHREA_3 = 27175
  private BOX_OF_ATHREA_4 = 27176
  private BOX_OF_ATHREA_5 = 27177
  # Items
  private HERB_OF_HARIT = 3832
  private HERB_OF_VANOR = 3833
  private HERB_OF_OEL_MAHUM = 3834
  private BLOOD_OF_EVA = 3835
  private ATHREAS_COIN = 3836
  private SYMBOL_OF_LOYALTY = 3837
  private ANTIDOTE_RECIPE_LIST = 3872
  private VOUCHER_OF_FAITH = 3873
  private ALLIANCE_MANIFESTO = 3874
  private POTION_OF_RECOVERY = 3889
  # Skills
  private POISON_OF_DEATH = SkillHolder.new(4082)
  private DIE_YOU_FOOL = SkillHolder.new(4083)
  # Locations
  private LOCS = {
    Location.new(102273, 103433, -3512),
    Location.new(102190, 103379, -3524),
    Location.new(102107, 103325, -3533),
    Location.new(102024, 103271, -3500),
    Location.new(102327, 103350, -3511),
    Location.new(102244, 103296, -3518),
    Location.new(102161, 103242, -3529),
    Location.new(102078, 103188, -3500),
    Location.new(102381, 103267, -3538),
    Location.new(102298, 103213, -3532),
    Location.new(102215, 103159, -3520),
    Location.new(102132, 103105, -3513),
    Location.new(102435, 103184, -3515),
    Location.new(102352, 103130, -3522),
    Location.new(102269, 103076, -3533),
    Location.new(102186, 103022, -3541)
  }
  # Misc
  private CLAN_MIN_LEVEL = 3
  private CLAN_MEMBER_MIN_LEVEL = 40
  private ADENA_TO_RESTART_GAME = 10000

  def initialize
    super(501, self.class.simple_name, "Proof of Clan Alliance")

    add_start_npc(SIR_KRISTOF_RODEMAI, STATUE_OF_OFFERING)
    add_talk_id(SIR_KRISTOF_RODEMAI, STATUE_OF_OFFERING, ATHREA, KALIS)
    add_kill_id(
      OEL_MAHUM_WITCH_DOCTOR, HARIT_LIZARDMAN_SHAMAN, VANOR_SILENOS_SHAMAN,
      BOX_OF_ATHREA_1, BOX_OF_ATHREA_2, BOX_OF_ATHREA_3, BOX_OF_ATHREA_4,
      BOX_OF_ATHREA_5
    )
    register_quest_items(
      ANTIDOTE_RECIPE_LIST, VOUCHER_OF_FAITH, HERB_OF_HARIT, HERB_OF_VANOR,
      HERB_OF_OEL_MAHUM, BLOOD_OF_EVA, ATHREAS_COIN, SYMBOL_OF_LOYALTY
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30756-06.html", "30756-08.html", "30757-05.html", "30758-02.html",
         "30758-04.html", "30759-02.html", "30759-04.html"
      html = event
    when "30756-07.html"
      if qs.created? && pc.clan_leader? && pc.clan.not_nil!.level == CLAN_MIN_LEVEL
        qs.start_quest
        qs.memo_state = 1
        html = event
      end
    when "30757-04.html"
      if Rnd.rand(10) > 5
        if qs.get_int("flag") != 2501
          give_items(pc, SYMBOL_OF_LOYALTY, 1)
          qs.set("flag", 2501)
        end
        html = event
      else
        npc.target = pc
        npc.do_cast(DIE_YOU_FOOL)
        start_quest_timer("SYMBOL_OF_LOYALTY", 4000, npc, pc)
        html = "30757-03.html"
      end
    when "30758-03.html"
      if lqs = get_leader_quest_state(pc, name)
        if npc.summoned_npc_count < 4
          lqs.memo_state = 4
          lqs.set("flag", 0)
          npc.script_value = 0
          LOCS.each do |loc|
            box = add_spawn(npc, Rnd.rand(BOX_OF_ATHREA_1..BOX_OF_ATHREA_5), loc, false, 300000)
            box.disable_core_ai(true)
            box.no_rnd_walk = true
          end
          html = event
        else
          html = "30758-03a.html"
        end
      end
    when "30758-07.html"
      if pc.adena >= ADENA_TO_RESTART_GAME
        if npc.summoned_npc_count < 4
          take_items(pc, Inventory::ADENA_ID, ADENA_TO_RESTART_GAME)
        end
        html = event
      else
        html = "30758-06.html"
      end
    when "30759-03.html"
      if qs.memo_state?(1)
        qs.set_cond(2, true)
        qs.memo_state = 2
        html = event
      end
    when "30759-07.html"
      if qs.memo_state?(2) && get_quest_items_count(pc, SYMBOL_OF_LOYALTY) >= 3
        take_items(pc, SYMBOL_OF_LOYALTY, -1)
        give_items(pc, ANTIDOTE_RECIPE_LIST, 1)
        npc.target = pc
        npc.do_cast(POISON_OF_DEATH)
        qs.set_cond(3, true)
        qs.memo_state = 3
        html = event
      end
    when "SYMBOL_OF_LOYALTY"
      if pc.dead? && qs.get_int("flag") != 2501
        give_items(pc, SYMBOL_OF_LOYALTY, 1)
        qs.set("flag", 2501)
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    unless qs = get_random_party_member_state(killer, -1, 3, npc)
      return super
    end

    pc = qs.player

    if lqs = get_leader_quest_state(pc, name)
      case npc.id
      when OEL_MAHUM_WITCH_DOCTOR
        if Rnd.rand(10) == 1 && lqs.memo_state >= 3 && lqs.memo_state < 6
          give_item_randomly(pc, npc, HERB_OF_OEL_MAHUM, 1, 0, 1.0, true)
        end
      when HARIT_LIZARDMAN_SHAMAN
        if Rnd.rand(10) == 1 && lqs.memo_state >= 3 && lqs.memo_state < 6
          give_item_randomly(pc, npc, HERB_OF_HARIT, 1, 0, 1.0, true)
        end
      when VANOR_SILENOS_SHAMAN
        if Rnd.rand(10) == 1 && lqs.memo_state >= 3 && lqs.memo_state < 6
          give_item_randomly(pc, npc, HERB_OF_VANOR, 1, 0, 1.0, true)
        end
      when BOX_OF_ATHREA_1, BOX_OF_ATHREA_2, BOX_OF_ATHREA_3, BOX_OF_ATHREA_4,
           BOX_OF_ATHREA_5
        summoner = npc.summoner
        if summoner && summoner.npc? && lqs.memo_state?(4)
          arthea = summoner.as(L2Npc)
          if lqs.get_int("flag") == 3 && arthea.script_value?(15)
            lqs.set("flag", lqs.get_int("flag") + 1)
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::BINGO))
          elsif lqs.get_int("flag") == 2 && arthea.script_value?(14)
            lqs.set("flag", lqs.get_int("flag") + 1)
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::BINGO))
          elsif lqs.get_int("flag") == 1 && arthea.script_value?(13)
            lqs.set("flag", lqs.get_int("flag") + 1)
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::BINGO))
          elsif lqs.get_int("flag") == 0 && arthea.script_value?(12)
            lqs.set("flag", lqs.get_int("flag") + 1)
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::BINGO))
          elsif lqs.get_int("flag") < 4
            if Rnd.rand(4) == 0
              lqs.set("flag", lqs.get_int("flag") + 1)
              npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::BINGO))
            end
          end
          arthea.script_value = arthea.script_value + 1
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    lqs = get_leader_quest_state(pc, name)

    case npc.id
    when SIR_KRISTOF_RODEMAI
      case qs.state
      when State::CREATED
        if pc.clan_leader? && (clan = pc.clan)
          if clan.level < CLAN_MIN_LEVEL
            html = "30756-01.html"
          elsif clan.level == CLAN_MIN_LEVEL
            if has_quest_items?(pc, ALLIANCE_MANIFESTO)
              html = "30756-03.html"
            else
              html = "30756-04.html"
            end
          else
            html = "30756-02.html"
          end
        else
          html = "30756-05.html"
        end
      when State::STARTED
        if qs.memo_state?(6) && has_quest_items?(pc, VOUCHER_OF_FAITH)
          take_items(pc, VOUCHER_OF_FAITH, -1)
          give_items(pc, ALLIANCE_MANIFESTO, 1)
          add_exp_and_sp(pc, 0, 120000)
          qs.exit_quest(false)
          html = "30756-09.html"
        else
          html = "30756-10.html"
        end
      end
    when STATUE_OF_OFFERING
      if lqs && lqs.memo_state?(2)
        if !pc.clan_leader?
          if pc.level >= CLAN_MEMBER_MIN_LEVEL
            html = qs.get_int("flag") != 2501 ? "30757-01.html" : "30757-01b.html"
          else
            html = "30757-02.html"
          end
        else
          html = "30757-01a.html"
        end
      else
        html = "30757-06.html"
      end
    when ATHREA
      if lqs
        case lqs.memo_state
        when 3
          if has_quest_items?(lqs.player, ANTIDOTE_RECIPE_LIST)
            unless has_quest_items?(lqs.player, BLOOD_OF_EVA)
              lqs.set("flag", 0)
              html = "30758-01.html"
            end
          end
        when 4
          if lqs.get_int("flag") < 4
            html = "30758-05.html"
          else
            give_items(pc, BLOOD_OF_EVA, 1)
            lqs.memo_state = 5
            html = "30758-08.html"
          end
        when 5
          html = "30758-09.html"
        end
      end
    when KALIS
      if qs.memo_state?(1) && !has_quest_items?(pc, SYMBOL_OF_LOYALTY)
        html = "30759-01.html"
      elsif qs.memo_state?(2) && get_quest_items_count(pc, SYMBOL_OF_LOYALTY) < 3
        html = "30759-05.html"
      elsif get_quest_items_count(pc, SYMBOL_OF_LOYALTY) >= 3 && !has_abnormal?(pc)
        html = "30759-06.html"
      elsif qs.memo_state?(5) && has_quest_items?(pc, BLOOD_OF_EVA) && has_quest_items?(pc, HERB_OF_VANOR) && has_quest_items?(pc, HERB_OF_HARIT) && has_quest_items?(pc, HERB_OF_OEL_MAHUM) && has_abnormal?(pc)
        give_items(pc, VOUCHER_OF_FAITH, 1)
        give_items(pc, POTION_OF_RECOVERY, 1)
        take_items(pc, BLOOD_OF_EVA, -1)
        take_items(pc, ANTIDOTE_RECIPE_LIST, -1)
        take_items(pc, HERB_OF_OEL_MAHUM, -1)
        take_items(pc, HERB_OF_HARIT, -1)
        take_items(pc, HERB_OF_VANOR, -1)
        qs.set_cond(4, true)
        qs.memo_state = 6
        html = "30759-08.html"
      elsif (qs.memo_state?(3) || qs.memo_state?(4) || qs.memo_state?(5)) && !has_abnormal?(pc)
        take_items(pc, ANTIDOTE_RECIPE_LIST, -1)
        qs.memo_state = 1
        html = "30759-09.html"
      elsif qs.memo_state < 6 && get_quest_items_count(pc, SYMBOL_OF_LOYALTY) >= 3 && !has_at_least_one_quest_item?(pc, BLOOD_OF_EVA, HERB_OF_VANOR, HERB_OF_HARIT, HERB_OF_OEL_MAHUM) && has_abnormal?(pc)
        html = "30759-10.html"
      elsif qs.memo_state?(6)
        html = "30759-11.html"
      elsif lqs && !pc.clan_leader?
        html = "30759-12.html"
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def has_abnormal?(pc)
    !!pc.effect_list.get_buff_info_by_abnormal_type(AbnormalType::FATAL_POISON)
  end

  private def get_leader_quest_state(pc, quest)
    if clan = pc.clan
      if leader = clan.leader.player_instance
        leader.get_quest_state(quest)
      end
    end
  end

  def get_random_party_member_state(pc, condition, chance, target)
    if pc.nil? || chance < 1
      return
    end

    qs = get_quest_state(pc, false)
    unless party = pc.party
      unless Util.in_range?(1500, pc, target, true)
        return
      end
      return qs
    end

    candidates = [] of QuestState
    if qs && chance > 0
      chance.times do |i|
        candidates << qs
      end
    end

    party.members.each do |m|
      if m == pc
        next
      end

      qs = get_quest_state(m, false)
      if qs
        candidates << qs
      end
    end

    unless qs = candidates.sample?(random: Rnd)
      return
    end

    unless Util.in_range?(1500, qs.player, target, true)
      return
    end

    qs
  end
end
