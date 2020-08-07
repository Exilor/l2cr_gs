class Scripts::TreasureChest < AbstractNpcAI
  private TIMER_1 = "5001"
  private TIMER_2 = "5002"
  private MAX_SPAWN_TIME = 14400000 # 4 hours
  private ATTACK_SPAWN_TIME = 5000
  private PLAYER_LEVEL_THRESHOLD = 78
  private MAESTROS_KEY_SKILL_ID = 22271
  private TREASURE_BOMBS = {
    SkillHolder.new(4143, 1),
    SkillHolder.new(4143, 2),
    SkillHolder.new(4143, 3),
    SkillHolder.new(4143, 4),
    SkillHolder.new(4143, 5),
    SkillHolder.new(4143, 6),
    SkillHolder.new(4143, 7),
    SkillHolder.new(4143, 8),
    SkillHolder.new(4143, 9),
    SkillHolder.new(4143, 10)
  }

  private DROPS = { # Integer => ItemChanceHolder[]
    18265 => [ # Treasure Chest
      ItemChanceHolder.new(736, 2703, 7), # Scroll of Escape
      ItemChanceHolder.new(1061, 2365, 4), # Major Healing Potion
      ItemChanceHolder.new(737, 3784, 4), # Scroll of Resurrection
      ItemChanceHolder.new(10260, 1136, 1), # Haste Potion
      ItemChanceHolder.new(10261, 1136, 1), # Accuracy Juice
      ItemChanceHolder.new(10262, 1136, 1), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1136, 1), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1136, 1), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1136, 1), # Evasion Juice
      ItemChanceHolder.new(10266, 1136, 1), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1136, 1), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1136, 1), # Wind Walk Juice
      ItemChanceHolder.new(5593, 2365, 6), # SP Scroll (Low-grade)
      ItemChanceHolder.new(5594, 1136, 1), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(10269, 1136, 1), # P. Def. Juice
      ItemChanceHolder.new(10131, 4919, 1), # Transformation Scroll: Onyx Beast
      ItemChanceHolder.new(10132, 4919, 1), # Transformation Scroll: Doom Wraith
      ItemChanceHolder.new(10133, 4919, 1), # Transformation Scroll: Grail Apostle
      ItemChanceHolder.new(1538, 3279, 1), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1230, 1), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(68, 2617, 1), # Falchion
      ItemChanceHolder.new(21747, 320, 1)  # Novice Adventurer's Treasure Sack
    ],
    18266 => [ # Treasure Chest
      ItemChanceHolder.new(736, 7, 3159), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 2764), # Major Healing Potion
      ItemChanceHolder.new(737, 4, 4422), # Scroll of Resurrection
      ItemChanceHolder.new(10260, 1, 1327), # Haste Potion
      ItemChanceHolder.new(10261, 1, 1327), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 1327), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 1327), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 1327), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 1327), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 1327), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 1327), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 1327), # Wind Walk Juice
      ItemChanceHolder.new(5593, 6, 2764), # SP Scroll (Low-grade)
      ItemChanceHolder.new(5594, 1, 1327), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(10269, 1, 1327), # P. Def. Juice
      ItemChanceHolder.new(10131, 1, 5749), # Transformation Scroll: Onyx Beast
      ItemChanceHolder.new(10132, 1, 5749), # Transformation Scroll: Doom Wraith
      ItemChanceHolder.new(10133, 1, 5749), # Transformation Scroll: Grail Apostle
      ItemChanceHolder.new(1538, 1, 3833), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 1438), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(68, 1, 3058), # Falchion
      ItemChanceHolder.new(21747, 1, 374)  # Novice Adventurer's Treasure Sack
    ],
    18267 => [ # Treasure Chest
      ItemChanceHolder.new(736, 7, 3651), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 3194), # Major Healing Potion
      ItemChanceHolder.new(737, 4, 5111), # Scroll of Resurrection
      ItemChanceHolder.new(10260, 1, 1534), # Haste Potion
      ItemChanceHolder.new(10261, 1, 1534), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 1534), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 1534), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 1534), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 1534), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 1534), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 1534), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 1534), # Wind Walk Juice
      ItemChanceHolder.new(5593, 6, 3194), # SP Scroll (Low-grade)
      ItemChanceHolder.new(5594, 1, 1534), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(10269, 1, 1534), # P. Def. Juice
      ItemChanceHolder.new(10131, 1, 6644), # Transformation Scroll: Onyx Beast
      ItemChanceHolder.new(10132, 1, 6644), # Transformation Scroll: Doom Wraith
      ItemChanceHolder.new(10133, 1, 6644), # Transformation Scroll: Grail Apostle
      ItemChanceHolder.new(1538, 1, 4429), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 1661), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(68, 1, 3534), # Falchion
      ItemChanceHolder.new(21747, 1, 463)  # Novice Adventurer's Treasure Sack
    ],
    18268 => [ # Treasure Chest
      ItemChanceHolder.new(736, 7, 4200), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 3675), # Major Healing Potion
      ItemChanceHolder.new(737, 4, 5879), # Scroll of Resurrection
      ItemChanceHolder.new(10260, 1, 1764), # Haste Potion
      ItemChanceHolder.new(10261, 1, 1764), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 1764), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 1764), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 1764), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 1764), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 1764), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 1764), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 1764), # Wind Walk Juice
      ItemChanceHolder.new(5593, 6, 3675), # SP Scroll (Low-grade)
      ItemChanceHolder.new(5594, 1, 1764), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(10269, 1, 1764), # P. Def. Juice
      ItemChanceHolder.new(10134, 1, 5095), # Transformation Scroll: Unicorn
      ItemChanceHolder.new(10135, 1, 5095), # Transformation Scroll: Lilim Knight
      ItemChanceHolder.new(10136, 1, 5095), # Transformation Scroll: Golem Guardian
      ItemChanceHolder.new(1538, 1, 5095), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 1911), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(69, 1, 1543), # Bastard Sword
      ItemChanceHolder.new(21747, 1, 498)  # Novice Adventurer's Treasure Sack
    ],
    18269 => [ # Treasure Chest
      ItemChanceHolder.new(736, 7, 5010), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 4383), # Major Healing Potion
      ItemChanceHolder.new(737, 4, 7013), # Scroll of Resurrection
      ItemChanceHolder.new(10260, 1, 2104), # Haste Potion
      ItemChanceHolder.new(10261, 1, 2104), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 2104), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 2104), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 2104), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 2104), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 2104), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 2104), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 2104), # Wind Walk Juice
      ItemChanceHolder.new(5593, 6, 4383), # SP Scroll (Low-grade)
      ItemChanceHolder.new(5594, 1, 2104), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(10269, 1, 2104), # P. Def. Juice
      ItemChanceHolder.new(10134, 1, 6078), # Transformation Scroll: Unicorn
      ItemChanceHolder.new(10135, 1, 6078), # Transformation Scroll: Lilim Knight
      ItemChanceHolder.new(10136, 1, 6078), # Transformation Scroll: Golem Guardian
      ItemChanceHolder.new(1538, 1, 6078), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 2280), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(69, 1, 1840), # Bastard Sword
      ItemChanceHolder.new(21747, 1, 593)  # Novice Adventurer's Treasure Sack
    ],
    18270 => [ # Treasure Chest
      ItemChanceHolder.new(736, 7, 5894), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 5157), # Major Healing Potion
      ItemChanceHolder.new(737, 4, 8252), # Scroll of Resurrection
      ItemChanceHolder.new(10260, 1, 2476), # Haste Potion
      ItemChanceHolder.new(10261, 1, 2476), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 2476), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 2476), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 2476), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 2476), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 2476), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 2476), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 2476), # Wind Walk Juice
      ItemChanceHolder.new(5593, 6, 5157), # SP Scroll (Low-grade)
      ItemChanceHolder.new(5594, 1, 2476), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(10269, 1, 2476), # P. Def. Juice
      ItemChanceHolder.new(10134, 1, 7152), # Transformation Scroll: Unicorn
      ItemChanceHolder.new(10135, 1, 7152), # Transformation Scroll: Lilim Knight
      ItemChanceHolder.new(10136, 1, 7152), # Transformation Scroll: Golem Guardian
      ItemChanceHolder.new(1538, 1, 7152), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 2682), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(69, 1, 2165), # Bastard Sword
      ItemChanceHolder.new(21747, 1, 698)  # Novice Adventurer's Treasure Sack
    ],
    18271 => [ # Treasure Chest
      ItemChanceHolder.new(736, 7, 6879), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 6019), # Major Healing Potion
      ItemChanceHolder.new(737, 4, 9630), # Scroll of Resurrection
      ItemChanceHolder.new(10260, 1, 2889), # Haste Potion
      ItemChanceHolder.new(10261, 1, 2889), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 2889), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 2889), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 2889), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 2889), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 2889), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 2889), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 2889), # Wind Walk Juice
      ItemChanceHolder.new(5593, 6, 6019), # SP Scroll (Low-grade)
      ItemChanceHolder.new(5594, 1, 2889), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(10269, 1, 2889), # P. Def. Juice
      ItemChanceHolder.new(10134, 1, 8346), # Transformation Scroll: Unicorn
      ItemChanceHolder.new(10135, 1, 8346), # Transformation Scroll: Lilim Knight
      ItemChanceHolder.new(10136, 1, 8346), # Transformation Scroll: Golem Guardian
      ItemChanceHolder.new(1538, 1, 8346), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 3130), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(69, 1, 2527), # Bastard Sword
      ItemChanceHolder.new(21747, 1, 815)  # Novice Adventurer's Treasure Sack
    ],
    18272 => [ # Treasure Chest
      ItemChanceHolder.new(736, 5, 6668), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 4168), # Major Healing Potion
      ItemChanceHolder.new(737, 3, 2223), # Scroll of Resurrection
      ItemChanceHolder.new(1539, 5, 6668), # Major Healing Potion
      ItemChanceHolder.new(8625, 2, 3334), # Elixir of Life (B-grade)
      ItemChanceHolder.new(8631, 2, 2874), # Elixir of Mind (B-grade)
      ItemChanceHolder.new(8637, 3, 5557), # Elixir of CP (B-grade)
      ItemChanceHolder.new(8636, 4, 5557), # Elixir of CP (C-grade)
      ItemChanceHolder.new(8630, 2, 3832), # Elixir of Mind (C-grade)
      ItemChanceHolder.new(8624, 2, 4631), # Elixir of Life (C-grade)
      ItemChanceHolder.new(10260, 1, 5129), # Haste Potion
      ItemChanceHolder.new(10261, 1, 5129), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 5129), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 5129), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 5129), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 5129), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 5129), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 5129), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 5129), # Wind Walk Juice
      ItemChanceHolder.new(5593, 9, 7124), # SP Scroll (Low-grade)
      ItemChanceHolder.new(5594, 2, 6411), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(5595, 1, 642), # SP Scroll (High-grade)
      ItemChanceHolder.new(10269, 1, 5129), # P. Def. Juice
      ItemChanceHolder.new(10137, 1, 5418), # Transformation Scroll: Inferno Drake
      ItemChanceHolder.new(10138, 1, 5418), # Transformation Scroll: Dragon Bomber
      ItemChanceHolder.new(1538, 1, 7223), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 2709), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(5577, 1, 2167), # Red Soul Crystal - Stage 11
      ItemChanceHolder.new(5578, 1, 2167), # Green Soul Crystal - Stage 11
      ItemChanceHolder.new(5579, 1, 2167), # Blue Soul Crystal - Stage 11
      ItemChanceHolder.new(70, 1, 1250), # Claymore
      ItemChanceHolder.new(21747, 1, 940)  # Novice Adventurer's Treasure Sack
    ],
    18273 => [ # Treasure Chest
      ItemChanceHolder.new(736, 5, 7662), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 4789), # Major Healing Potion
      ItemChanceHolder.new(737, 3, 2554), # Scroll of Resurrection
      ItemChanceHolder.new(1539, 5, 7662), # Major Healing Potion
      ItemChanceHolder.new(8625, 2, 3831), # Elixir of Life (B-grade)
      ItemChanceHolder.new(8631, 2, 3303), # Elixir of Mind (B-grade)
      ItemChanceHolder.new(8637, 3, 6385), # Elixir of CP (B-grade)
      ItemChanceHolder.new(8636, 4, 6385), # Elixir of CP (C-grade)
      ItemChanceHolder.new(8630, 2, 4404), # Elixir of Mind (C-grade)
      ItemChanceHolder.new(8624, 2, 5321), # Elixir of Life (C-grade)
      ItemChanceHolder.new(10260, 1, 5894), # Haste Potion
      ItemChanceHolder.new(10261, 1, 5894), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 5894), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 5894), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 5894), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 5894), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 5894), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 5894), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 5894), # Wind Walk Juice
      ItemChanceHolder.new(5593, 9, 8186), # SP Scroll (Low-grade)
      ItemChanceHolder.new(5594, 2, 7367), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(5595, 1, 737), # SP Scroll (High-grade)
      ItemChanceHolder.new(10269, 1, 5894), # P. Def. Juice
      ItemChanceHolder.new(10137, 1, 6226), # Transformation Scroll: Inferno Drake
      ItemChanceHolder.new(10138, 1, 6226), # Transformation Scroll: Dragon Bomber
      ItemChanceHolder.new(1538, 1, 8301), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 3113), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(5577, 1, 2491), # Red Soul Crystal - Stage 11
      ItemChanceHolder.new(5578, 1, 2491), # Green Soul Crystal - Stage 11
      ItemChanceHolder.new(5579, 1, 2491), # Blue Soul Crystal - Stage 11
      ItemChanceHolder.new(70, 1, 1437), # Claymore
      ItemChanceHolder.new(21747, 1, 1080)  # Novice Adventurer's Treasure Sack
    ],
    18274 => [ # Treasure Chest
      ItemChanceHolder.new(736, 5, 8719), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 5450), # Major Healing Potion
      ItemChanceHolder.new(737, 3, 2907), # Scroll of Resurrection
      ItemChanceHolder.new(1539, 5, 8719), # Major Healing Potion
      ItemChanceHolder.new(8625, 2, 4360), # Elixir of Life (B-grade)
      ItemChanceHolder.new(8631, 2, 3759), # Elixir of Mind (B-grade)
      ItemChanceHolder.new(8637, 3, 7266), # Elixir of CP (B-grade)
      ItemChanceHolder.new(8636, 4, 7266), # Elixir of CP (C-grade)
      ItemChanceHolder.new(8630, 2, 5011), # Elixir of Mind (C-grade)
      ItemChanceHolder.new(8624, 2, 6055), # Elixir of Life (C-grade)
      ItemChanceHolder.new(10260, 1, 6707), # Haste Potion
      ItemChanceHolder.new(10261, 1, 6707), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 6707), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 6707), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 6707), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 6707), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 6707), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 6707), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 6707), # Wind Walk Juice
      ItemChanceHolder.new(5593, 9, 9315), # SP Scroll (Low-grade)
      ItemChanceHolder.new(5594, 2, 8384), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(5595, 1, 839), # SP Scroll (High-grade)
      ItemChanceHolder.new(10269, 1, 6707), # P. Def. Juice
      ItemChanceHolder.new(21180, 1, 7084), # Transformation Scroll: Heretic - Event
      ItemChanceHolder.new(21181, 1, 5668), # Transformation Scroll: Veil Master - Event
      ItemChanceHolder.new(1538, 1, 9446), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 3542), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(5577, 1, 2834), # Red Soul Crystal - Stage 11
      ItemChanceHolder.new(5578, 1, 2834), # Green Soul Crystal - Stage 11
      ItemChanceHolder.new(5579, 1, 2834), # Blue Soul Crystal - Stage 11
      ItemChanceHolder.new(135, 1, 481), # Samurai Long Sword
      ItemChanceHolder.new(21747, 1, 1229)  # Novice Adventurer's Treasure Sack
    ],
    18275 => [ # Treasure Chest
      ItemChanceHolder.new(736, 5, 9881), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 6176), # Major Healing Potion
      ItemChanceHolder.new(737, 3, 3294), # Scroll of Resurrection
      ItemChanceHolder.new(1539, 5, 9881), # Major Healing Potion
      ItemChanceHolder.new(8625, 2, 4941), # Elixir of Life (B-grade)
      ItemChanceHolder.new(8631, 2, 4259), # Elixir of Mind (B-grade)
      ItemChanceHolder.new(8637, 3, 8234), # Elixir of CP (B-grade)
      ItemChanceHolder.new(8636, 4, 8234), # Elixir of CP (C-grade)
      ItemChanceHolder.new(8630, 2, 5679), # Elixir of Mind (C-grade)
      ItemChanceHolder.new(8624, 2, 6862), # Elixir of Life (C-grade)
      ItemChanceHolder.new(10260, 1, 7601), # Haste Potion
      ItemChanceHolder.new(10261, 1, 7601), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 7601), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 7601), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 7601), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 7601), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 7601), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 7601), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 7601), # Wind Walk Juice
      ItemChanceHolder.new(5593, 9, 10557), # SP Scroll (Low-grade)
      ItemChanceHolder.new(5594, 2, 9501), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(5595, 1, 951), # SP Scroll (High-grade)
      ItemChanceHolder.new(10269, 1, 7601), # P. Def. Juice
      ItemChanceHolder.new(21180, 1, 8028), # Transformation Scroll: Heretic - Event
      ItemChanceHolder.new(21181, 1, 6423), # Transformation Scroll: Veil Master - Event
      ItemChanceHolder.new(1538, 1, 10704), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 4014), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(5577, 1, 3212), # Red Soul Crystal - Stage 11
      ItemChanceHolder.new(5578, 1, 3212), # Green Soul Crystal - Stage 11
      ItemChanceHolder.new(5579, 1, 3212), # Blue Soul Crystal - Stage 11
      ItemChanceHolder.new(135, 1, 546), # Samurai Long Sword
      ItemChanceHolder.new(21747, 1, 1393)  # Novice Adventurer's Treasure Sack
    ],
    18276 => [ # Treasure Chest
      ItemChanceHolder.new(736, 8, 7727), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 7727), # Major Healing Potion
      ItemChanceHolder.new(737, 3, 4121), # Scroll of Resurrection
      ItemChanceHolder.new(8625, 2, 6182), # Elixir of Life (B-grade)
      ItemChanceHolder.new(8631, 2, 5329), # Elixir of Mind (B-grade)
      ItemChanceHolder.new(8637, 4, 7727), # Elixir of CP (B-grade)
      ItemChanceHolder.new(8638, 3, 8242), # Elixir of CP (A-grade)
      ItemChanceHolder.new(8632, 2, 4293), # Elixir of Mind (A-grade)
      ItemChanceHolder.new(8626, 2, 4945), # Elixir of Life (A-grade)
      ItemChanceHolder.new(10260, 1, 4451), # Haste Potion
      ItemChanceHolder.new(10261, 1, 4451), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 4451), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 4451), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 4451), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 4451), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 4451), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 4451), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 4451), # Wind Walk Juice
      ItemChanceHolder.new(5594, 2, 5563), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(5595, 1, 557), # SP Scroll (High-grade)
      ItemChanceHolder.new(10269, 1, 4451), # P. Def. Juice
      ItemChanceHolder.new(8736, 1, 6439), # Mid-grade Life Stone - Lv. 55
      ItemChanceHolder.new(8737, 1, 5563), # Mid-grade Life Stone - Lv. 58
      ItemChanceHolder.new(8738, 1, 4636), # Mid-grade Life Stone - Lv. 61
      ItemChanceHolder.new(21182, 1, 5786), # Transformation Scroll: Saber Tooth Tiger - Event
      ItemChanceHolder.new(21183, 1, 4822), # Transformation Scroll: Oel Mahum - Event
      ItemChanceHolder.new(1538, 2, 4822), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 3616), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(9648, 1, 670), # Transformation Sealbook: Onyx Beast
      ItemChanceHolder.new(9649, 1, 804), # Transformation Sealbook: Doom Wraith
      ItemChanceHolder.new(5580, 1, 145), # Red Soul Crystal - Stage 12
      ItemChanceHolder.new(5581, 1, 145), # Green Soul Crystal - Stage 12
      ItemChanceHolder.new(5582, 1, 145), # Blue Soul Crystal - Stage 12
      ItemChanceHolder.new(142, 1, 217), # Keshanberk
      ItemChanceHolder.new(21748, 1, 92)  # Experienced Adventurer's Treasure Sack
    ],
    18277 => [ # Treasure Chest
      ItemChanceHolder.new(736, 8, 8657), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 8657), # Major Healing Potion
      ItemChanceHolder.new(737, 3, 4617), # Scroll of Resurrection
      ItemChanceHolder.new(8625, 2, 6926), # Elixir of Life (B-grade)
      ItemChanceHolder.new(8631, 2, 5971), # Elixir of Mind (B-grade)
      ItemChanceHolder.new(8637, 4, 8657), # Elixir of CP (B-grade)
      ItemChanceHolder.new(8638, 3, 9234), # Elixir of CP (A-grade)
      ItemChanceHolder.new(8632, 2, 4810), # Elixir of Mind (A-grade)
      ItemChanceHolder.new(8626, 2, 5541), # Elixir of Life (A-grade)
      ItemChanceHolder.new(10260, 1, 4987), # Haste Potion
      ItemChanceHolder.new(10261, 1, 4987), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 4987), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 4987), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 4987), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 4987), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 4987), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 4987), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 4987), # Wind Walk Juice
      ItemChanceHolder.new(5594, 2, 6233), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(5595, 1, 624), # SP Scroll (High-grade)
      ItemChanceHolder.new(10269, 1, 4987), # P. Def. Juice
      ItemChanceHolder.new(8736, 1, 7214), # Mid-grade Life Stone - Lv. 55
      ItemChanceHolder.new(8737, 1, 6233), # Mid-grade Life Stone - Lv. 58
      ItemChanceHolder.new(8738, 1, 5195), # Mid-grade Life Stone - Lv. 61
      ItemChanceHolder.new(21183, 1, 5402), # Transformation Scroll: Oel Mahum - Event
      ItemChanceHolder.new(21184, 1, 5402), # Transformation Scroll: Doll Blader - Event
      ItemChanceHolder.new(1538, 2, 5402), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 4052), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(9648, 1, 751), # Transformation Sealbook: Onyx Beast
      ItemChanceHolder.new(9649, 1, 901), # Transformation Sealbook: Doom Wraith
      ItemChanceHolder.new(5580, 1, 163), # Red Soul Crystal - Stage 12
      ItemChanceHolder.new(5581, 1, 163), # Green Soul Crystal - Stage 12
      ItemChanceHolder.new(5582, 1, 163), # Blue Soul Crystal - Stage 12
      ItemChanceHolder.new(79, 1, 161), # Damascus Sword
      ItemChanceHolder.new(21748, 1, 103)  # Experienced Adventurer's Treasure Sack
    ],
    18278 => [ # Treasure Chest
      ItemChanceHolder.new(736, 8, 9646), # Scroll of Escape
      ItemChanceHolder.new(1061, 4, 9646), # Major Healing Potion
      ItemChanceHolder.new(737, 3, 5145), # Scroll of Resurrection
      ItemChanceHolder.new(8625, 2, 7717), # Elixir of Life (B-grade)
      ItemChanceHolder.new(8631, 2, 6652), # Elixir of Mind (B-grade)
      ItemChanceHolder.new(8637, 4, 9646), # Elixir of CP (B-grade)
      ItemChanceHolder.new(8638, 3, 10289), # Elixir of CP (A-grade)
      ItemChanceHolder.new(8632, 2, 5359), # Elixir of Mind (A-grade)
      ItemChanceHolder.new(8626, 2, 6173), # Elixir of Life (A-grade)
      ItemChanceHolder.new(10260, 1, 5556), # Haste Potion
      ItemChanceHolder.new(10261, 1, 5556), # Accuracy Juice
      ItemChanceHolder.new(10262, 1, 5556), # Critical Damage Juice
      ItemChanceHolder.new(10263, 1, 5556), # Critical Rate Juice
      ItemChanceHolder.new(10264, 1, 5556), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 1, 5556), # Evasion Juice
      ItemChanceHolder.new(10266, 1, 5556), # M. Atk. Juice
      ItemChanceHolder.new(10267, 1, 5556), # P. Atk. Potion
      ItemChanceHolder.new(10268, 1, 5556), # Wind Walk Juice
      ItemChanceHolder.new(5594, 2, 6945), # SP Scroll (Mid-grade)
      ItemChanceHolder.new(5595, 1, 695), # SP Scroll (High-grade)
      ItemChanceHolder.new(10269, 1, 5556), # P. Def. Juice
      ItemChanceHolder.new(8736, 1, 8038), # Mid-grade Life Stone - Lv. 55
      ItemChanceHolder.new(8737, 1, 6945), # Mid-grade Life Stone - Lv. 58
      ItemChanceHolder.new(8738, 1, 5788), # Mid-grade Life Stone - Lv. 61
      ItemChanceHolder.new(21183, 1, 6019), # Transformation Scroll: Oel Mahum - Event
      ItemChanceHolder.new(21184, 1, 6019), # Transformation Scroll: Doll Blader - Event
      ItemChanceHolder.new(1538, 2, 6019), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 4514), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(9648, 1, 836), # Transformation Sealbook: Onyx Beast
      ItemChanceHolder.new(9649, 1, 1004), # Transformation Sealbook: Doom Wraith
      ItemChanceHolder.new(5580, 1, 181), # Red Soul Crystal - Stage 12
      ItemChanceHolder.new(5581, 1, 181), # Green Soul Crystal - Stage 12
      ItemChanceHolder.new(5582, 1, 181), # Blue Soul Crystal - Stage 12
      ItemChanceHolder.new(79, 1, 179), # Damascus Sword
      ItemChanceHolder.new(21748, 1, 115)  # Experienced Adventurer's Treasure Sack
    ],
    18279 => [ # Treasure Chest
      ItemChanceHolder.new(8627, 2, 5714), # Elixir of Life (S-grade)
      ItemChanceHolder.new(8633, 2, 5102), # Elixir of Mind (S-grade)
      ItemChanceHolder.new(8639, 5, 5714), # Elixir of CP (S-grade)
      ItemChanceHolder.new(8638, 6, 5714), # Elixir of CP (A-grade)
      ItemChanceHolder.new(8632, 2, 5953), # Elixir of Mind (A-grade)
      ItemChanceHolder.new(8626, 3, 4572), # Elixir of Life (A-grade)
      ItemChanceHolder.new(729, 1, 96), # Scroll: Enchant Weapon (A-grade)
      ItemChanceHolder.new(730, 1, 715), # Scroll: Enchant Armor (A-grade)
      ItemChanceHolder.new(1540, 4, 4286), # Quick Healing Potion
      ItemChanceHolder.new(10260, 3, 1929), # Haste Potion
      ItemChanceHolder.new(10261, 3, 1929), # Accuracy Juice
      ItemChanceHolder.new(10262, 3, 1929), # Critical Damage Juice
      ItemChanceHolder.new(10263, 3, 1929), # Critical Rate Juice
      ItemChanceHolder.new(10264, 3, 1929), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 3, 1929), # Evasion Juice
      ItemChanceHolder.new(10266, 3, 1929), # M. Atk. Juice
      ItemChanceHolder.new(10267, 3, 1929), # P. Atk. Potion
      ItemChanceHolder.new(10268, 3, 1929), # Wind Walk Juice
      ItemChanceHolder.new(5595, 1, 724), # SP Scroll (High-grade)
      ItemChanceHolder.new(9898, 1, 724), # SP Scroll (Top-grade)
      ItemChanceHolder.new(10269, 3, 1929), # P. Def. Juice
      ItemChanceHolder.new(8739, 1, 4822), # Mid-grade Life Stone - Lv. 64
      ItemChanceHolder.new(8740, 1, 4018), # Mid-grade Life Stone - Lv. 67
      ItemChanceHolder.new(8741, 1, 3349), # Mid-grade Life Stone - Lv. 70
      ItemChanceHolder.new(8742, 1, 3014), # Mid-grade Life Stone - Lv. 76
      ItemChanceHolder.new(21180, 1, 9117), # Transformation Scroll: Heretic - Event
      ItemChanceHolder.new(21181, 1, 7294), # Transformation Scroll: Veil Master - Event
      ItemChanceHolder.new(21182, 1, 7294), # Transformation Scroll: Saber Tooth Tiger - Event
      ItemChanceHolder.new(1538, 2, 6078), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 4559), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(9654, 1, 845), # Transformation Sealbook: Inferno Drake
      ItemChanceHolder.new(9655, 1, 845), # Transformation Sealbook: Dragon Bomber
      ItemChanceHolder.new(5580, 1, 183), # Red Soul Crystal - Stage 12
      ItemChanceHolder.new(5581, 1, 183), # Green Soul Crystal - Stage 12
      ItemChanceHolder.new(5582, 1, 183), # Blue Soul Crystal - Stage 12
      ItemChanceHolder.new(80, 1, 130), # Tallum Blade
      ItemChanceHolder.new(21748, 1, 128)  # Experienced Adventurer's Treasure Sack
    ],
    18280 => [ # Treasure Chest
      ItemChanceHolder.new(8627, 2, 6323), # Elixir of Life (S-grade)
      ItemChanceHolder.new(8633, 2, 5646), # Elixir of Mind (S-grade)
      ItemChanceHolder.new(8639, 5, 6323), # Elixir of CP (S-grade)
      ItemChanceHolder.new(8638, 6, 6323), # Elixir of CP (A-grade)
      ItemChanceHolder.new(8632, 2, 6587), # Elixir of Mind (A-grade)
      ItemChanceHolder.new(8626, 3, 5059), # Elixir of Life (A-grade)
      ItemChanceHolder.new(729, 1, 106), # Scroll: Enchant Weapon (A-grade)
      ItemChanceHolder.new(730, 1, 791), # Scroll: Enchant Armor (A-grade)
      ItemChanceHolder.new(1540, 4, 4742), # Quick Healing Potion
      ItemChanceHolder.new(10260, 3, 2134), # Haste Potion
      ItemChanceHolder.new(10261, 3, 2134), # Accuracy Juice
      ItemChanceHolder.new(10262, 3, 2134), # Critical Damage Juice
      ItemChanceHolder.new(10263, 3, 2134), # Critical Rate Juice
      ItemChanceHolder.new(10264, 3, 2134), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 3, 2134), # Evasion Juice
      ItemChanceHolder.new(10266, 3, 2134), # M. Atk. Juice
      ItemChanceHolder.new(10267, 3, 2134), # P. Atk. Potion
      ItemChanceHolder.new(10268, 3, 2134), # Wind Walk Juice
      ItemChanceHolder.new(5595, 1, 801), # SP Scroll (High-grade)
      ItemChanceHolder.new(9898, 1, 801), # SP Scroll (Top-grade)
      ItemChanceHolder.new(10269, 3, 2134), # P. Def. Juice
      ItemChanceHolder.new(8739, 1, 5335), # Mid-grade Life Stone - Lv. 64
      ItemChanceHolder.new(8740, 1, 4446), # Mid-grade Life Stone - Lv. 67
      ItemChanceHolder.new(8741, 1, 3705), # Mid-grade Life Stone - Lv. 70
      ItemChanceHolder.new(8742, 1, 3335), # Mid-grade Life Stone - Lv. 76
      ItemChanceHolder.new(21180, 1, 10088), # Transformation Scroll: Heretic - Event
      ItemChanceHolder.new(21181, 1, 8070), # Transformation Scroll: Veil Master - Event
      ItemChanceHolder.new(21182, 1, 8070), # Transformation Scroll: Saber Tooth Tiger - Event
      ItemChanceHolder.new(1538, 2, 6725), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 5044), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(9654, 1, 935), # Transformation Sealbook: Inferno Drake
      ItemChanceHolder.new(9655, 1, 935), # Transformation Sealbook: Dragon Bomber
      ItemChanceHolder.new(5580, 1, 202), # Red Soul Crystal - Stage 12
      ItemChanceHolder.new(5581, 1, 202), # Green Soul Crystal - Stage 12
      ItemChanceHolder.new(5582, 1, 202), # Blue Soul Crystal - Stage 12
      ItemChanceHolder.new(80, 1, 144), # Tallum Blade
      ItemChanceHolder.new(21748, 1, 141)  # Experienced Adventurer's Treasure Sack
    ],
    18281 => [ # Treasure Chest
      ItemChanceHolder.new(8627, 2, 6967), # Elixir of Life (S-grade)
      ItemChanceHolder.new(8633, 2, 6220), # Elixir of Mind (S-grade)
      ItemChanceHolder.new(8639, 5, 6967), # Elixir of CP (S-grade)
      ItemChanceHolder.new(8638, 6, 6967), # Elixir of CP (A-grade)
      ItemChanceHolder.new(8632, 2, 7257), # Elixir of Mind (A-grade)
      ItemChanceHolder.new(8626, 3, 5573), # Elixir of Life (A-grade)
      ItemChanceHolder.new(729, 1, 117), # Scroll: Enchant Weapon (A-grade)
      ItemChanceHolder.new(730, 1, 871), # Scroll: Enchant Armor (A-grade)
      ItemChanceHolder.new(1540, 4, 5225), # Quick Healing Potion
      ItemChanceHolder.new(10260, 3, 2352), # Haste Potion
      ItemChanceHolder.new(10261, 3, 2352), # Accuracy Juice
      ItemChanceHolder.new(10262, 3, 2352), # Critical Damage Juice
      ItemChanceHolder.new(10263, 3, 2352), # Critical Rate Juice
      ItemChanceHolder.new(10264, 3, 2352), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 3, 2352), # Evasion Juice
      ItemChanceHolder.new(10266, 3, 2352), # M. Atk. Juice
      ItemChanceHolder.new(10267, 3, 2352), # P. Atk. Potion
      ItemChanceHolder.new(10268, 3, 2352), # Wind Walk Juice
      ItemChanceHolder.new(5595, 1, 882), # SP Scroll (High-grade)
      ItemChanceHolder.new(9898, 1, 882), # SP Scroll (Top-grade)
      ItemChanceHolder.new(10269, 3, 2352), # P. Def. Juice
      ItemChanceHolder.new(8739, 1, 5878), # Mid-grade Life Stone - Lv. 64
      ItemChanceHolder.new(8740, 1, 4899), # Mid-grade Life Stone - Lv. 67
      ItemChanceHolder.new(8741, 1, 4082), # Mid-grade Life Stone - Lv. 70
      ItemChanceHolder.new(8742, 1, 3674), # Mid-grade Life Stone - Lv. 76
      ItemChanceHolder.new(21183, 1, 7410), # Transformation Scroll: Oel Mahum - Event
      ItemChanceHolder.new(21184, 1, 7410), # Transformation Scroll: Doll Blader - Event
      ItemChanceHolder.new(21185, 1, 3705), # Transformation Scroll: Zaken - Event
      ItemChanceHolder.new(1538, 2, 7410), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 5558), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(9654, 1, 1030), # Transformation Sealbook: Inferno Drake
      ItemChanceHolder.new(9655, 1, 1030), # Transformation Sealbook: Dragon Bomber
      ItemChanceHolder.new(5908, 1, 112), # Red Soul Crystal: Stage 13
      ItemChanceHolder.new(5911, 1, 112), # Green Soul Crystal - Stage 13
      ItemChanceHolder.new(5914, 1, 112), # Blue Soul Crystal: Stage 13
      ItemChanceHolder.new(6364, 1, 52), # Forgotten Blade
      ItemChanceHolder.new(21748, 1, 156)  # Experienced Adventurer's Treasure Sack
    ],
    18282 => [ # Treasure Chest
      ItemChanceHolder.new(8627, 2, 7649), # Elixir of Life (S-grade)
      ItemChanceHolder.new(8633, 2, 6829), # Elixir of Mind (S-grade)
      ItemChanceHolder.new(8639, 5, 7649), # Elixir of CP (S-grade)
      ItemChanceHolder.new(8638, 6, 7649), # Elixir of CP (A-grade)
      ItemChanceHolder.new(8632, 2, 7968), # Elixir of Mind (A-grade)
      ItemChanceHolder.new(8626, 3, 6119), # Elixir of Life (A-grade)
      ItemChanceHolder.new(729, 1, 128), # Scroll: Enchant Weapon (A-grade)
      ItemChanceHolder.new(730, 1, 957), # Scroll: Enchant Armor (A-grade)
      ItemChanceHolder.new(1540, 4, 5737), # Quick Healing Potion
      ItemChanceHolder.new(10260, 3, 2582), # Haste Potion
      ItemChanceHolder.new(10261, 3, 2582), # Accuracy Juice
      ItemChanceHolder.new(10262, 3, 2582), # Critical Damage Juice
      ItemChanceHolder.new(10263, 3, 2582), # Critical Rate Juice
      ItemChanceHolder.new(10264, 3, 2582), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 3, 2582), # Evasion Juice
      ItemChanceHolder.new(10266, 3, 2582), # M. Atk. Juice
      ItemChanceHolder.new(10267, 3, 2582), # P. Atk. Potion
      ItemChanceHolder.new(10268, 3, 2582), # Wind Walk Juice
      ItemChanceHolder.new(5595, 1, 968), # SP Scroll (High-grade)
      ItemChanceHolder.new(9898, 1, 968), # SP Scroll (Top-grade)
      ItemChanceHolder.new(10269, 3, 2582), # P. Def. Juice
      ItemChanceHolder.new(8739, 1, 6454), # Mid-grade Life Stone - Lv. 64
      ItemChanceHolder.new(8740, 1, 5378), # Mid-grade Life Stone - Lv. 67
      ItemChanceHolder.new(8741, 1, 4482), # Mid-grade Life Stone - Lv. 70
      ItemChanceHolder.new(8742, 1, 4034), # Mid-grade Life Stone - Lv. 76
      ItemChanceHolder.new(21183, 1, 8136), # Transformation Scroll: Oel Mahum - Event
      ItemChanceHolder.new(21184, 1, 8136), # Transformation Scroll: Doll Blader - Event
      ItemChanceHolder.new(21185, 1, 4068), # Transformation Scroll: Zaken - Event
      ItemChanceHolder.new(1538, 2, 8136), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 6102), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(9654, 1, 1130), # Transformation Sealbook: Inferno Drake
      ItemChanceHolder.new(9655, 1, 1130), # Transformation Sealbook: Dragon Bomber
      ItemChanceHolder.new(5908, 1, 123), # Red Soul Crystal: Stage 13
      ItemChanceHolder.new(5911, 1, 123), # Green Soul Crystal - Stage 13
      ItemChanceHolder.new(5914, 1, 123), # Blue Soul Crystal: Stage 13
      ItemChanceHolder.new(6364, 1, 58), # Forgotten Blade
      ItemChanceHolder.new(21748, 1, 171)  # Experienced Adventurer's Treasure Sack
    ],
    18283 => [ # Treasure Chest
      ItemChanceHolder.new(8627, 2, 8366), # Elixir of Life (S-grade)
      ItemChanceHolder.new(8633, 2, 7470), # Elixir of Mind (S-grade)
      ItemChanceHolder.new(8639, 5, 8366), # Elixir of CP (S-grade)
      ItemChanceHolder.new(8638, 6, 8366), # Elixir of CP (A-grade)
      ItemChanceHolder.new(8632, 2, 8715), # Elixir of Mind (A-grade)
      ItemChanceHolder.new(8626, 3, 6693), # Elixir of Life (A-grade)
      ItemChanceHolder.new(729, 1, 140), # Scroll: Enchant Weapon (A-grade)
      ItemChanceHolder.new(730, 1, 1046), # Scroll: Enchant Armor (A-grade)
      ItemChanceHolder.new(1540, 4, 6275), # Quick Healing Potion
      ItemChanceHolder.new(10260, 3, 2824), # Haste Potion
      ItemChanceHolder.new(10261, 3, 2824), # Accuracy Juice
      ItemChanceHolder.new(10262, 3, 2824), # Critical Damage Juice
      ItemChanceHolder.new(10263, 3, 2824), # Critical Rate Juice
      ItemChanceHolder.new(10264, 3, 2824), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 3, 2824), # Evasion Juice
      ItemChanceHolder.new(10266, 3, 2824), # M. Atk. Juice
      ItemChanceHolder.new(10267, 3, 2824), # P. Atk. Potion
      ItemChanceHolder.new(10268, 3, 2824), # Wind Walk Juice
      ItemChanceHolder.new(5595, 1, 1059), # SP Scroll (High-grade)
      ItemChanceHolder.new(9898, 1, 1059), # SP Scroll (Top-grade)
      ItemChanceHolder.new(10269, 3, 2824), # P. Def. Juice
      ItemChanceHolder.new(8739, 1, 7059), # Mid-grade Life Stone - Lv. 64
      ItemChanceHolder.new(8740, 1, 5883), # Mid-grade Life Stone - Lv. 67
      ItemChanceHolder.new(8741, 1, 4902), # Mid-grade Life Stone - Lv. 70
      ItemChanceHolder.new(8742, 1, 4412), # Mid-grade Life Stone - Lv. 76
      ItemChanceHolder.new(21183, 1, 8898), # Transformation Scroll: Oel Mahum - Event
      ItemChanceHolder.new(21184, 1, 8898), # Transformation Scroll: Doll Blader - Event
      ItemChanceHolder.new(21185, 1, 4449), # Transformation Scroll: Zaken - Event
      ItemChanceHolder.new(1538, 2, 8898), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 6674), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(9654, 1, 1236), # Transformation Sealbook: Inferno Drake
      ItemChanceHolder.new(9655, 1, 1236), # Transformation Sealbook: Dragon Bomber
      ItemChanceHolder.new(5908, 1, 134), # Red Soul Crystal: Stage 13
      ItemChanceHolder.new(5911, 1, 134), # Green Soul Crystal - Stage 13
      ItemChanceHolder.new(5914, 1, 134), # Blue Soul Crystal: Stage 13
      ItemChanceHolder.new(6364, 1, 63), # Forgotten Blade
      ItemChanceHolder.new(21748, 1, 187)  # Experienced Adventurer's Treasure Sack
    ],
    18284 => [ # Treasure Chest
      ItemChanceHolder.new(8627, 2, 6836), # Elixir of Life (S-grade)
      ItemChanceHolder.new(8633, 2, 6103), # Elixir of Mind (S-grade)
      ItemChanceHolder.new(8639, 4, 10000), # Elixir of CP (S-grade)
      ItemChanceHolder.new(9546, 1, 821), # Fire Stone
      ItemChanceHolder.new(9547, 1, 821), # Water Stone
      ItemChanceHolder.new(9548, 1, 821), # Earth Stone
      ItemChanceHolder.new(9549, 1, 821), # Wind Stone
      ItemChanceHolder.new(9550, 1, 821), # Dark Stone
      ItemChanceHolder.new(9551, 1, 821), # Holy Stone
      ItemChanceHolder.new(959, 1, 42), # Scroll: Enchant Weapon (S-grade)
      ItemChanceHolder.new(960, 1, 411), # Scroll: Enchant Armor (S-grade)
      ItemChanceHolder.new(14701, 2, 2051), # Superior Quick Healing Potion
      ItemChanceHolder.new(10260, 3, 3076), # Haste Potion
      ItemChanceHolder.new(10261, 3, 3076), # Accuracy Juice
      ItemChanceHolder.new(10262, 3, 3076), # Critical Damage Juice
      ItemChanceHolder.new(10263, 3, 3076), # Critical Rate Juice
      ItemChanceHolder.new(10264, 3, 3076), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 3, 3076), # Evasion Juice
      ItemChanceHolder.new(10266, 3, 3076), # M. Atk. Juice
      ItemChanceHolder.new(10267, 3, 3076), # P. Atk. Potion
      ItemChanceHolder.new(10268, 3, 3076), # Wind Walk Juice
      ItemChanceHolder.new(5595, 2, 577), # SP Scroll (High-grade)
      ItemChanceHolder.new(9898, 1, 231), # SP Scroll (Top-grade)
      ItemChanceHolder.new(17185, 1, 116), # Scroll: 10,000 SP
      ItemChanceHolder.new(10269, 3, 3076), # P. Def. Juice
      ItemChanceHolder.new(9574, 1, 4006), # Mid-grade Life Stone - Lv. 80
      ItemChanceHolder.new(10484, 1, 3338), # Mid-grade Life Stone - Lv. 82
      ItemChanceHolder.new(14167, 1, 2783), # Mid-grade Life Stone - Lv. 84
      ItemChanceHolder.new(21185, 1, 2539), # Transformation Scroll: Zaken - Event
      ItemChanceHolder.new(21186, 1, 1524), # Transformation Scroll: Anakim - Event
      ItemChanceHolder.new(21187, 1, 2177), # Transformation Scroll: Venom - Event
      ItemChanceHolder.new(21188, 1, 2177), # Transformation Scroll: Gordon - Event
      ItemChanceHolder.new(21189, 1, 2177), # Transformation Scroll: Ranku - Event
      ItemChanceHolder.new(21190, 1, 2177), # Transformation Scroll: Kechi - Event
      ItemChanceHolder.new(21191, 1, 2177), # Transformation Scroll: Demon Prince - Event
      ItemChanceHolder.new(9552, 1, 191), # Fire Crystal
      ItemChanceHolder.new(9553, 1, 191), # Water Crystal
      ItemChanceHolder.new(9554, 1, 191), # Earth Crystal
      ItemChanceHolder.new(9555, 1, 191), # Wind Crystal
      ItemChanceHolder.new(9556, 1, 191), # Dark Crystal
      ItemChanceHolder.new(9557, 1, 191), # Holy Crystal
      ItemChanceHolder.new(6622, 1, 3047), # Lesser Giant's Codex
      ItemChanceHolder.new(9627, 1, 191), # Lesser Giant's Codex - Mastery
      ItemChanceHolder.new(1538, 2, 5078), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 3809), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(9570, 1, 39), # Red Soul Crystal - Stage 14
      ItemChanceHolder.new(9572, 1, 39), # Green Soul Crystal - Stage 14
      ItemChanceHolder.new(9571, 1, 39), # Blue Soul Crystal - Stage 14
      ItemChanceHolder.new(9442, 1, 21), # Dynasty Sword
      ItemChanceHolder.new(21749, 1, 25)  # Great Adventurer's Treasure Sack
    ],
    18285 => [ # Treasure Chest
      ItemChanceHolder.new(8627, 2, 7420), # Elixir of Life (S-grade)
      ItemChanceHolder.new(8633, 2, 6625), # Elixir of Mind (S-grade)
      ItemChanceHolder.new(8639, 4, 10000), # Elixir of CP (S-grade)
      ItemChanceHolder.new(9546, 1, 891), # Fire Stone
      ItemChanceHolder.new(9547, 1, 891), # Water Stone
      ItemChanceHolder.new(9548, 1, 891), # Earth Stone
      ItemChanceHolder.new(9549, 1, 891), # Wind Stone
      ItemChanceHolder.new(9550, 1, 891), # Dark Stone
      ItemChanceHolder.new(9551, 1, 891), # Holy Stone
      ItemChanceHolder.new(959, 1, 45), # Scroll: Enchant Weapon (S-grade)
      ItemChanceHolder.new(960, 1, 446), # Scroll: Enchant Armor (S-grade)
      ItemChanceHolder.new(14701, 2, 2226), # Superior Quick Healing Potion
      ItemChanceHolder.new(10260, 3, 3339), # Haste Potion
      ItemChanceHolder.new(10261, 3, 3339), # Accuracy Juice
      ItemChanceHolder.new(10262, 3, 3339), # Critical Damage Juice
      ItemChanceHolder.new(10263, 3, 3339), # Critical Rate Juice
      ItemChanceHolder.new(10264, 3, 3339), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 3, 3339), # Evasion Juice
      ItemChanceHolder.new(10266, 3, 3339), # M. Atk. Juice
      ItemChanceHolder.new(10267, 3, 3339), # P. Atk. Potion
      ItemChanceHolder.new(10268, 3, 3339), # Wind Walk Juice
      ItemChanceHolder.new(5595, 2, 627), # SP Scroll (High-grade)
      ItemChanceHolder.new(9898, 1, 251), # SP Scroll (Top-grade)
      ItemChanceHolder.new(17185, 1, 126), # Scroll: 10,000 SP
      ItemChanceHolder.new(10269, 3, 3339), # P. Def. Juice
      ItemChanceHolder.new(9574, 1, 4348), # Mid-grade Life Stone - Lv. 80
      ItemChanceHolder.new(10484, 1, 3623), # Mid-grade Life Stone - Lv. 82
      ItemChanceHolder.new(14167, 1, 3021), # Mid-grade Life Stone - Lv. 84
      ItemChanceHolder.new(21185, 1, 2756), # Transformation Scroll: Zaken - Event
      ItemChanceHolder.new(21186, 1, 1654), # Transformation Scroll: Anakim - Event
      ItemChanceHolder.new(21187, 1, 2363), # Transformation Scroll: Venom - Event
      ItemChanceHolder.new(21188, 1, 2363), # Transformation Scroll: Gordon - Event
      ItemChanceHolder.new(21189, 1, 2363), # Transformation Scroll: Ranku - Event
      ItemChanceHolder.new(21190, 1, 2363), # Transformation Scroll: Kechi - Event
      ItemChanceHolder.new(21191, 1, 2363), # Transformation Scroll: Demon Prince - Event
      ItemChanceHolder.new(9552, 1, 207), # Fire Crystal
      ItemChanceHolder.new(9553, 1, 207), # Water Crystal
      ItemChanceHolder.new(9554, 1, 207), # Earth Crystal
      ItemChanceHolder.new(9555, 1, 207), # Wind Crystal
      ItemChanceHolder.new(9556, 1, 207), # Dark Crystal
      ItemChanceHolder.new(9557, 1, 207), # Holy Crystal
      ItemChanceHolder.new(6622, 1, 3308), # Lesser Giant's Codex
      ItemChanceHolder.new(9627, 1, 207), # Lesser Giant's Codex - Mastery
      ItemChanceHolder.new(1538, 2, 5512), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 4134), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(10480, 1, 21), # Red Soul Crystal - Stage 15
      ItemChanceHolder.new(10482, 1, 21), # Green Soul Crystal - Stage 15
      ItemChanceHolder.new(10481, 1, 21), # Blue Soul Crystal - Stage 15
      ItemChanceHolder.new(10215, 1, 16), # Icarus Sawsword
      ItemChanceHolder.new(21749, 1, 27)  # Great Adventurer's Treasure Sack
    ],
    18286 => [ # Treasure Chest
      ItemChanceHolder.new(8627, 2, 8005), # Elixir of Life (S-grade)
      ItemChanceHolder.new(8633, 2, 7147), # Elixir of Mind (S-grade)
      ItemChanceHolder.new(8639, 4, 10000), # Elixir of CP (S-grade)
      ItemChanceHolder.new(9546, 1, 961), # Fire Stone
      ItemChanceHolder.new(9547, 1, 961), # Water Stone
      ItemChanceHolder.new(9548, 1, 961), # Earth Stone
      ItemChanceHolder.new(9549, 1, 961), # Wind Stone
      ItemChanceHolder.new(9550, 1, 961), # Dark Stone
      ItemChanceHolder.new(9551, 1, 961), # Holy Stone
      ItemChanceHolder.new(959, 1, 49), # Scroll: Enchant Weapon (S-grade)
      ItemChanceHolder.new(960, 1, 481), # Scroll: Enchant Armor (S-grade)
      ItemChanceHolder.new(14701, 2, 2402), # Superior Quick Healing Potion
      ItemChanceHolder.new(10260, 3, 3602), # Haste Potion
      ItemChanceHolder.new(10261, 3, 3602), # Accuracy Juice
      ItemChanceHolder.new(10262, 3, 3602), # Critical Damage Juice
      ItemChanceHolder.new(10263, 3, 3602), # Critical Rate Juice
      ItemChanceHolder.new(10264, 3, 3602), # Casting Spd. Juice
      ItemChanceHolder.new(10265, 3, 3602), # Evasion Juice
      ItemChanceHolder.new(10266, 3, 3602), # M. Atk. Juice
      ItemChanceHolder.new(10267, 3, 3602), # P. Atk. Potion
      ItemChanceHolder.new(10268, 3, 3602), # Wind Walk Juice
      ItemChanceHolder.new(5595, 2, 676), # SP Scroll (High-grade)
      ItemChanceHolder.new(9898, 1, 271), # SP Scroll (Top-grade)
      ItemChanceHolder.new(17185, 1, 136), # Scroll: 10,000 SP
      ItemChanceHolder.new(10269, 3, 3602), # P. Def. Juice
      ItemChanceHolder.new(9574, 1, 4690), # Mid-grade Life Stone - Lv. 80
      ItemChanceHolder.new(10484, 1, 3909), # Mid-grade Life Stone - Lv. 82
      ItemChanceHolder.new(14167, 1, 3259), # Mid-grade Life Stone - Lv. 84
      ItemChanceHolder.new(21185, 1, 2973), # Transformation Scroll: Zaken - Event
      ItemChanceHolder.new(21186, 1, 1784), # Transformation Scroll: Anakim - Event
      ItemChanceHolder.new(21187, 1, 2549), # Transformation Scroll: Venom - Event
      ItemChanceHolder.new(21188, 1, 2549), # Transformation Scroll: Gordon - Event
      ItemChanceHolder.new(21189, 1, 2549), # Transformation Scroll: Ranku - Event
      ItemChanceHolder.new(21190, 1, 2549), # Transformation Scroll: Kechi - Event
      ItemChanceHolder.new(21191, 1, 2549), # Transformation Scroll: Demon Prince - Event
      ItemChanceHolder.new(9552, 1, 223), # Fire Crystal
      ItemChanceHolder.new(9553, 1, 223), # Water Crystal
      ItemChanceHolder.new(9554, 1, 223), # Earth Crystal
      ItemChanceHolder.new(9555, 1, 223), # Wind Crystal
      ItemChanceHolder.new(9556, 1, 223), # Dark Crystal
      ItemChanceHolder.new(9557, 1, 223), # Holy Crystal
      ItemChanceHolder.new(6622, 1, 3568), # Lesser Giant's Codex
      ItemChanceHolder.new(9627, 1, 223), # Lesser Giant's Codex - Mastery
      ItemChanceHolder.new(1538, 2, 5946), # Blessed Scroll of Escape
      ItemChanceHolder.new(3936, 1, 4460), # Blessed Scroll of Resurrection
      ItemChanceHolder.new(13071, 1, 12), # Red Soul Crystal - Stage 16
      ItemChanceHolder.new(13073, 1, 12), # Green Soul Crystal - Stage 16
      ItemChanceHolder.new(13072, 1, 12), # Blue Soul Crystal - Stage 16
      ItemChanceHolder.new(13457, 1, 13), # Vesper Cutter
      ItemChanceHolder.new(21749, 1, 29)  # Great Adventurer's Treasure Sack
    ]
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_spawn_id(DROPS.keys)
    add_attack_id(DROPS.keys)
  end

  def on_adv_event(event, npc, pc)
    if event == TIMER_1 || event == TIMER_2
      npc.not_nil!.delete_me
    end

    super
  end

  def on_spawn(npc)
    npc.variables["MAESTRO_SKILL_USED"] = 0
    start_quest_timer(TIMER_2, MAX_SPAWN_TIME, npc, nil)

    super
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    if attacker.level < PLAYER_LEVEL_THRESHOLD
      npc.variables["MAX_LEVEL_DIFFERENCE"] = 6
    else
      npc.variables["MAX_LEVEL_DIFFERENCE"] = 5
    end

    if npc.variables.get_i32("MAESTRO_SKILL_USED") == 0
      if skill && skill.id == MAESTROS_KEY_SKILL_ID
        npc.variables["MAESTRO_SKILL_USED"] = 1
        start_quest_timer(TIMER_1, ATTACK_SPAWN_TIME, npc, nil)

        if npc.level &- npc.variables.get_i32("MAX_LEVEL_DIFFERENCE") > attacker.level
          add_skill_cast_desire(npc, attacker, TREASURE_BOMBS[npc.level // 10], 1_000_000)
        else
          if Rnd.rand(100) < 10
            npc.do_die(nil)
            if items = DROPS[npc.id]?
              items.each do |item|
                npc.drop_item(attacker, item.id, item.count)
              end
            else
              warn "Treasure Chest ID #{npc.id} doesn't have a drop list."
            end
          else
            add_skill_cast_desire(npc, attacker, TREASURE_BOMBS[npc.level // 10], 1_000_000)
          end
        end
      elsif Rnd.rand(100) < 30
        attacker.send_packet(SystemMessageId::IF_YOU_HAVE_A_MAESTROS_KEY_YOU_CAN_USE_IT_TO_OPEN_THE_TREASURE_CHEST)
      end
    end

    super
  end
end
