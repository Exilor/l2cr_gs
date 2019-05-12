class Scripts::Q00373_SupplierOfReagents < Quest
  # NPCs
  private WESLEY = 30166
  private ALCHEMIST_MIXING_URN = 31149
  # Mobs
  private HALLATE_MAID = 20822
  private HALLATE_GUARDIAN = 21061
  private HAMES_ORC_SHAMAN = 21115
  private LAVA_WYRM = 21111
  private CRENDION = 20813
  private PLATINUM_TRIBE_SHAMAN = 20828
  private PLATINUM_GUARDIAN_SHAMAN = 21066
  # Items
  private REAGENT_POUNCH1 = 6007
  private REAGENT_POUNCH2 = 6008
  private REAGENT_POUNCH3 = 6009
  private REAGENT_BOX = 6010
  private WYRM_BLOOD = 6011
  private LAVA_STONE = 6012
  private MOONSTONE_SHARD = 6013
  private ROTTEN_BONE = 6014
  private DEMONS_BLOOD = 6015
  private INFERNIUM_ORE = 6016
  private BLOOD_ROOT = 6017
  private VOLCANIC_ASH = 6018
  private QUICKSILVER = 6019
  private SULFUR = 6020
  private DRACOPLASM = 6021
  private MAGMA_DUST = 6022
  private MOON_DUST = 6023
  private NECROPLASM = 6024
  private DEMONPLASM = 6025
  private INFERNO_DUST = 6026
  private DRACONIC_ESSENCE = 6027
  private FIRE_ESSENCE = 6028
  private LUNARGENT = 6029
  private MIDNIGHT_OIL = 6030
  private DEMONIC_ESSENCE = 6031
  private ABYSS_OIL = 6032
  private HELLFIRE_OIL = 6033
  private NIGHTMARE_OIL = 6034
  private PURE_SILVER = 6320
  private MIXING_MANUAL = 6317
  private WESLEYS_MIXING_STONE = 5904
  # Misc
  private MIN_LVL = 57
  private HTML_TO_MEMO_STATE = {
    "31149-03.html" => 11,
    "31149-04.html" => 12,
    "31149-05.html" => 13,
    "31149-06.html" => 14,
    "31149-07.html" => 15,
    "31149-08.html" => 16,
    "31149-09.html" => 17,
    "31149-10.html" => 18,
    "31149-11.html" => 19,
    "31149-12.html" => 20,
    "31149-13.html" => 21,
    "31149-14.html" => 22,
    "31149-15.html" => 23,
    "31149-16.html" => 24,
    "31149-19.html" => 1100,
    "31149-20.html" => 1200,
    "31149-21.html" => 1300,
    "31149-22.html" => 1400,
    "31149-23.html" => 1500,
    "31149-24.html" => 1600
  }
  private MEMO_STATE_TO_ITEM = {
    11 => ItemHolder.new(WYRM_BLOOD, 10),
    12 => ItemHolder.new(LAVA_STONE, 10),
    13 => ItemHolder.new(MOONSTONE_SHARD, 10),
    14 => ItemHolder.new(ROTTEN_BONE, 10),
    15 => ItemHolder.new(DEMONS_BLOOD, 10),
    16 => ItemHolder.new(INFERNIUM_ORE, 10),
    17 => ItemHolder.new(DRACOPLASM, 10),
    18 => ItemHolder.new(MAGMA_DUST, 10),
    19 => ItemHolder.new(MOON_DUST, 10),
    20 => ItemHolder.new(NECROPLASM, 10),
    21 => ItemHolder.new(DEMONPLASM, 10),
    22 => ItemHolder.new(INFERNO_DUST, 10),
    23 => ItemHolder.new(FIRE_ESSENCE, 1),
    24 => ItemHolder.new(LUNARGENT, 1),
    1100 => ItemHolder.new(BLOOD_ROOT, 1),
    1200 => ItemHolder.new(VOLCANIC_ASH, 1),
    1300 => ItemHolder.new(QUICKSILVER, 1),
    1400 => ItemHolder.new(SULFUR, 1),
    1500 => ItemHolder.new(DEMONIC_ESSENCE, 1),
    1600 => ItemHolder.new(MIDNIGHT_OIL, 1)
  }

  private record Entry, item : Int32, html : String

  private MEMO_STATE_TO_REWARD = {
    1111 => Entry.new(DRACOPLASM, "31149-30.html"),
    1212 => Entry.new(MAGMA_DUST, "31149-31.html"),
    1213 => Entry.new(MOON_DUST, "31149-32.html"),
    1114 => Entry.new(NECROPLASM, "31149-33.html"),
    1115 => Entry.new(DEMONPLASM, "31149-34.html"),
    1216 => Entry.new(INFERNO_DUST, "31149-35.html"),
    1317 => Entry.new(DRACONIC_ESSENCE, "31149-36.html"),
    1418 => Entry.new(FIRE_ESSENCE, "31149-37.html"),
    1319 => Entry.new(LUNARGENT, "31149-38.html"),
    1320 => Entry.new(MIDNIGHT_OIL, "31149-39.html"),
    1421 => Entry.new(DEMONIC_ESSENCE, "31149-40.html"),
    1422 => Entry.new(ABYSS_OIL, "31149-41.html"),
    1523 => Entry.new(HELLFIRE_OIL, "31149-42.html"),
    1624 => Entry.new(NIGHTMARE_OIL, "31149-43.html"),
    1324 => Entry.new(PURE_SILVER, "31149-46.html")
  }

  def initialize
    super(373, self.class.simple_name, "Supplier of Reagents")

    add_start_npc(WESLEY)
    add_kill_id(
      HALLATE_GUARDIAN, HALLATE_MAID, HAMES_ORC_SHAMAN, LAVA_WYRM, CRENDION,
      PLATINUM_GUARDIAN_SHAMAN, PLATINUM_TRIBE_SHAMAN
    )
    add_talk_id(WESLEY, ALCHEMIST_MIXING_URN)
    register_quest_items(WESLEYS_MIXING_STONE, MIXING_MANUAL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30166-03.htm", "30166-06.html", "30166-04a.html", "30166-04b.html",
         "30166-04c.html", "30166-04d.html", "31149-18.html"
      html = event
    when "30166-04.html"
      if pc.level >= MIN_LVL && qs.created?
        give_items(pc, WESLEYS_MIXING_STONE, 1)
        give_items(pc, MIXING_MANUAL, 1)
        qs.start_quest
        html = event
      end
    when "30166-07.html"
      qs.exit_quest(true, true)
      html = event
    when "31149-02.html"
      qs.memo_state = 0
      qs.set_memo_state_ex(1, 0)
      html = event
    when "31149-03.html", "31149-04.html", "31149-05.html", "31149-06.html",
         "31149-07.html", "31149-08.html", "31149-09.html", "31149-10.html",
         "31149-11.html", "31149-12.html", "31149-13.html", "31149-14.html",
         "31149-15.html", "31149-16.html", "31149-19.html", "31149-20.html",
         "31149-21.html", "31149-22.html", "31149-23.html", "31149-24.html"
      memo_state = HTML_TO_MEMO_STATE[event]
      if has_item?(pc, MEMO_STATE_TO_ITEM[memo_state])
        # If the player has the chosen item (ingredient or catalyst), we save it (for the catalyst or the reward)
        qs.memo_state += memo_state
        html = event
        play_sound(pc, Sound::SKILLSOUND_LIQUID_MIX)
      else
        # If the player has not the chosen catalyst, we take the ingredient previously saved (if not nil)
        take_item(pc, MEMO_STATE_TO_ITEM[qs.memo_state])
        if event == "31149-19.html"
          html = "31149-25.html"
        else
          html = "31149-17.html"
        end
      end
    when "31149-26.html"
      if qs.memo_state?(1324)
        html = "31149-26a.html"
      else
        html = event
      end
    when "31149-27.html"
      qs.set_memo_state_ex(1, 1) # Temperature Salamander
      html = event
    when "31149-28a.html"
      if rand(100) < 33
        qs.set_memo_state_ex(1, 3) # Temperature Ifrit
      else
        qs.set_memo_state_ex(1, 0)
      end
      html = event
    when "31149-29a.html"
      if rand(100) < 20
        qs.set_memo_state_ex(1, 5) # Temperature Phoenix
      else
        qs.set_memo_state_ex(1, 0)
      end
      html = event
    when "mixitems"
      memo_state = qs.memo_state
      item1 = MEMO_STATE_TO_ITEM[memo_state % 100]?
      item2 = MEMO_STATE_TO_ITEM[(memo_state / 100) * 100]?
      reward = MEMO_STATE_TO_REWARD[memo_state]?
      q235 = pc.get_quest_state(Q00235_MimirsElixir.simple_name)
      if reward.nil? || qs.memo_state_ex?(1, 0)
        take_item(pc, item1)
        take_item(pc, item2)
        html = reward.nil? ? "31149-44.html" : "31149-45.html"
        play_sound(pc, Sound::SKILLSOUND_LIQUID_FAIL)
      elsif memo_state != 1324 || (memo_state == 1324 && q235 && q235.started? && !has_quest_items?(pc, reward.item))
        if item1 && item2 && has_item?(pc, item1) && has_item?(pc, item2)
          take_item(pc, item1)
          take_item(pc, item2)
          give_items(pc, reward.item, memo_state == 1324 ? 1 : qs.get_memo_state_ex(1))
          qs.memo_state = 0
          qs.set_memo_state_ex(1, 0)
          html = reward.html
          play_sound(pc, Sound::SKILLSOUND_LIQUID_SUCCESS)
        else
          html = "31149-44.html"
          play_sound(pc, Sound::SKILLSOUND_LIQUID_FAIL)
        end
      else
        html = "31149-44.html"
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, -1, 3, npc)
      case npc.id
      when HALLATE_GUARDIAN
        chance = rand(1000)
        if chance < 766
          give_item_randomly(qs.player, npc, DEMONS_BLOOD, 3, 0, 1, true)
        elsif chance < 876
          give_item_randomly(qs.player, npc, MOONSTONE_SHARD, 1, 0, 1, true)
        end
      when HALLATE_MAID
        chance = rand(100)
        if chance < 45
          give_item_randomly(qs.player, npc, REAGENT_POUNCH1, 1, 0, 1, true)
        elsif chance < 65
          give_item_randomly(qs.player, npc, VOLCANIC_ASH, 1, 0, 1, true)
        end
      when HAMES_ORC_SHAMAN
        if rand(1000) < 616
          give_item_randomly(qs.player, npc, REAGENT_POUNCH3, 1, 0, 1, true)
        end
      when LAVA_WYRM
        chance = rand(1000)
        if chance < 666
          give_item_randomly(qs.player, npc, WYRM_BLOOD, 1, 0, 1, true)
        elsif chance < 989
          give_item_randomly(qs.player, npc, LAVA_STONE, 1, 0, 1, true)
        end
      when CRENDION
        if rand(1000) < 618
          give_item_randomly(qs.player, npc, ROTTEN_BONE, 1, 0, 1, true)
        else
          give_item_randomly(qs.player, npc, QUICKSILVER, 1, 0, 1, true)
        end
      when PLATINUM_GUARDIAN_SHAMAN
        if rand(1000) < 444
          give_item_randomly(qs.player, npc, REAGENT_BOX, 1, 0, 1, true)
        end
      when PLATINUM_TRIBE_SHAMAN
        if rand(1000) < 658
          give_item_randomly(qs.player, npc, REAGENT_POUNCH2, 1, 0, 1, true)
        else
          give_item_randomly(qs.player, npc, QUICKSILVER, 2, 0, 1, true)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if pc.level < MIN_LVL
        html = "30166-01.html"
      else
        html = "30166-02.htm"
      end
    elsif qs.started?
      if npc.id == WESLEY
        html = "30166-05.html"
      else
        html = "31149-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
