class Scripts::Q00416_PathOfTheOrcShaman < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    case event
    when "START"
      if !pc.class_id.orc_mage?
        if pc.class_id.orc_shaman?
          html = "30585-02.htm"
        else
          html = "30585-03.htm"
        end
      elsif pc.level < MIN_LEVEL
        html = "30585-04.htm"
      elsif has_quest_items?(pc, MASK_OF_MEDIUM)
        html = "30585-05.htm"
      else
        html = "30585-06.htm"
      end
    when "30585-07.htm"
      st.start_quest
      st.memo_state = 1
      give_items(pc, FIRE_CHARM, 1)
      html = event
    when "30585-12.html"
      if has_quest_items?(pc, TOTEM_SPIRIT_CLAW)
        html = event
      end
    when "30585-13.html"
      if has_quest_items?(pc, TOTEM_SPIRIT_CLAW)
        take_items(pc, TOTEM_SPIRIT_CLAW, -1)
        give_items(pc, TATARUS_LETTER, 1)
        st.set_cond(5, true)
        html = event
      end
    when "30585-14.html"
      if has_quest_items?(pc, TOTEM_SPIRIT_CLAW)
        take_items(pc, TOTEM_SPIRIT_CLAW, -1)
        st.set_cond(12, true)
        st.memo_state = 100
        html = event
      end
    when "30502-07.html"
      if has_quest_items?(pc, TOTEM_SPIRIT_BLOOD)
        take_items(pc, TOTEM_SPIRIT_BLOOD, -1)
        give_items(pc, MASK_OF_MEDIUM, 1)
        level = pc.level
        if level >= 20
          add_exp_and_sp(pc, 320_534, 22_992)
        elsif level >= 19
          add_exp_and_sp(pc, 456_128, 29_690)
        else
          add_exp_and_sp(pc, 591_724, 36_388)
        end
        give_adena(pc, 163_800, true)
        st.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        st.save_global_quest_var("1ClassQuestFinished", "1")
        html = event
      end
    when "32090-05.html"
      if st.memo_state?(106)
        html = event
      end
    when "32090-06.html"
      if st.memo_state?(106)
        st.memo_state = 107
        st.set_cond(18, true)
        html = event
      end
    when "30593-02.html"
      if has_quest_items?(pc, BLOOD_CAULDRON)
        html = event
      end
    when "30593-03.html"
      if has_quest_items?(pc, BLOOD_CAULDRON)
        take_items(pc, BLOOD_CAULDRON, -1)
        give_items(pc, SPIRIT_NET, 1)
        st.set_cond(9, true)
        html = event
      end
    when "30592-02.html"
      if has_quest_items?(pc, HESTUI_MASK, SECOND_FIERY_EGG)
        html = event
      end
    when "30592-03.html"
      if has_quest_items?(pc, HESTUI_MASK, SECOND_FIERY_EGG)
        take_items(pc, -1, {HESTUI_MASK, SECOND_FIERY_EGG})
        give_items(pc, TOTEM_SPIRIT_CLAW, 1)
        st.set_cond(4, true)
        html = event
      end
    when "32057-02.html"
      if st.memo_state?(101)
        st.memo_state = 102
        st.set_cond(14, true)
        html = event
      end
    when "32057-05.html"
      if st.memo_state?(109)
        st.memo_state = 110
        st.set_cond(21, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless st = get_random_party_member_state(pc, -1, 3, npc)
      return super
    end

    if npc.id == BLACK_LEOPARD
      case st.memo_state
      when 102
        st.memo_state = 103
      when 103
        st.memo_state = 104
        st.set_cond(15, true)
        if Rnd.rand(100) < 66
          npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::MY_DEAR_FRIEND_OF_S1_WHO_HAS_GONE_ON_AHEAD_OF_ME).add_string_parameter(st.player.name))
        end
      when 105
        st.memo_state = 106
        st.set_cond(17, true)
        if Rnd.rand(100) < 66
          npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::LISTEN_TO_TEJAKAR_GANDI_YOUNG_OROKA_THE_SPIRIT_OF_THE_SLAIN_LEOPARD_IS_CALLING_YOU_S1).add_string_parameter(st.player.name))
        end
      when 107
        st.memo_state = 108
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

        if npc.id.in?(20038, 20043)
          random = Rnd.rand(10)
          item_count = get_quest_items_count(st.player, DURKA_PARASITE)
          if (item_count == 5 && random < 1) ||
            (item_count == 6 && random < 2) ||
            (item_count == 7 && random < 2) || item_count >= 8
            take_items(pc, DURKA_PARASITE, -1)
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

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if st.created?
      if npc.id == TATARU_ZU_HESTUI
        html = "30585-01.htm"
      end
    elsif st.started?
      case npc.id
      when TATARU_ZU_HESTUI
        if st.memo_state?(1)
          if has_quest_items?(pc, FIRE_CHARM)
            if get_quest_items_count(pc, KASHA_BEAR_PELT, KASHA_BLADE_SPIDER_HUSK, FIRST_FIERY_EGG) < 3
              html = "30585-08.html"
            else
              take_items(pc, -1, {FIRE_CHARM, KASHA_BEAR_PELT, KASHA_BLADE_SPIDER_HUSK, FIRST_FIERY_EGG})
              give_items(pc, HESTUI_MASK, 1)
              give_items(pc, SECOND_FIERY_EGG, 1)
              st.set_cond(3, true)
              html = "30585-09.html"
            end
          elsif has_quest_items?(pc, HESTUI_MASK, SECOND_FIERY_EGG)
            html = "30585-10.html"
          elsif has_quest_items?(pc, TOTEM_SPIRIT_CLAW)
            html = "30585-11.html"
          elsif has_quest_items?(pc, TATARUS_LETTER)
            html = "30585-15.html"
          elsif has_at_least_one_quest_item?(pc, GRIZZLY_BLOOD, FLAME_CHARM, BLOOD_CAULDRON, SPIRIT_NET, BOUND_DURKA_SPIRIT, TOTEM_SPIRIT_BLOOD)
            html = "30585-16.html"
          end
        elsif st.memo_state?(100)
          html = "30585-14.html"
        end
      when UMOS
        if st.memo_state?(1)
          if has_quest_items?(pc, TATARUS_LETTER)
            give_items(pc, FLAME_CHARM, 1)
            take_items(pc, TATARUS_LETTER, -1)
            st.set_cond(6, true)
            html = "30502-01.html"
          elsif has_quest_items?(pc, FLAME_CHARM)
            if get_quest_items_count(pc, GRIZZLY_BLOOD) < 3
              html = "30502-02.html"
            else
              take_items(pc, -1, {FLAME_CHARM, GRIZZLY_BLOOD})
              give_items(pc, BLOOD_CAULDRON, 1)
              st.set_cond(8, true)
              html = "30502-03.html"
            end
          elsif has_quest_items?(pc, BLOOD_CAULDRON)
            html = "30502-04.html"
          elsif has_at_least_one_quest_item?(pc, BOUND_DURKA_SPIRIT, SPIRIT_NET)
            html = "30502-05.html"
          elsif has_quest_items?(pc, TOTEM_SPIRIT_BLOOD)
            html = "30502-06.html"
          end
        end
      when MOIRA
        memo_state = st.memo_state
        if memo_state == 100
          st.memo_state = 101
          st.set_cond(13, true)
          html = "31979-01.html"
        elsif memo_state >= 101 && memo_state < 108
          html = "31979-02.html"
        elsif memo_state == 110
          give_items(pc, MASK_OF_MEDIUM, 1)
          level = pc.level
          if level >= 20
            add_exp_and_sp(pc, 160_267, 11_496)
          elsif level >= 19
            add_exp_and_sp(pc, 228_064, 14_845)
          else
            add_exp_and_sp(pc, 295_862, 18_194)
          end
          give_adena(pc, 81900, true)
          st.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          st.save_global_quest_var("1ClassQuestFinished", "1")
          html = "31979-03.html"
        end
      when DEAD_LEOPARDS_CARCASS
        case st.memo_state
        when 102, 103
          html = "32090-01.html"
        when 104
          st.memo_state = 105
          st.set_cond(16, true)
          html = "32090-03.html"
        when 105
          html = "32090-01.html"
        when 106
          html = "32090-04.html"
        when 107
          html = "32090-07.html"
        when 108
          st.memo_state = 109
          st.set_cond(20, true)
          html = "32090-08.html"
        end
      when DUDA_MARA_TOTEM_SPIRIT
        if st.memo_state?(1)
          if has_quest_items?(pc, BLOOD_CAULDRON)
            html = "30593-01.html"
          elsif has_quest_items?(pc, SPIRIT_NET) && !has_quest_items?(pc, BOUND_DURKA_SPIRIT)
            html = "30593-04.html"
          elsif !has_quest_items?(pc, SPIRIT_NET) && has_quest_items?(pc, BOUND_DURKA_SPIRIT)
            take_items(pc, BOUND_DURKA_SPIRIT, -1)
            give_items(pc, TOTEM_SPIRIT_BLOOD, 1)
            st.set_cond(11, true)
            html = "30593-05.html"
          elsif has_quest_items?(pc, TOTEM_SPIRIT_BLOOD)
            html = "30593-06.html"
          end
        end
      when HESTUI_TOTEM_SPIRIT
        if st.memo_state?(1)
          if has_quest_items?(pc, HESTUI_MASK, SECOND_FIERY_EGG)
            html = "30592-01.html"
          elsif has_quest_items?(pc, TOTEM_SPIRIT_CLAW)
            html = "30592-04.html"
          elsif has_at_least_one_quest_item?(pc, GRIZZLY_BLOOD, FLAME_CHARM, BLOOD_CAULDRON, SPIRIT_NET, BOUND_DURKA_SPIRIT, TOTEM_SPIRIT_BLOOD, TATARUS_LETTER)
            html = "30592-05.html"
          end
        end
      when TOTEM_SPIRIT_OF_GANDI
        case st.memo_state
        when 101
          html = "32057-01.html"
        when 102
          html = "32057-03.html"
        when 109
          html = "32057-04.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
