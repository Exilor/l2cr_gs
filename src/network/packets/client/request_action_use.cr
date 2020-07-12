require "../../../instance_managers/airship_manager"

class Packets::Incoming::RequestActionUse < GameClientPacket
  no_action_request

  private SIN_EATER_ID = 12564
  private SWITCH_STANCE_ID = 6054
  private NPC_STRINGS = {
    NpcString::USING_A_SPECIAL_SKILL_HERE_COULD_TRIGGER_A_BLOODBATH,
    NpcString::HEY_WHAT_DO_YOU_EXPECT_OF_ME,
    NpcString::UGGGGGH_PUSH_ITS_NOT_COMING_OUT,
    NpcString::AH_I_MISSED_THE_MARK
  }

  @id = 0
  @ctrl = false
  @shift = false

  private def read_impl
    @id = d
    @ctrl = d == 1
    @shift = c == 1
  end

  private def run_impl
    return unless pc = active_char

    if (pc.fake_death? && @id != 0) || pc.dead? || pc.out_of_control?
      action_failed
      return
    end

    if info = pc.effect_list.get_buff_info_by_abnormal_type(AbnormalType::BOT_PENALTY)
      info.effects.each do |effect|
        unless effect.check_condition(@id)
          send_packet(SystemMessageId::YOU_HAVE_BEEN_REPORTED_SO_ACTIONS_NOT_ALLOWED)
          action_failed
          return
        end
      end
    end

    if pc.transformed?
      unless ExBasicActionList::ACTIONS_ON_TRANSFORM.bincludes?(@id)
        action_failed
        debug { "#{pc.name} requested action #{@id} which he shouldn't have access to in his transformation." }
        return
      end
    end

    summon = pc.summon
    target = pc.target

    use_action(pc, summon, target)
  end

  private def schedule_sit(pc, target)
    na = NextAction.new(AI::ARRIVED, AI::MOVE_TO) { use_sit(pc, target) }
    pc.ai.next_action = na
  end

  private def use_action(pc, summon, target)
    case @id
    when 0 # Sit/Stand
      if pc.sitting? || !pc.moving? || pc.fake_death?
        use_sit(pc, target)
      else
        schedule_sit(pc, target)
      end
    when 1 # Walk/Run
      if pc.running?
        pc.set_walking
      else
        pc.set_running
      end
    when 10 # Private Store - Sell
      pc.try_open_private_sell_store(false)
    when 15 # Pet Movement Mode change
      validate_summon(summon, true) do |s|
        s.ai.as(L2SummonAI).notify_follow_status_change
      end
    when 16 # Pet Attack
      validate_summon(summon, true) do |s|
        if s.can_attack?(@ctrl)
          s.do_attack
        end
      end
    when 17 # Pet Stop
      validate_summon(summon, true, &.cancel_action)
    when 19 # Pet Unsummon
      validate_summon(summon, true) do |s|
        if s.dead?
          send_packet(SystemMessageId::DEAD_PET_CANNOT_BE_RETURNED)
          return
        end

        if s.attacking_now? || s.in_combat? || s.movement_disabled?
          send_packet(SystemMessageId::PET_CANNOT_SENT_BACK_DURING_BATTLE)
          return
        end

        if s.hungry?
          if s.pet? && s.as(L2PetInstance).pet_data.food.empty?
            send_packet(SystemMessageId::YOU_CANNOT_RESTORE_HUNGRY_PETS)
          else
            send_packet(SystemMessageId::THE_HELPER_PET_CANNOT_BE_RETURNED)
          end

          return
        end

        s.unsummon(pc)
      end
    when 21 # Servitor Movement Mode change
      validate_summon(summon, false) do |s|
        s.ai.as(L2SummonAI).notify_follow_status_change
      end
    when 22 # Servitor Attack
      validate_summon(summon, true) do |s|
        if s.can_attack?(@ctrl)
          s.do_attack
        end
      end
    when 23 # Servitor Stop
      validate_summon(summon, true, &.cancel_action)
    when 28 # Private Store - Buy
      pc.try_open_private_buy_store
    when 32 # Wild Hog Cannon - Wild Cannon
      use_skill("DDMagic", false)
    when 36 # Soulless - Toxic Smoke
      use_skill("RangeDebuff", false)
    when 37 # Dwarven Manufacture
      if pc.looks_dead?
        action_failed
        return
      end

      unless pc.private_store_type.none?
        pc.private_store_type = PrivateStoreType::NONE
        pc.broadcast_user_info
      end

      if pc.sitting?
        pc.stand_up
      end

      send_packet(RecipeShopManageList.new(pc, true))
    when 38 # Mount/Dismount
      pc.mount_player(summon)
    when 39 # Soulless - Parasite Burst
      use_skill("RangeDD", false)
    when 41 # Wild Hog Cannon - Attack
      use_skill(4230, false)
    when 42 # Kai the Cat - Self Damage Shield
      use_skill("HealMagic", false)
    when 43 # Merrow the Unicorn - Hydro Screw
      use_skill("DDMagic", false)
    when 44 # Big Boom - Boom Attack
      use_skill("DDMagic", false)
    when 45 # Boxer the Unicorn - Master Recharge
      use_skill("HealMagic", pc, false)
    when 46 # Mew the Cat - Mega Storm Strike
      use_skill("DDMagic", false)
    when 47 # Silhouette - Steal Blood
      use_skill("DDMagic", false)
    when 48 # Mechanic Golem - Mech. Cannon
      use_skill("DDMagic", false)
    when 51 # General Manufacture
      if pc.looks_dead?
        action_failed
        return
      end

      unless pc.private_store_type.none?
        pc.private_store_type = PrivateStoreType::NONE
        pc.broadcast_user_info
      end

      if pc.sitting?
        pc.stand_up
      end

      send_packet(RecipeShopManageList.new(pc, false))
    when 52 # Servitor Unsummon
      validate_summon(summon, false) do |s|
        if s.attacking_now? || s.in_combat?
          send_packet(SystemMessageId::SERVITOR_NOT_RETURN_IN_BATTLE)
          return
        end

        s.unsummon(pc)
      end
    when 53 # Servitor move to target
      validate_summon(summon, false) do |s|
        if target && s != target && !s.movement_disabled?
          s.follow_status = false
          s.set_intention(AI::MOVE_TO, target.not_nil!.location)
        end
      end
    when 54 # Pet move to target
      validate_summon(summon, true) do |s|
        if target && s != target && !s.movement_disabled?
          s.follow_status = false
          s.set_intention(AI::MOVE_TO, target.not_nil!.location)
        end
      end
    when 61 # Private Store package sell
      pc.try_open_private_sell_store(true)
    when 65 # Bot Report Button
      if Config.botreport_enable
        BotReportTable.report_bot(pc)
      else
        pc.send_message("This feature is disabled.")
      end
    when 67 # Airship Steer
      if (airship = pc.airship) && airship.set_captain(pc)
        pc.broadcast_user_info
      end
    when 68 # Airship Cancel Control
      if (airship = pc.airship) && airship.captain?(pc)
        if airship.set_captain(nil)
          pc.broadcast_user_info
        end
      end
    when 69 # Airship Destination Map
      AirshipManager.send_airship_teleport_list(pc)
    when 70 # Airship Exit
      if ship = pc.airship
        if ship.captain?(pc)
          if ship.set_captain(nil)
            pc.broadcast_user_info
          end
        elsif ship.in_dock?
          ship.oust_player(pc)
        end
      end
    when 71..73
      use_couple_social(@id - 55)
    when 1000 # Siege Golem - Siege Hammer
      if target.is_a?(L2DoorInstance)
        use_skill(4079, false)
      end
    when 1001 # Sin Eater - Ultimate Bombastic Buster
      validate_summon(summon, true) do |s|
        if s.id == SIN_EATER_ID
          say = NpcSay.new(s.l2id, Say2::NPC_ALL, s.id, NPC_STRINGS.sample)
          s.broadcast_packet(say)
        end
      end
    when 1003 # Wind Hatchling/Strider - Wild Stun
      use_skill("PhysicalSpecial", true)
    when 1004 # Wind Hatchling/Strider - Wild Defense
      use_skill("Buff", pc, true)
    when 1005 # Star Hatchling/Strider - Bright Burst
      use_skill("DDMagic", true)
    when 1006 # Star Hatchling/Strider - Bright Heal
      use_skill("Heal", true)
    when 1007 # Feline Queen - Blessing of Queen
      use_skill("Buff1", pc, false)
    when 1008 # Feline Queen - Gift of Queen
      use_skill("Buff2", pc, false)
    when 1009 # Feline Queen - Cure of Queen
      use_skill("DDMagic", pc, false)
    when 1010 # Unicorn Seraphim - Blessing of Seraphim
      use_skill("Buff1", pc, false)
    when 1011 # Unicorn Seraphim - Gift of Seraphim
      use_skill("Buff2", pc, false)
    when 1012 # Unicorn Seraphim - Cure of Seraphim
      use_skill("DDMagic", pc, false)
    when 1013 # Nightshade - Curse of Shade
      use_skill("DeBuff1", false)
    when 1014 # Nightshade - Mass Curse of Shade
      use_skill("DeBuff2", false)
    when 1015 # Nightshade - Shade Sacrifice
      use_skill("Heal", false)
    when 1016 # Cursed Man - Cursed Blow
      use_skill("PhysicalSpecial1", false)
    when 1017 # Cursed Man - Cursed Strike
      use_skill("PhysicalSpecial2", false)
    when 1031 # Feline King - Slash
      use_skill("PhysicalSpecial1", false)
    when 1032 # Feline King - Spinning Slash
      use_skill("PhysicalSpecial2", false)
    when 1033 # Feline King - Hold of King
      use_skill("PhysicalSpecial3", false)
    when 1034 # Magnus the Unicorn - Whiplash
      use_skill("PhysicalSpecial1", false)
    when 1035 # Magnus the Unicorn - Tridal Wave
      use_skill("PhysicalSpecial2", false)
    when 1036 # Spectral Lord - Corpse Kaboom
      use_skill("PhysicalSpecial1", false)
    when 1037 # Spectral Lord - Dicing Death
      use_skill("PhysicalSpecial2", false)
    when 1038 # Spectral Lord - Dark Curse
      use_skill("PhysicalSpecial3", false)
    when 1039 # Swoop Cannon - Cannon Fodder
      use_skill(5110, false)
    when 1040 # Swoop Cannon - Big Bang
      use_skill(5111, false)
    when 1041 # Great Wolf - Bite Attack
      use_skill("Skill01", true)
    when 1042 # Great Wolf - Maul
      use_skill("Skill03", true)
    when 1043 # Great Wolf - Cry of the Wolf
      use_skill("Skill02", true)
    when 1044 # Great Wolf - Awakening
      use_skill("Skill04", true)
    when 1045 # Great Wolf - Howl
      use_skill(5584, true)
    when 1046 # Strider - Roar
      use_skill(5585, true)
    when 1047 # Divine Beast - Bite
      use_skill(5580, false)
    when 1048 # Divine Beast - Stun Attack
      use_skill(5581, false)
    when 1049 # Divine Beast - Fire Breath
      use_skill(5582, false)
    when 1050 # Divine Beast - Roar
      use_skill(5583, false)
    when 1051 # Feline Queen - Bless The Body
      use_skill("buff3", false)
    when 1052 # Feline Queen - Bless The Soul
      use_skill("buff4", false)
    when 1053 # Feline Queen - Haste
      use_skill("buff5", false)
    when 1054 # Unicorn Seraphim - Acumen
      use_skill("buff3", false)
    when 1055 # Unicorn Seraphim - Clarity
      use_skill("buff4", false)
    when 1056 # Unicorn Seraphim - Empower
      use_skill("buff5", false)
    when 1057 # Unicorn Seraphim - Wild Magic
      use_skill("buff6", false)
    when 1058 # Nightshade - Death Whisper
      use_skill("buff3", false)
    when 1059 # Nightshade - Focus
      use_skill("buff4", false)
    when 1060 # Nightshade - Guidance
      use_skill("buff5", false)
    when 1061 # Wild Beast Fighter, White Weasel - Death blow
      use_skill(5745, true)
    when 1062 # Wild Beast Fighter - Double attack
      use_skill(5746, true)
    when 1063 # Wild Beast Fighter - Spin attack
      use_skill(5747, true)
    when 1064 # Wild Beast Fighter - Meteor Shower
      use_skill(5748, true)
    when 1065 # Fox Shaman, Wild Beast Fighter, White Weasel, Fairy Princess - Awakening
      use_skill(5753, true)
    when 1066 # Fox Shaman, Spirit Shaman - Thunder Bolt
      use_skill(5749, true)
    when 1067 # Fox Shaman, Spirit Shaman - Flash
      use_skill(5750, true)
    when 1068 # Fox Shaman, Spirit Shaman - Lightning Wave
      use_skill(5751, true)
    when 1069 # Fox Shaman, Fairy Princess - Flare
      use_skill(5752, true)
    when 1070 # White Weasel, Fairy Princess, Improved Baby Buffalo, Improved Baby Kookaburra, Improved Baby Cougar, Spirit Shaman, Toy Knight, Turtle Ascetic - Buff control
      use_skill(5771, true)
    when 1071 # Tigress - Power Strike
      use_skill("DDMagic", true)
    when 1072 # Toy Knight - Piercing attack
      use_skill(6046, true)
    when 1073 # Toy Knight - Whirlwind
      use_skill(6047, true)
    when 1074 # Toy Knight - Lance Smash
      use_skill(6048, true)
    when 1075 # Toy Knight - Battle Cry
      use_skill(6049, true)
    when 1076 # Turtle Ascetic - Power Smash
      use_skill(6050, true)
    when 1077 # Turtle Ascetic - Energy Burst
      use_skill(6051, true)
    when 1078 # Turtle Ascetic - Shockwave
      use_skill(6052, true)
    when 1079 # Turtle Ascetic - Howl
      use_skill(6053, true)
    when 1080 # Phoenix Rush
      use_skill(6041, false)
    when 1081 # Phoenix Cleanse
      use_skill(6042, false)
    when 1082 # Phoenix Flame Feather
      use_skill(6043, false)
    when 1083 # Phoenix Flame Beak
      use_skill(6044, false)
    when 1084 # Switch State
      use_skill(6054, true)
    when 1086 # Panther Cancel
      use_skill(6094, false)
    when 1087 # Panther Dark Claw
      use_skill(6095, false)
    when 1088 # Panther Fatal Claw
      use_skill(6096, false)
    when 1089 # Deinonychus - Tail Strike
      use_skill(6199, true)
    when 1090 # Guardian"s Strider - Strider Bite
      use_skill(6205, true)
    when 1091 # Guardian"s Strider - Strider Fear
      use_skill(6206, true)
    when 1092 # Guardian"s Strider - Strider Dash
      use_skill(6207, true)
    when 1093 # Maguen - Maguen Strike
      use_skill(6618, true)
    when 1094 # Maguen - Maguen Wind Walk
      use_skill(6681, true)
    when 1095 # Elite Maguen - Maguen Power Strike
      use_skill(6619, true)
    when 1096 # Elite Maguen - Elite Maguen Wind Walk
      use_skill(6682, true)
    when 1097 # Maguen - Maguen Return
      use_skill(6683, true)
    when 1098 # Elite Maguen - Maguen Party Return
      use_skill(6684, true)
    when 5000 # Baby Rudolph - Reindeer Scratch
      use_skill(23155, true)
    when 5001 # Deseloph, Hyum, Rekang, Lilias, Lapham, Mafum - Rosy Seduction
      use_skill(23167, true)
    when 5002 # Deseloph, Hyum, Rekang, Lilias, Lapham, Mafum - Critical Seduction
      use_skill(23168, true)
    when 5003 # Hyum, Lapham, Hyum, Lapham - Thunder Bolt
      use_skill(5749, true)
    when 5004 # Hyum, Lapham, Hyum, Lapham - Flash
      use_skill(5750, true)
    when 5005 # Hyum, Lapham, Hyum, Lapham - Lightning Wave
      use_skill(5751, true)
    when 5006 # Deseloph, Hyum, Rekang, Lilias, Lapham, Mafum, Deseloph, Hyum, Rekang, Lilias, Lapham, Mafum - Buff Control
      use_skill(5771, true)
    when 5007 # Deseloph, Lilias, Deseloph, Lilias - Piercing Attack
      use_skill(6046, true)
    when 5008 # Deseloph, Lilias, Deseloph, Lilias - Spin Attack
      use_skill(6047, true)
    when 5009 # Deseloph, Lilias, Deseloph, Lilias - Smash
      use_skill(6048, true)
    when 5010 # Deseloph, Lilias, Deseloph, Lilias - Ignite
      use_skill(6049, true)
    when 5011 # Rekang, Mafum, Rekang, Mafum - Power Smash
      use_skill(6050, true)
    when 5012 # Rekang, Mafum, Rekang, Mafum - Energy Burst
      use_skill(6051, true)
    when 5013 # Rekang, Mafum, Rekang, Mafum - Shockwave
      use_skill(6052, true)
    when 5014 # Rekang, Mafum, Rekang, Mafum - Ignite
      use_skill(6053, true)
    when 5015 # Deseloph, Hyum, Rekang, Lilias, Lapham, Mafum, Deseloph, Hyum, Rekang, Lilias, Lapham, Mafum - Switch Stance
      use_skill(6054, true)
    when 12 # Greeting
      try_broadcast_social(2)
    when 13 # Victory
      try_broadcast_social(3)
    when 14 # Advance
      try_broadcast_social(4)
    when 24 # Yes
      try_broadcast_social(6)
    when 25 # No
      try_broadcast_social(5)
    when 26 # Bow
      try_broadcast_social(7)
    when 29 # Unaware
      try_broadcast_social(8)
    when 30 # Social Waiting
      try_broadcast_social(9)
    when 31 # Laugh
      try_broadcast_social(10)
    when 33 # Applaud
      try_broadcast_social(11)
    when 34 # Dance
      try_broadcast_social(12)
    when 35 # Sorrow
      try_broadcast_social(13)
    when 62 # Charm
      try_broadcast_social(14)
    when 66 # Shyness
      try_broadcast_social(15)
    else
      warn { "#{pc.name} requested an unhandled action type: #{@id}." }
    end
  end

  private def use_sit(pc : L2PcInstance, target)
    return false unless pc.mount_type.none?

    if !pc.sitting? && target.is_a?(L2StaticObjectInstance) && target.type == 1
      if pc.inside_radius?(target, L2StaticObjectInstance::INTERACTION_DISTANCE, false, false)
        cs = ChairSit.new(pc, target.id)
        send_packet(cs)
        pc.sit_down
        pc.broadcast_packet(cs)
        return true
      end
    end

    if pc.fake_death?
      pc.stop_effects(EffectType::FAKE_DEATH)
    elsif pc.sitting?
      pc.stand_up
    else
      pc.sit_down
    end

    true
  end

  private def try_broadcast_social(id)
    return unless pc = active_char

    if pc.fishing?
      send_packet(SystemMessageId::CANNOT_DO_WHILE_FISHING_3)
      return
    end

    if pc.can_make_social_action?
      pc.broadcast_packet(SocialAction.new(pc.l2id, id))
    end
  end

  private def use_couple_social(id)
    return unless requester = active_char

    unless target = requester.target
      send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    unless target.is_a?(L2PcInstance)
      send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    distance = requester.calculate_distance(target, false, false).to_i
    if !distance.between?(15, 125) || requester == target
      send_packet(SystemMessageId::TARGET_DO_NOT_MEET_LOC_REQUIREMENTS)
      return
    end

    if requester.in_store_mode? || requester.in_craft_mode?
      sm = SystemMessage.c1_is_in_private_shop_mode_or_in_a_battle_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(requester)
      send_packet(sm)
      return
    end

    if requester.in_combat? || requester.in_duel? || AttackStances.includes?(requester)
      sm = SystemMessage.c1_is_in_a_battle_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(requester)
      send_packet(sm)
      return
    end

    if requester.fishing?
      send_packet(SystemMessageId::CANNOT_DO_WHILE_FISHING_3)
      return
    end

    if requester.karma > 0
      sm = SystemMessage.c1_is_in_a_chaotic_state_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(requester)
      send_packet(sm)
      return
    end

    if requester.in_olympiad_mode?
      sm = SystemMessage.c1_is_participating_in_the_olympiad_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(requester)
      send_packet(sm)
      return
    end

    if requester.in_siege?
      sm = SystemMessage.c1_is_in_a_castle_siege_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(requester)
      send_packet(sm)
      return
    end

    if requester.in_hideout_siege?
      sm = SystemMessage.c1_is_participating_in_a_hideout_siege_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(requester)
      send_packet(sm)
      return
    end

    if requester.mounted? || requester.flying_mounted? || requester.in_boat? || requester.in_airship?
      sm = SystemMessage.c1_is_riding_a_ship_steed_or_strider_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(requester)
      send_packet(sm)
    end

    if requester.transformed?
      sm = SystemMessage.c1_is_currently_transforming_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(requester)
      send_packet(sm)
      return
    end

    if requester.looks_dead?
      sm = SystemMessage.c1_is_currently_dead_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(requester)
      send_packet(sm)
      return
    end

    partner = target

    if partner.in_store_mode? || partner.in_craft_mode?
      sm = SystemMessage.c1_is_in_private_shop_mode_or_in_a_battle_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if partner.in_combat? || partner.in_duel? || AttackStances.includes?(partner)
      sm = SystemMessage.c1_is_in_a_battle_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if partner.multi_social_action > 0
      sm = SystemMessage.c1_is_already_participating_in_a_couple_action_and_cannot_be_requested_for_another_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if partner.fishing?
      sm = SystemMessage.c1_is_fishing_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if partner.karma > 0
      sm = SystemMessage.c1_is_in_a_chaotic_state_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if partner.in_olympiad_mode?
      sm = SystemMessage.c1_is_participating_in_the_olympiad_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if partner.in_hideout_siege?
      sm = SystemMessage.c1_is_participating_in_a_hideout_siege_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if partner.in_siege?
      sm = SystemMessage.c1_is_in_a_castle_siege_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if partner.mounted? || partner.flying_mounted? || partner.in_boat? || partner.in_airship?
      sm = SystemMessage.c1_is_riding_a_ship_steed_or_strider_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if partner.teleporting?
      sm = SystemMessage.c1_is_currently_teleporting_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if partner.transformed?
      sm = SystemMessage.c1_is_currently_transforming_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if partner.looks_dead?
      sm = SystemMessage.c1_is_currently_dead_and_cannot_be_requested_for_a_couple_action
      sm.add_pc_name(partner)
      send_packet(sm)
      return
    end

    if requester.all_skills_disabled? || partner.all_skills_disabled?
      send_packet(SystemMessageId::COUPLE_ACTION_CANCELED)
      return
    end

    requester.set_multi_social_action(id, partner.l2id)

    sm = SystemMessage.you_have_requested_couple_action_c1
    sm.add_pc_name(partner)
    send_packet(sm)

    if !requester.intention.idle? || !partner.intention.idle?
      packet = ExAskCoupleAction.new(requester.l2id, id)
      next_action = NextAction.new(AI::ARRIVED, AI::MOVE_TO) do
        partner.send_packet(packet)
      end
      requester.ai.next_action = next_action
      return
    end

    if requester.casting_now? || requester.casting_simultaneously_now?
      packet = ExAskCoupleAction.new(requester.l2id, id)
      next_action = NextAction.new(AI::FINISH_CASTING, AI::CAST) do
        partner.send_packet(packet)
      end
      requester.ai.next_action = next_action
      return
    end

    partner.send_packet(ExAskCoupleAction.new(requester.l2id, id))
  end

  private def validate_summon(summon : L2Summon?, check_pet : Bool, & : L2Summon ->) : L2Summon?
    if summon && ((check_pet && summon.pet?) || summon.servitor?)
      if summon.is_a?(L2PetInstance) && summon.uncontrollable?
        send_packet(SystemMessageId::WHEN_YOUR_PETS_HUNGER_GAUGE_IS_AT_0_YOU_CANNOT_USE_YOUR_PET)
        return nil
      end

      if summon.betrayed?
        send_packet(SystemMessageId::PET_REFUSING_ORDER)
        return nil
      end

      if summon.is_a?(L2Summon)
        yield summon
      end

      return summon
    end

    if check_pet
      send_packet(SystemMessageId::DONT_HAVE_PET)
    else
      send_packet(SystemMessageId::DONT_HAVE_SERVITOR)
    end

    nil
  end

  private def use_skill(skill_id : Int32, target : L2Object?, pet : Bool)
    return unless pc = active_char

    return unless summon = validate_summon(pc.summon, pet) {}
    return unless can_control?(summon)

    lvl = 0
    case summon
    when L2PetInstance
      pet_data = PetDataTable.get_pet_data(summon.id)
      lvl = pet_data.get_available_level(skill_id, summon.level)
    when L2ServitorInstance
      lvl = SummonSkillsTable.get_available_level(summon, skill_id)
    end

    if lvl > 0
      summon.target = target
      summon.use_magic(SkillData[skill_id, lvl], @ctrl, @shift)
    end

    if skill_id == SWITCH_STANCE_ID
      summon.switch_mode
    end
  end

  private def use_skill(skill_name : String, target : L2Object?, pet : Bool)
    return unless pc = active_char

    return unless summon = validate_summon(pc.summon, pet) {}
    return unless can_control?(summon)

    if summon.is_a?(L2PetInstance) && !summon.in_support_mode?
      send_packet(SystemMessageId::PET_AUXILIARY_MODE_CANNOT_USE_SKILLS)
      return
    end

    unless holder = summon.template.get_skill_holder(skill_name)
      warn { "#{pc.name} requested missing pet skill '#{skill_name}'." }
      return
    end

    unless skill = holder.skill?
      warn { "#{pc.name} requested missing pet skill #{holder}." }
      return
    end

    summon.target = target
    summon.use_magic(skill, @ctrl, @shift)

    if skill.id == SWITCH_STANCE_ID
      summon.switch_mode
    end
  end

  private def use_skill(skill_id : Int32, pet : Bool)
    return unless pc = active_char
    use_skill(skill_id, pc.target, pet)
  end

  private def use_skill(skill_name : String, pet : Bool)
    return unless pc = active_char
    use_skill(skill_name, pc.target, pet)
  end

  private def can_control?(summon : L2Summon) : Bool
    return false unless pc = active_char

    if summon.is_a?(L2PetInstance)
      unless summon.in_support_mode?
        send_packet(SystemMessageId::PET_AUXILIARY_MODE_CANNOT_USE_SKILLS)
        return false
      end

      if summon.level - pc.level > 20
        send_packet(SystemMessageId::PET_TOO_HIGH_TO_CONTROL)
        return false
      end
    end

    true
  end
end
