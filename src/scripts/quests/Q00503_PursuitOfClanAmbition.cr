class Scripts::Q00503_PursuitOfClanAmbition < Quest
  # NPCs
  private HEAD_BLACKSMITH_KUSTO = 30512
  private MARTIEN = 30645
  private WITCH_ATHREA = 30758
  private WITCH_KALIS = 30759
  private SIR_GUSTAV_ATHEBALDT = 30760
  private CORPSE_OF_FRITZ = 30761
  private CORPSE_OF_LUTZ = 30762
  private CORPSE_OF_KURTZ = 30763
  private BALTHAZAR = 30764
  private IMPERIAL_COFFER = 30765
  private WITCH_CLEO = 30766
  private SIR_ERIC_RODEMAI = 30868
  # Items
  private MIST_DRAKES_EGG = 3839
  private BLITZ_WYRM_EGG = 3840
  private DRAKES_EGG = 3841
  private THUNDER_WYRM_EGG = 3842
  private BROOCH_OF_THE_MAGPIE = 3843
  private IMPERIAL_KEY = 3847
  private GUSTAVS_1ST_LETTER = 3866
  private GUSTAVS_2ND_LETTER = 3867
  private GUSTAVS_3RD_LETTER = 3868
  private SCEPTER_OF_JUDGMENT = 3869
  private BLACK_ANVIL_COIN = 3871
  private RECIPE_SPITEFUL_SOUL_ENERGY = 14854
  private SPITEFUL_SOUL_ENERGY = 14855
  private SPITEFUL_SOUL_VENGEANCE = 14856
  # Reward
  private SEAL_OF_ASPIRATION = 3870
  # Monsters
  private DRAKE = 20137
  private DRAKE2 = 20285
  private THUNDER_WYRM = 20243
  private THUNDER_WYRM2 = 20282
  private GRAVE_GUARD = 20668
  private SPITEFUL_SOUL_LEADER = 20974
  # Quest Monster
  private GRAVE_KEYMASTER = 27179
  private IMPERIAL_GRAVEKEEPER = 27181
  private BLITZ_WYRM = 27178

  def initialize
    super(503, self.class.simple_name, "Pursuit Of Clan Ambition")

    add_start_npc(SIR_GUSTAV_ATHEBALDT)
    add_talk_id(
      SIR_GUSTAV_ATHEBALDT, HEAD_BLACKSMITH_KUSTO, MARTIEN, WITCH_ATHREA,
      WITCH_KALIS, CORPSE_OF_FRITZ, CORPSE_OF_LUTZ, CORPSE_OF_KURTZ, BALTHAZAR,
      IMPERIAL_COFFER, WITCH_CLEO, SIR_ERIC_RODEMAI
    )
    add_kill_id(
      DRAKE, DRAKE2, THUNDER_WYRM, THUNDER_WYRM2, GRAVE_GUARD,
      SPITEFUL_SOUL_LEADER, GRAVE_KEYMASTER, BLITZ_WYRM, IMPERIAL_GRAVEKEEPER
    )
    add_spawn_id(WITCH_ATHREA, WITCH_KALIS, IMPERIAL_COFFER, BLITZ_WYRM)
    register_quest_items(
      MIST_DRAKES_EGG, BLITZ_WYRM_EGG, DRAKES_EGG, THUNDER_WYRM_EGG,
      BROOCH_OF_THE_MAGPIE, IMPERIAL_KEY, GUSTAVS_1ST_LETTER,
      GUSTAVS_2ND_LETTER, GUSTAVS_3RD_LETTER, SCEPTER_OF_JUDGMENT,
      BLACK_ANVIL_COIN, RECIPE_SPITEFUL_SOUL_ENERGY, SPITEFUL_SOUL_ENERGY,
      SPITEFUL_SOUL_VENGEANCE
    )
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    if event.starts_with?("DESPAWN")
      npc.delete_me
      return super
    end

    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30760-08.html"
      if qs.created?
        give_items(pc, GUSTAVS_1ST_LETTER, 1)
        qs.start_quest
        qs.memo_state = 1000
        html = event
      end
    when "30760-12.html"
      give_items(pc, GUSTAVS_2ND_LETTER, 1)
      qs.memo_state = 4000
      qs.set_cond(4)
      html = event
    when "30760-16.html"
      give_items(pc, GUSTAVS_3RD_LETTER, 1)
      qs.memo_state = 7000
      qs.set_cond(7)
      html = event
    when "30760-20.html"
      if has_quest_items?(pc, SCEPTER_OF_JUDGMENT)
        give_items(pc, SEAL_OF_ASPIRATION, 1)
        add_exp_and_sp(pc, 0, 250000)
        qs.exit_quest(false, true)
        html = event
      end
    when "30760-22.html"
      qs.memo_state = 10000
      qs.set_cond(12)
      html = event
    when "30760-23.html"
      if has_quest_items?(pc, SCEPTER_OF_JUDGMENT)
        give_items(pc, SEAL_OF_ASPIRATION, 1)
        add_exp_and_sp(pc, 0, 250000)
        qs.exit_quest(false, true)
        html = event
      end
    when "30512-03.html"
      if has_quest_items?(pc, BROOCH_OF_THE_MAGPIE)
        take_items(pc, BROOCH_OF_THE_MAGPIE, -1)
        give_items(pc, BLACK_ANVIL_COIN, 1)
      end
      html = event
    when "30645-03.html"
      take_items(pc, GUSTAVS_1ST_LETTER, -1)
      qs.memo_state = 2000
      qs.set_cond(2, true)
      html = event
    when "30761-02.html"
      if qs.memo_state?(2000) || qs.memo_state?(2011) || qs.memo_state?(2010) || qs.memo_state?(2001)
        give_items(pc, BLITZ_WYRM_EGG, 3)
        qs.memo_state = qs.memo_state + 100
        add_attack_desire(add_spawn(BLITZ_WYRM, npc, true, 0, false), pc)
        add_attack_desire(add_spawn(BLITZ_WYRM, npc, true, 0, false), pc)
        start_quest_timer("DESPAWN", 10000, npc, pc)
        html = event
      elsif qs.memo_state?(2100) || qs.memo_state?(2111) || qs.memo_state?(2110) || qs.memo_state?(2101)
        add_attack_desire(add_spawn(BLITZ_WYRM, npc, true, 0, false), pc)
        add_attack_desire(add_spawn(BLITZ_WYRM, npc, true, 0, false), pc)
        start_quest_timer("DESPAWN", 10000, npc, pc)
        html = "30761-03.html"
      end
    when "30762-02.html"
      if qs.memo_state?(2000) || qs.memo_state?(2101) || qs.memo_state?(2001) || qs.memo_state?(2100)
        give_items(pc, BLITZ_WYRM_EGG, 3)
        give_items(pc, MIST_DRAKES_EGG, 4)
        qs.memo_state = qs.memo_state + 10
        add_attack_desire(add_spawn(BLITZ_WYRM, npc, true, 0, false), pc)
        add_attack_desire(add_spawn(BLITZ_WYRM, npc, true, 0, false), pc)
        start_quest_timer("DESPAWN", 10000, npc, pc)
        html = event
      elsif qs.memo_state?(2100) || qs.memo_state?(2111) || qs.memo_state?(2011) || qs.memo_state?(2110)
        add_attack_desire(add_spawn(BLITZ_WYRM, npc, true, 0, false), pc)
        add_attack_desire(add_spawn(BLITZ_WYRM, npc, true, 0, false), pc)
        start_quest_timer("DESPAWN", 10000, npc, pc)
        html = "30762-03.html"
      end
    when "30763-02.html"
      if qs.memo_state?(2000) || qs.memo_state?(2110) || qs.memo_state?(2010) || qs.memo_state?(2100)
        give_items(pc, BROOCH_OF_THE_MAGPIE, 1)
        give_items(pc, MIST_DRAKES_EGG, 6)
        qs.memo_state = qs.memo_state + 1
        npc.delete_me
        html = event
      end
    when "30764-03.html"
      take_items(pc, GUSTAVS_2ND_LETTER, -1)
      qs.memo_state = 5000
      qs.set_cond(5, true)
      html = event
    when "30764-06.html"
      take_items(pc, GUSTAVS_2ND_LETTER, -1)
      take_items(pc, BLACK_ANVIL_COIN, -1)
      give_items(pc, RECIPE_SPITEFUL_SOUL_ENERGY, 1)
      qs.memo_state = 5000
      qs.set_cond(5, true)
      html = event
    when "30765-04.html"
      take_items(pc, IMPERIAL_KEY, -1)
      give_items(pc, SCEPTER_OF_JUDGMENT, 1)
      qs.memo_state = 8700
      html = event
    when "30766-04.html"
      qs.memo_state = 8100
      qs.set_cond(9, true)
      npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::BLOOD_AND_HONOR))
      start_quest_timer("SPAWN_WITCH", 5000, npc, pc)
      html = event
    when "30766-08.html"
      if has_quest_items?(pc, SCEPTER_OF_JUDGMENT)
        give_items(pc, SEAL_OF_ASPIRATION, 1)
        add_exp_and_sp(pc, 0, 250000)
        qs.exit_quest(false, true)
        html = event
      end
    when "30868-04.html"
      take_items(pc, GUSTAVS_3RD_LETTER, -1)
      qs.memo_state = 8000
      qs.set_cond(8, true)
      html = event
    when "30868-10.html"
      qs.memo_state = 9000
      qs.set_cond(11, true)
      html = event
    when "30645-06.html", "30760-05.html", "30760-06.html", "30760-07.html",
         "30760-21.html", "30764-05.html", "30765-02.html", "30765-05a.html",
         "30766-03.html", "30868-03.html", "30868-06a.html"
      html = event
    when "SPAWN_WITCH"
       athrea = add_spawn(WITCH_ATHREA, 160688, 21296, -3714, 0, false, 0)
      athrea.script_value = 50301
       kalis = add_spawn(WITCH_KALIS, 160690, 21176, -3712, 0, false, 0)
      kalis.script_value = 50302
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs.nil? || !qs.started? || !Util.in_range?(1500, npc, killer, true)
      return super
    end

    unless clan = killer.clan
      return super
    end

    unless leader = clan.leader.player_instance
      return super
    end

    unless Util.in_range?(1500, npc, leader, true)
      return super
    end

    unless leader_qs = get_quest_state(leader, false)
      return super
    end

    case npc.id
    when DRAKE, DRAKE2
      if leader_qs.memo_state >= 2000 || leader_qs.memo_state < 3000
        give_item_randomly(leader, MIST_DRAKES_EGG, 1, 10, 0.1, true)

        give_item_randomly(leader, DRAKES_EGG, 1, 10, 0.5, true)
      end
    when THUNDER_WYRM, THUNDER_WYRM2
      if leader_qs.memo_state >= 2000 || leader_qs.memo_state < 3000
        give_item_randomly(leader, THUNDER_WYRM_EGG, 1, 10, 0.5, true)
      end
    when GRAVE_GUARD
      if leader_qs.memo_state < 8511 || leader_qs.memo_state >= 8500
        leader_qs.memo_state = leader_qs.memo_state + 1

        if leader_qs.memo_state >= 8505 && Rnd.rand(100) < 50
          leader_qs.memo_state = 8500
          add_spawn(GRAVE_KEYMASTER, npc, true, 0, false)
        elsif leader_qs.memo_state >= 8510
          leader_qs.memo_state = 8500
          add_spawn(GRAVE_KEYMASTER, npc, true, 0, false)
        end
      end
    when SPITEFUL_SOUL_LEADER
      if leader_qs.memo_state == 5000
        rnd = Rnd.rand(100)
        if rnd < 10
          give_item_randomly(leader, SPITEFUL_SOUL_ENERGY, 1, 10, 1, false)
        elsif rnd < 60
          give_items(leader, SPITEFUL_SOUL_VENGEANCE, 1)
        end
      end
    when BLITZ_WYRM
      if leader_qs.memo_state >= 2000 || leader_qs.memo_state < 3000
        give_item_randomly(leader, BLITZ_WYRM_EGG, 1, 10, 1, true)
      end
    when GRAVE_KEYMASTER
      if leader_qs.memo_state >= 8500
        give_item_randomly(leader, IMPERIAL_KEY, 1, 6, 1, true)
      end
    when IMPERIAL_GRAVEKEEPER
      if leader_qs.memo_state < 8511 || leader_qs.memo_state >= 8500
        add_spawn(IMPERIAL_COFFER, npc, true, 0, false)
      end
    else
      # automatically added
    end


    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    lqs = get_leader_quest_state(pc, name)

    if qs.created? || qs.completed?
      if npc.id == SIR_GUSTAV_ATHEBALDT
        if lqs
          if pc.clan_leader?
            if clan = pc.clan
              if clan.level < 4
                html = "30760-01.html"
              elsif clan.level >= 5
                html = "30760-02.html"
              elsif clan.level == 4 && has_quest_items?(pc, SEAL_OF_ASPIRATION)
                html = "30760-03.html"
              elsif clan.level == 4 && !has_quest_items?(pc, SEAL_OF_ASPIRATION)
                html = "30760-04.html"
              end
            end
          else
            html = "30760-04t.html"
          end
        end
      end
    elsif qs.started?
      case npc.id
      when SIR_GUSTAV_ATHEBALDT
        if lqs
          if qs.memo_state == 1000
            html = "30760-09.html"
          elsif qs.memo_state == 2000
            html = "30760-10.html"
          elsif qs.memo_state == 3000
            if !pc.clan_leader?
              html = "30760-11t.html"
            else
              html = "30760-11.html"
            end
          elsif qs.memo_state == 4000
            html = "30760-13.html"
          elsif qs.memo_state == 5000
            html = "30760-14.html"
          elsif qs.memo_state == 6000
            if !pc.clan_leader?
              html = "30760-15t.html"
            else
              html = "30760-15.html"
            end
          elsif qs.memo_state == 7000
            html = "30760-17.html"
          elsif qs.memo_state >= 8000 && qs.memo_state < 8700
            html = "30760-18.html"
          elsif qs.memo_state >= 8700 && qs.memo_state < 10000 && pc.clan_leader?
            html = "30760-19.html"
          elsif qs.memo_state == 9000 && !pc.clan_leader?
            html = "30760-19t.html"
          elsif qs.memo_state == 10000
            if !pc.clan_leader?
              html = "30760-24t.html"
            else
              html = "30760-24.html"
            end
          end
        end
      when HEAD_BLACKSMITH_KUSTO
        if lqs && !pc.clan_leader?
          html = "30512-01a.html"
        elsif !has_at_least_one_quest_item?(pc, BROOCH_OF_THE_MAGPIE, BLACK_ANVIL_COIN)
          html = "30512-01.html"
        elsif has_quest_items?(pc, BROOCH_OF_THE_MAGPIE)
          html = "30512-02.html"
        elsif lqs && has_quest_items?(pc, BLACK_ANVIL_COIN) && !has_quest_items?(pc, BROOCH_OF_THE_MAGPIE)
          html = "30512-04.html"
        end
      when MARTIEN
        if lqs
          if qs.memo_state == 1000
            if !pc.clan_leader?
              html = "30645-01.html"
            else
              html = "30645-02.html"
            end
          elsif qs.memo_state < 3000 && qs.memo_state >= 2000
            if get_quest_items_count(pc, MIST_DRAKES_EGG) < 10 || get_quest_items_count(pc, BLITZ_WYRM_EGG) < 10 || get_quest_items_count(pc, THUNDER_WYRM_EGG) < 10 || get_quest_items_count(pc, DRAKES_EGG) < 10
              html = "30645-04.html"
            else
              take_items(pc, MIST_DRAKES_EGG, -1)
              take_items(pc, BLITZ_WYRM_EGG, -1)
              take_items(pc, DRAKES_EGG, -1)
              take_items(pc, THUNDER_WYRM_EGG, -1)
              qs.memo_state = 3000
              qs.set_cond(3, true)
              html = "30645-05.html"
            end
          elsif qs.memo_state == 3000
            html = "30645-07.html"
          elsif qs.memo_state > 3000
            html = "30645-08.html"
          end
        end
      when WITCH_ATHREA
        if lqs
          html = "30758-01.html"
        end
      when WITCH_KALIS
        if lqs
          html = "30759-01.html"
        end
      when CORPSE_OF_FRITZ
        if qs.memo_state < 3000 && qs.memo_state >= 2000
          html = "30761-01.html"
        end
      when CORPSE_OF_LUTZ
        if qs.memo_state < 3000 && qs.memo_state >= 2000
          html = "30762-01.html"
        end
      when CORPSE_OF_KURTZ
        if qs.memo_state < 3000 && qs.memo_state == 2000 || qs.memo_state == 2110 || qs.memo_state == 2010 || qs.memo_state == 2100
          html = "30763-01.html"
        elsif qs.memo_state == 2001 || qs.memo_state == 2111 || qs.memo_state == 2011 || qs.memo_state == 2101
          html = "30763-03.html"
        end
      when BALTHAZAR
        if lqs
          if qs.memo_state == 4000
            if !pc.clan_leader?
              html = "30764-01.html"
            elsif !has_quest_items?(pc, BLACK_ANVIL_COIN) && pc.clan_leader?
              html = "30764-02.html"
            elsif has_quest_items?(pc, BLACK_ANVIL_COIN)
              html = "30764-04.html"
            end
          elsif qs.memo_state == 5000
            if get_quest_items_count(pc, SPITEFUL_SOUL_ENERGY) < 10
              html = "30764-07a.html"
            else
              take_items(pc, SPITEFUL_SOUL_ENERGY, -1)
              qs.memo_state = 6000
              qs.set_cond(6, true)
              html = "30764-08a.html"
            end
          elsif qs.memo_state >= 6000
            html = "30764-09.html"
          end
        end
      when IMPERIAL_COFFER
        if lqs
          if qs.memo_state >= 8500 && qs.memo_state < 8700
            if get_quest_items_count(pc, IMPERIAL_KEY) >= 6
              if !pc.clan_leader?
                html = "30765-01.html"
              else
                html = "30765-03.html"
              end
            end
          elsif qs.memo_state >= 8700
            html = "30765-05.html"
          end
        end
      when WITCH_CLEO
        if lqs
          if !pc.clan_leader?
            html = "30766-01.html"
          elsif qs.memo_state == 8000
            html = "30766-02.html"
          elsif qs.memo_state == 8100
            html = "30766-05.html"
          elsif qs.memo_state > 8100 && qs.memo_state < 10000
            html = "30766-06.html"
          elsif qs.memo_state == 10000 && pc.clan_leader?
            html = "30766-07.html"
          end
        end
      when SIR_ERIC_RODEMAI
        if lqs
          if qs.memo_state == 7000
            if !pc.clan_leader?
              html = "30868-01.html"
            else
              html = "30868-02.html"
            end
          elsif qs.memo_state == 8000
            html = "30868-05.html"
          elsif qs.memo_state == 8100
            if pc.clan_leader?
              qs.memo_state = 8500
              qs.set_cond(10, true)
              html = "30868-06.html"
            else
              html = "30868-07.html"
            end
          elsif qs.memo_state < 8511 && qs.memo_state >= 8500
            html = "30868-08.html"
          elsif qs.memo_state == 8700
            html = "30868-09.html"
          elsif qs.memo_state >= 9000
            html = "30868-11.html"
          end
        end
      else
        # automatically added
      end

    end

    html || get_no_quest_msg(pc)
  end

  def on_spawn(npc)
    case npc.id
    when WITCH_ATHREA
      if npc.script_value?(50301)
        start_quest_timer("DESPAWN_WITCH_ATHREA", 5000, npc, nil)
        npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::WAR_AND_DEATH))
      end
    when WITCH_KALIS
      if npc.script_value?(50302)
        start_quest_timer("DESPAWN_WITCH_KALIS", 5000, npc, nil)
        npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::AMBITION_AND_POWER))
      end
    when IMPERIAL_COFFER
      start_quest_timer("DESPAWN_IMPERIAL_COFFER", 180000, npc, nil)
      npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::CURSE_OF_THE_GODS_ON_THE_ONE_THAT_DEFILES_THE_PROPERTY_OF_THE_EMPIRE))
    when BLITZ_WYRM
      start_quest_timer("DESPAWN_BLITZ_WYRM", 180000, npc, nil)
    else
      # automatically added
    end


    super
  end

  private def get_leader_quest_state(pc, quest)
    if clan = pc.clan
      if leader = clan.leader.player_instance
        leader.get_quest_state(quest)
      end
    end
  end
end