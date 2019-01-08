class Quests::Q00416_PathOfTheOrcShaman < Quest
  # NPCs
  private UMOS = 30502
  private TATARU_ZU_HESTUI = 30585
  private HESTUI_TOTEM_SPIRIT = 30592
  private DUDA_MARA_TOTEM_SPIRIT = 30593
  private MOIRA = 31979
  private TOTEM_SPIRIT_OF_GANDI = 32057
  private DEAD_LEOPARDS_CARCASS = 32090
  # Items
  private FIRE_CHARM = 1616
  private KASHA_BEAR_PELT = 1617
  private KASHA_BLADE_SPIDER_HUSK = 1618
  private FIRST_FIERY_EGG = 1619
  private HESTUI_MASK = 1620
  private SECOND_FIERY_EGG = 1621
  private TOTEM_SPIRIT_CLAW = 1622
  private TATARUS_LETTER = 1623
  private FLAME_CHARM = 1624
  private GRIZZLY_BLOOD = 1625
  private BLOOD_CAULDRON = 1626
  private SPIRIT_NET = 1627
  private BOUND_DURKA_SPIRIT = 1628
  private DURKA_PARASITE = 1629
  private TOTEM_SPIRIT_BLOOD = 1630
  private MASK_OF_MEDIUM = 1631
  # Quest Monsters
  private DURKA_SPIRIT = 27056
  private BLACK_LEOPARD = 27319
  # Misc
  private MIN_LEVEL = 18
  # Mobs
  private MOBS = {
    20415 => ItemChanceHolder.new(FIRST_FIERY_EGG, 1.0, 1), # scarlet_salamander
    20478 => ItemChanceHolder.new(KASHA_BLADE_SPIDER_HUSK, 1.0, 1), # kasha_blade_spider
    20479 => ItemChanceHolder.new(KASHA_BEAR_PELT, 1.0, 1), # kasha_bear
    20335 => ItemChanceHolder.new(GRIZZLY_BLOOD, 1.0, 6), # grizzly_bear
    20038 => ItemChanceHolder.new(DURKA_PARASITE, 1.0, 9), # poison_spider
    20043 => ItemChanceHolder.new(DURKA_PARASITE, 1.0, 9), # bind_poison_spider
    27056 => ItemChanceHolder.new(DURKA_PARASITE, 1.0, 9) # durka_spirit
  }

  def initialize
    super(416, self.class.simple_name, "Path of the Orc Shaman")

    add_start_npc(TATARU_ZU_HESTUI)
    add_talk_id(
      TATARU_ZU_HESTUI, UMOS, MOIRA, DEAD_LEOPARDS_CARCASS,
      DUDA_MARA_TOTEM_SPIRIT, HESTUI_TOTEM_SPIRIT, TOTEM_SPIRIT_OF_GANDI
    )
    add_kill_id(MOBS.keys)
    add_kill_id(BLACK_LEOPARD)
    register_quest_items(
      FIRE_CHARM, KASHA_BEAR_PELT, KASHA_BLADE_SPIDER_HUSK, FIRST_FIERY_EGG,
      HESTUI_MASK, SECOND_FIERY_EGG, TOTEM_SPIRIT_CLAW, TATARUS_LETTER,
      FLAME_CHARM, GRIZZLY_BLOOD, BLOOD_CAULDRON, SPIRIT_NET,
      BOUND_DURKA_SPIRIT, DURKA_PARASITE, TOTEM_SPIRIT_BLOOD
    )
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless st = get_quest_state(player, false)

    case event
    when "START"
      if !player.class_id.orc_mage?
        if player.class_id.orc_shaman?
          htmltext = "30585-02.htm"
        else
          htmltext = "30585-03.htm"
        end
      elsif player.level < MIN_LEVEL
        htmltext = "30585-04.htm"
      elsif has_quest_items?(player, MASK_OF_MEDIUM)
        htmltext = "30585-05.htm"
      else
        htmltext = "30585-06.htm"
      end
    when "30585-07.htm"
      st.start_quest
      st.memo_state = 1
      give_items(player, FIRE_CHARM, 1)
      htmltext = event
    when "30585-12.html"
      if has_quest_items?(player, TOTEM_SPIRIT_CLAW)
        htmltext = event
      end
    when "30585-13.html"
      if has_quest_items?(player, TOTEM_SPIRIT_CLAW)
        take_items(player, TOTEM_SPIRIT_CLAW, -1)
        give_items(player, TATARUS_LETTER, 1)
        st.set_cond(5, true)
        htmltext = event
      end
    when "30585-14.html"
      if has_quest_items?(player, TOTEM_SPIRIT_CLAW)
        take_items(player, TOTEM_SPIRIT_CLAW, -1)
        st.set_cond(12, true)
        st.memo_state=(100)
        htmltext = event
      end
    when "30502-07.html"
      if has_quest_items?(player, TOTEM_SPIRIT_BLOOD)
        take_items(player, TOTEM_SPIRIT_BLOOD, -1)
        give_items(player, MASK_OF_MEDIUM, 1)
        level = player.level
        if level >= 20
          add_exp_and_sp(player, 320534, 22992)
        elsif level >= 19
          add_exp_and_sp(player, 456128, 29690)
        else
          add_exp_and_sp(player, 591724, 36388)
        end
        give_adena(player, 163800, true)
        st.exit_quest(false, true)
        player.send_packet(SocialAction.new(player.l2id, 3))
        st.save_global_quest_var("1ClassQuestFinished", "1")
        htmltext = event
      end
    when "32090-05.html"
      if st.memo_state?(106)
        htmltext = event
      end
    when "32090-06.html"
      if st.memo_state?(106)
        st.memo_state=(107)
        st.set_cond(18, true)
        htmltext = event
      end
    when "30593-02.html"
      if has_quest_items?(player, BLOOD_CAULDRON)
        htmltext = event
      end
    when "30593-03.html"
      if has_quest_items?(player, BLOOD_CAULDRON)
        take_items(player, BLOOD_CAULDRON, -1)
        give_items(player, SPIRIT_NET, 1)
        st.set_cond(9, true)
        htmltext = event
      end
    when "30592-02.html"
      if has_quest_items?(player, HESTUI_MASK, SECOND_FIERY_EGG)
        htmltext = event
      end
    when "30592-03.html"
      if has_quest_items?(player, HESTUI_MASK, SECOND_FIERY_EGG)
        take_items(player, -1, {HESTUI_MASK, SECOND_FIERY_EGG})
        give_items(player, TOTEM_SPIRIT_CLAW, 1)
        st.set_cond(4, true)
        htmltext = event
      end
    when "32057-02.html"
      if st.memo_state?(101)
        st.memo_state=(102)
        st.set_cond(14, true)
        htmltext = event
      end
    when "32057-05.html"
      if st.memo_state?(109)
        st.memo_state=(110)
        st.set_cond(21, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, player, is_summon)
    unless st = get_random_party_member_state(player, -1, 3, npc)
      return super
    end

    if npc.id == BLACK_LEOPARD
      case st.memo_state
      when 102
        st.memo_state=(103)
      when 103
        st.memo_state=(104)
        st.set_cond(15, true)
        if Rnd.rand(100) < 66
          npc.broadcast_packet(NpcSay.new(npc.l2id, Packets::Incoming::Say2::NPC_ALL, npc.id, NpcString::MY_DEAR_FRIEND_OF_S1_WHO_HAS_GONE_ON_AHEAD_OF_ME).add_string_parameter(st.player.name))
        end
      when 105
        st.memo_state=(106)
        st.set_cond(17, true)
        if Rnd.rand(100) < 66
          npc.broadcast_packet(NpcSay.new(npc.l2id, Packets::Incoming::Say2::NPC_ALL, npc.id, NpcString::LISTEN_TO_TEJAKAR_GANDI_YOUNG_OROKA_THE_SPIRIT_OF_THE_SLAIN_LEOPARD_IS_CALLING_YOU_S1).add_string_parameter(st.player.name))
        end
      when 107
        st.memo_state=(108)
        st.set_cond(19, true)
      end

      return super
    end

    item = MOBS[npc.id]
    if item.count == st.cond
      if st.cond?(1) && has_quest_items?(st.player, FIRE_CHARM)
        if give_item_randomly(st.player, npc, item.id, 1, 1, item.chance, true) && has_quest_items?(st.player, FIRST_FIERY_EGG, KASHA_BLADE_SPIDER_HUSK, KASHA_BEAR_PELT)
          st.set_cond(2, true)
        end
      elsif st.cond?(6) && has_quest_items?(st.player, FLAME_CHARM)
        if give_item_randomly(st.player, npc, item.id, 1, 3, item.chance, true)
          st.set_cond(7)
        end
      elsif st.cond?(9) && has_quest_items?(st.player, SPIRIT_NET) &&
        !has_quest_items?(st.player, BOUND_DURKA_SPIRIT) &&
        get_quest_items_count(st.player, DURKA_PARASITE) <= 8

        if npc.id == 20038 || npc.id == 20043
          random = Rnd.rand(10)
          item_count = get_quest_items_count(st.player, DURKA_PARASITE)
          if (item_count == 5 && random < 1) ||
            (item_count == 6 && random < 2) ||
            (item_count == 7 && random < 2) || item_count >= 8
            take_items(player, DURKA_PARASITE, -1)
            add_spawn(DURKA_SPIRIT, *npc.xyz, 0, true, 0i64, false)
            play_sound(st.player, Sound::ITEMSOUND_QUEST_BEFORE_BATTLE)
          else
            give_items(st.player, DURKA_PARASITE, 1)
            play_sound(st.player, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        else
          give_items(st.player, BOUND_DURKA_SPIRIT, 1)
          take_items(st.player, -1, {DURKA_PARASITE, SPIRIT_NET})
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if st.created?
      if npc.id == TATARU_ZU_HESTUI
        htmltext = "30585-01.htm"
      end
    elsif st.started?
      case npc.id
      when TATARU_ZU_HESTUI
        if st.memo_state?(1)
          if has_quest_items?(player, FIRE_CHARM)
            if get_quest_items_count(player, KASHA_BEAR_PELT, KASHA_BLADE_SPIDER_HUSK, FIRST_FIERY_EGG) < 3
              htmltext = "30585-08.html"
            else
              take_items(player, -1, [FIRE_CHARM, KASHA_BEAR_PELT, KASHA_BLADE_SPIDER_HUSK, FIRST_FIERY_EGG])
              give_items(player, HESTUI_MASK, 1)
              give_items(player, SECOND_FIERY_EGG, 1)
              st.set_cond(3, true)
              htmltext = "30585-09.html"
            end
          elsif has_quest_items?(player, HESTUI_MASK, SECOND_FIERY_EGG)
            htmltext = "30585-10.html"
          elsif has_quest_items?(player, TOTEM_SPIRIT_CLAW)
            htmltext = "30585-11.html"
          elsif has_quest_items?(player, TATARUS_LETTER)
            htmltext = "30585-15.html"
          elsif has_at_least_one_quest_item?(player, GRIZZLY_BLOOD, FLAME_CHARM, BLOOD_CAULDRON, SPIRIT_NET, BOUND_DURKA_SPIRIT, TOTEM_SPIRIT_BLOOD)
            htmltext = "30585-16.html"
          end
        elsif st.memo_state?(100)
          htmltext = "30585-14.html"
        end
      when UMOS
        if st.memo_state?(1)
          if has_quest_items?(player, TATARUS_LETTER)
            give_items(player, FLAME_CHARM, 1)
            take_items(player, TATARUS_LETTER, -1)
            st.set_cond(6, true)
            htmltext = "30502-01.html"
          elsif has_quest_items?(player, FLAME_CHARM)
            if get_quest_items_count(player, GRIZZLY_BLOOD) < 3
              htmltext = "30502-02.html"
            else
              take_items(player, -1, {FLAME_CHARM, GRIZZLY_BLOOD})
              give_items(player, BLOOD_CAULDRON, 1)
              st.set_cond(8, true)
              htmltext = "30502-03.html"
            end
          elsif has_quest_items?(player, BLOOD_CAULDRON)
            htmltext = "30502-04.html"
          elsif has_at_least_one_quest_item?(player, BOUND_DURKA_SPIRIT, SPIRIT_NET)
            htmltext = "30502-05.html"
          elsif has_quest_items?(player, TOTEM_SPIRIT_BLOOD)
            htmltext = "30502-06.html"
          end
        end
      when MOIRA
        memo_state = st.memo_state
        if memo_state == 100
          st.memo_state=(101)
          st.set_cond(13, true)
          htmltext = "31979-01.html"
        elsif memo_state >= 101 && memo_state < 108
          htmltext = "31979-02.html"
        elsif memo_state == 110
          give_items(player, MASK_OF_MEDIUM, 1)
          level = player.level
          if level >= 20
            add_exp_and_sp(player, 160267, 11496)
          elsif level >= 19
            add_exp_and_sp(player, 228064, 14845)
          else
            add_exp_and_sp(player, 295862, 18194)
          end
          give_adena(player, 81900, true)
          st.exit_quest(false, true)
          player.send_packet(SocialAction.new(player.l2id, 3))
          st.save_global_quest_var("1ClassQuestFinished", "1")
          htmltext = "31979-03.html"
        end
      when DEAD_LEOPARDS_CARCASS
        case st.memo_state
        when 102, 103
          htmltext = "32090-01.html"
        when 104
          st.memo_state=(105)
          st.set_cond(16, true)
          htmltext = "32090-03.html"
        when 105
          htmltext = "32090-01.html"
        when 106
          htmltext = "32090-04.html"
        when 107
          htmltext = "32090-07.html"
        when 108
          st.memo_state=(109)
          st.set_cond(20, true)
          htmltext = "32090-08.html"
        end
      when DUDA_MARA_TOTEM_SPIRIT
        if st.memo_state?(1)
          if has_quest_items?(player, BLOOD_CAULDRON)
            htmltext = "30593-01.html"
          elsif has_quest_items?(player, SPIRIT_NET) && !has_quest_items?(player, BOUND_DURKA_SPIRIT)
            htmltext = "30593-04.html"
          elsif !has_quest_items?(player, SPIRIT_NET) && has_quest_items?(player, BOUND_DURKA_SPIRIT)
            take_items(player, BOUND_DURKA_SPIRIT, -1)
            give_items(player, TOTEM_SPIRIT_BLOOD, 1)
            st.set_cond(11, true)
            htmltext = "30593-05.html"
          elsif has_quest_items?(player, TOTEM_SPIRIT_BLOOD)
            htmltext = "30593-06.html"
          end
        end
      when HESTUI_TOTEM_SPIRIT
        if st.memo_state?(1)
          if has_quest_items?(player, HESTUI_MASK, SECOND_FIERY_EGG)
            htmltext = "30592-01.html"
          elsif has_quest_items?(player, TOTEM_SPIRIT_CLAW)
            htmltext = "30592-04.html"
          elsif has_at_least_one_quest_item?(player, GRIZZLY_BLOOD, FLAME_CHARM, BLOOD_CAULDRON, SPIRIT_NET, BOUND_DURKA_SPIRIT, TOTEM_SPIRIT_BLOOD, TATARUS_LETTER)
            htmltext = "30592-05.html"
          end
        end
      when TOTEM_SPIRIT_OF_GANDI
        case st.memo_state
        when 101
          htmltext = "32057-01.html"
        when 102
          htmltext = "32057-03.html"
        when 109
          htmltext = "32057-04.html"
        end
      end
    end

    htmltext
  end
end
