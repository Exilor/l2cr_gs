class Scripts::RangeGuard < AbstractNpcAI
  private ULTIMATE_DEFENSE = SkillHolder.new(5044, 3) # NPC Ultimate Defense

  private NOT_ALLOWED_SKILLS = {
    15, 28, # Charm / Aggression
    51, 65, # Lure / Horror
    106, 115, # Veil / Power Break
    122, 127, # Hex / Hamstring
    254, 352, # Spoil / Shield Bash
    353, 358, # Shield Slam / Bluff
    402, 403, # Arrest / Shackle
    412, 485, # Sand Bomb / Disarm
    501, 511, # Violent Temper / Temptation
    522, 531, # Real Target / Critical Wound
    680, 695, # Divine Knight Hate / Divine Wizard Divine Cloud
    696, 716, # Divine Wizard Surrender to Divine / Zaken Hold
    775, 792, # Weapon Blockade / Betrayal Mark
    1042, 1049, # Hold Undead / Requiem
    1069, 1071, # Sleep / Surrender To Water
    1072, 1074, # Sleeping Cloud / Surrender To Wind
    1083, 1097, # Surrender To Fire / Dreaming Spirit
    1092, 1064, # Fear / Silence
    1160, 1164, # Slow / Curse Weakness
    1169, 1170, # Curse Fear / Anchor
    1201, 1206, # Dryad Root / Wind Shackle
    1222, 1223, # Curse Chaos / Surrender To Earth
    1224, 1263, # Surrender To Poison / Curse Gloom
    1269, 1336, # Curse Disease / Curse of Doom
    1337, 1338, # Curse of Abyss / Arcane Chaos
    1358, 1359, # Block Shield / Block Wind Walk
    1386, 1394, # Arcane Disruption / Trance
    1396, 1445, # Magical BackFire / Surrender to Dark
    1446, 1447, # Shadow Bind / Voice Bind
    1481, 1482, # Oblivion / Weak Constitution
    1483, 1484, # Thin Skin / Enervation
    1485, 1486, # Spite / Mental Impoverish
    1511, 1524, # Curse of Life Flow / Surrender to the Divine
    1529 # Soul Web
  }

  private MIN_DISTANCE = 150

  def initialize
    super(self.class.simple_name, "ai/group_template")

    NpcData.get_all_npc_of_class_type("L2Monster").each do |template|
      if template.parameters.get_i32("LongRangeGuardRate", -1) > 0
        add_attack_id(template.id)
      end
    end
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    playable = is_summon ? (attacker.summon || attacker) : attacker
    dst = Util.calculate_distance(npc, playable, true, false)
    skill_id = ULTIMATE_DEFENSE.skill_id

    if npc.affected_by_skill?(skill_id) && dst <= MIN_DISTANCE
      npc.stop_skill_effects(true, skill_id)
    elsif dst > MIN_DISTANCE && !npc.skill_disabled?(skill_id) && !(skill && NOT_ALLOWED_SKILLS.bincludes?(skill.id))
      rate = npc.template.parameters.get_i32("LongRangeGuardRate")
      if Rnd.rand(100) < rate
        target = npc.target
        npc.target = npc
        npc.do_cast(ULTIMATE_DEFENSE)
        npc.target = target
      end
    end

    super
  end
end
