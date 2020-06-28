class Scripts::Q00335_TheSongOfTheHunter < Quest
  # NPCs
  private GREY = 30744
  private TOR = 30745
  private CYBELLIN = 30746
  # Monsters
  private BREKA_ORC_SHAMAN = 20269
  private BREKA_ORC_WARRIOR = 20271
  private GUARDIAN_BASILISK = 20550
  private FETTERED_SOUL = 20552
  private WINDSUS = 20553
  private GRANDIS = 20554
  private GIANT_FUNGUS = 20555
  private GIANT_MONSTEREYE = 20556
  private DIRE_WYRM = 20557
  private ROTTING_TREE = 20558
  private TRISALIM_SPIDER = 20560
  private TRISALIM_TARANTULA = 20561
  private SPORE_ZOMBIE = 20562
  private MANASHEN_GARGOYLE = 20563
  private ENCHANTED_STONE_GOLEM = 20565
  private ENCHANTED_GARGOYLE = 20567
  private TARLK_BUGBEAR_WARRIOR = 20571
  private LETO_LIZARDMAN_ARCHER = 20578
  private LETO_LIZARDMAN_SOLDIER = 20579
  private LETO_LIZARDMAN_SHAMAN = 20581
  private LETO_LIZARDMAN_OVERLORD = 20582
  private TIMAK_ORC_WARRIOR = 20586
  private TIMAK_ORC_OVERLORD = 20588
  private FLINE = 20589
  private LIELE = 20590
  private VALLEY_TREANT = 20591
  private SATYR = 20592
  private UNICORN = 20593
  private FOREST_RUNNER = 20594
  private VALLEY_TREANT_ELDER = 20597
  private SATYR_ELDER = 20598
  private UNICORN_ELDER = 20599
  private KARUL_BUGBEAR = 20600
  private TAMLIN_ORC = 20601
  private TAMLIN_ORC_ARCHER = 20602
  private KRONBE_SPIDER = 20603
  private TAIK_ORC_ARCHER = 20631
  private TAIK_ORC_WARRIOR = 20632
  private TAIK_ORC_SHAMAN = 20633
  private TAIK_ORC_CAPTAIN = 20634
  private MIRROR = 20639
  private HARIT_LIZARDMAN_GRUNT = 20641
  private HARIT_LIZARDMAN_ARCHER = 20642
  private HARIT_LIZARDMAN_WARRIOR = 20643
  private GRAVE_WANDERER = 20659
  private ARCHER_OF_GREED = 20660
  private HATAR_RATMAN_THIEF = 20661
  private HATAR_RATMAN_BOSS = 20662
  private DEPRIVE = 20664
  private FARCRAN = 20667
  private TAIRIM = 20675
  private JUDGE_OF_MARSH = 20676
  private VANOR_SILENOS_GRUNT = 20682
  private VANOR_SILENOS_SCOUT = 20683
  private VANOR_SILENOS_WARRIOR = 20684
  private VANOR_SILENOS_CHIEFTAIN = 20686
  private BREKA_OVERLORD_HAKA = 27140
  private BREKA_OVERLORD_JAKA = 27141
  private BREKA_OVERLORD_MARKA = 27142
  private WINDSUS_ALEPH = 27143
  private TARLK_RAIDER_ATHU = 27144
  private TARLK_RAIDER_LANKA = 27145
  private TARLK_RAIDER_TRISKA = 27146
  private TARLK_RAIDER_MOTURA = 27147
  private TARLK_RAIDER_KALATH = 27148
  private GREMLIN_FILCHER = 27149
  private BLACK_LEGION_STORMTROOPER = 27150
  private LETO_SHAMAN_KETZ = 27156
  private LETO_CHIEF_NARAK = 27157
  private TIMAK_RAIDER_KAIKEE = 27158
  private TIMAK_OVERLORD_OKUN = 27159
  private GOK_MAGOK = 27160
  private TAIK_OVERLORD_KAKRAN = 27161
  private HATAR_CHIEFTAIN_KUBEL = 27162
  private VANOR_ELDER_KERUNOS = 27163
  private KARUL_CHIEF_OROOTO = 27164
  # Misc
  private MIN_LEVEL = 35
  private MAX_LEVEL = 45
  private CYBELLINS_DAGGER = 3471
  private FIRST_CIRCLE_HUNTER_LICENSE = 3692
  private SECOND_CIRCLE_HUNTER_LICENSE = 3693
  private LAUREL_LEAF_PIN = 3694
  private TEST_INSTRUCTIONS_1 = 3695
  private TEST_INSTRUCTIONS_2 = 3696
  private CYBELLINS_REQUEST = 3697
  private BLOOD_CRYSTAL_PURITY_1 = 3698
  private BLOOD_CRYSTAL_PURITY_2 = 3699
  private BLOOD_CRYSTAL_PURITY_3 = 3700
  private BLOOD_CRYSTAL_PURITY_4 = 3701
  private BLOOD_CRYSTAL_PURITY_5 = 3702
  private BLOOD_CRYSTAL_PURITY_6 = 3703
  private BLOOD_CRYSTAL_PURITY_7 = 3704
  private BLOOD_CRYSTAL_PURITY_8 = 3705
  private BLOOD_CRYSTAL_PURITY_9 = 3706
  private BLOOD_CRYSTAL_PURITY_10 = 3707
  private BROKEN_BLOOD_CRYSTAL = 3708
  private GUARDIAN_BASILISK_SCALE = 3709
  private KARUT_WEED = 3710
  private HAKAS_HEAD = 3711
  private JAKAS_HEAD = 3712
  private MARKAS_HEAD = 3713
  private WINDSUS_ALEPH_SKIN = 3714
  private INDIGO_SPIRIT_ORE = 3715
  private SPORESEA_SEED = 3716
  private TIMAK_ORC_TOTEM = 3717
  private TRISALIM_SILK = 3718
  private AMBROSIUS_FRUIT = 3719
  private BALEFIRE_CRYSTAL = 3720
  private IMPERIAL_ARROWHEAD = 3721
  private ATHUS_HEAD = 3722
  private LANKAS_HEAD = 3723
  private TRISKAS_HEAD = 3724
  private MOTURAS_HEAD = 3725
  private KALATHS_HEAD = 3726
  private FIRST_CIRCLE_REQUEST_1C = 3727
  private FIRST_CIRCLE_REQUEST_2C = 3728
  private FIRST_CIRCLE_REQUEST_3C = 3729
  private FIRST_CIRCLE_REQUEST_4C = 3730
  private FIRST_CIRCLE_REQUEST_5C = 3731
  private FIRST_CIRCLE_REQUEST_6C = 3732
  private FIRST_CIRCLE_REQUEST_7C = 3733
  private FIRST_CIRCLE_REQUEST_8C = 3734
  private FIRST_CIRCLE_REQUEST_9C = 3735
  private FIRST_CIRCLE_REQUEST_10C = 3736
  private FIRST_CIRCLE_REQUEST_11C = 3737
  private FIRST_CIRCLE_REQUEST_12C = 3738
  private FIRST_CIRCLE_REQUEST_1B = 3739
  private FIRST_CIRCLE_REQUEST_2B = 3740
  private FIRST_CIRCLE_REQUEST_3B = 3741
  private FIRST_CIRCLE_REQUEST_4B = 3742
  private FIRST_CIRCLE_REQUEST_5B = 3743
  private FIRST_CIRCLE_REQUEST_6B = 3744
  private FIRST_CIRCLE_REQUEST_1A = 3745
  private FIRST_CIRCLE_REQUEST_2A = 3746
  private FIRST_CIRCLE_REQUEST_3A = 3747
  private SECOND_CIRCLE_REQUEST_1C = 3748
  private SECOND_CIRCLE_REQUEST_2C = 3749
  private SECOND_CIRCLE_REQUEST_3C = 3750
  private SECOND_CIRCLE_REQUEST_4C = 3751
  private SECOND_CIRCLE_REQUEST_5C = 3752
  private SECOND_CIRCLE_REQUEST_6C = 3753
  private SECOND_CIRCLE_REQUEST_7C = 3754
  private SECOND_CIRCLE_REQUEST_8C = 3755
  private SECOND_CIRCLE_REQUEST_9C = 3756
  private SECOND_CIRCLE_REQUEST_10C = 3757
  private SECOND_CIRCLE_REQUEST_11C = 3758
  private SECOND_CIRCLE_REQUEST_12C = 3759
  private SECOND_CIRCLE_REQUEST_1B = 3760
  private SECOND_CIRCLE_REQUEST_2B = 3761
  private SECOND_CIRCLE_REQUEST_3B = 3762
  private SECOND_CIRCLE_REQUEST_4B = 3763
  private SECOND_CIRCLE_REQUEST_5B = 3764
  private SECOND_CIRCLE_REQUEST_6B = 3765
  private SECOND_CIRCLE_REQUEST_1A = 3766
  private SECOND_CIRCLE_REQUEST_2A = 3767
  private SECOND_CIRCLE_REQUEST_3A = 3768
  private CHARM_OF_KADESH = 3769
  private TIMAK_JADE_NECKLACE = 3770
  private ENCHANTED_GOLEM_SHARD = 3771
  private GIANT_MONSTER_EYE_MEAT = 3772
  private DIRE_WYRM_EGG = 3773
  private GUARDIAN_BASILISK_TALON = 3774
  private REVENANTS_CHAINS = 3775
  private WINDSUS_TUSK = 3776
  private GRANDISS_SKULL = 3777
  private TAIK_OBSIDIAN_AMULET = 3778
  private KARUL_BUGBEAR_HEAD = 3779
  private TAMLIN_IVORY_CHARM = 3780
  private FANG_OF_NARAK = 3781
  private ENCHANTED_GARGOYLES_HORN = 3782
  private COILED_SERPENT_TOTEM = 3783
  private TOTEM_OF_KADESH = 3784
  private KAIKIS_HEAD = 3785
  private KRONBE_VENOM_SAC = 3786
  private EVAS_CHARM = 3787
  private TITANS_TABLET = 3788
  private BOOK_OF_SHUNAIMAN = 3789
  private ROTTING_TREE_SPORES = 3790
  private TRISALIM_VENOM_SAC = 3791
  private TAIK_ORC_TOTEM = 3792
  private HARIT_BARBED_NECKLACE = 3793
  private COIN_OF_OLD_EMPIRE = 3794
  private SKIN_OF_FARCRAN = 3795
  private TEMPEST_SHARD = 3796
  private TSUNAMI_SHARD = 3797
  private SATYR_MANE = 3798
  private HAMADRYAD_SHARD = 3799
  private VANOR_SILENOS_MANE = 3800
  private TALK_BUGBEAR_TOTEM = 3801
  private OKUNS_HEAD = 3802
  private KAKRANS_HEAD = 3803
  private NARCISSUSS_SOULSTONE = 3804
  private DEPRIVE_EYE = 3805
  private UNICORNS_HORN = 3806
  private KERUNOSS_GOLD_MANE = 3807
  private SKULL_OF_EXECUTED = 3808
  private BUST_OF_TRAVIS = 3809
  private SWORD_OF_CADMUS = 3810

  # Rewards
  private REWARDS = {
    {FIRST_CIRCLE_REQUEST_1C, CHARM_OF_KADESH, 40, 2090},
    {FIRST_CIRCLE_REQUEST_3C, ENCHANTED_GOLEM_SHARD, 50, 9480},
    {FIRST_CIRCLE_REQUEST_4C, GIANT_MONSTER_EYE_MEAT, 30, 9110},
    {FIRST_CIRCLE_REQUEST_5C, DIRE_WYRM_EGG, 40, 8690},
    {FIRST_CIRCLE_REQUEST_6C, GUARDIAN_BASILISK_TALON, 100, 9480},
    {FIRST_CIRCLE_REQUEST_7C, REVENANTS_CHAINS, 50, 11280},
    {FIRST_CIRCLE_REQUEST_8C, WINDSUS_TUSK, 30, 9640},
    {FIRST_CIRCLE_REQUEST_9C, GRANDISS_SKULL, 100, 9180},
    {FIRST_CIRCLE_REQUEST_10C, TAIK_OBSIDIAN_AMULET, 50, 5160},
    {FIRST_CIRCLE_REQUEST_11C, KARUL_BUGBEAR_HEAD, 30, 3140},
    {FIRST_CIRCLE_REQUEST_12C, TAMLIN_IVORY_CHARM, 40, 3160},
    {FIRST_CIRCLE_REQUEST_1B, FANG_OF_NARAK, 1, 6370},
    {FIRST_CIRCLE_REQUEST_2B, ENCHANTED_GARGOYLES_HORN, 50, 19080},
    {FIRST_CIRCLE_REQUEST_3B, COILED_SERPENT_TOTEM, 50, 19080},
    {FIRST_CIRCLE_REQUEST_4B, TOTEM_OF_KADESH, 1, 5790},
    {FIRST_CIRCLE_REQUEST_5B, KAIKIS_HEAD, 1, 8560},
    {FIRST_CIRCLE_REQUEST_6B, KRONBE_VENOM_SAC, 30, 8320},
    {FIRST_CIRCLE_REQUEST_1A, EVAS_CHARM, 30, 30310},
    {FIRST_CIRCLE_REQUEST_2A, TITANS_TABLET, 1, 27540},
    {FIRST_CIRCLE_REQUEST_3A, BOOK_OF_SHUNAIMAN, 1, 20560},
    {SECOND_CIRCLE_REQUEST_1C, ROTTING_TREE_SPORES, 40, 6850},
    {SECOND_CIRCLE_REQUEST_2C, TRISALIM_VENOM_SAC, 40, 7250},
    {SECOND_CIRCLE_REQUEST_3C, TAIK_ORC_TOTEM, 50, 7160},
    {SECOND_CIRCLE_REQUEST_4C, HARIT_BARBED_NECKLACE, 40, 6580},
    {SECOND_CIRCLE_REQUEST_5C, COIN_OF_OLD_EMPIRE, 20, 10100},
    {SECOND_CIRCLE_REQUEST_6C, SKIN_OF_FARCRAN, 30, 13000},
    {SECOND_CIRCLE_REQUEST_7C, TEMPEST_SHARD, 40, 7660},
    {SECOND_CIRCLE_REQUEST_8C, TSUNAMI_SHARD, 40, 7660},
    {SECOND_CIRCLE_REQUEST_9C, SATYR_MANE, 40, 11260},
    {SECOND_CIRCLE_REQUEST_10C, HAMADRYAD_SHARD, 40, 7660},
    {SECOND_CIRCLE_REQUEST_11C, VANOR_SILENOS_MANE, 30, 8810},
    {SECOND_CIRCLE_REQUEST_12C, TALK_BUGBEAR_TOTEM, 30, 7350},
    {SECOND_CIRCLE_REQUEST_1B, OKUNS_HEAD, 1, 8760},
    {SECOND_CIRCLE_REQUEST_2B, KAKRANS_HEAD, 1, 9380},
    {SECOND_CIRCLE_REQUEST_3B, NARCISSUSS_SOULSTONE, 40, 17820},
    {SECOND_CIRCLE_REQUEST_4B, DEPRIVE_EYE, 20, 17540},
    {SECOND_CIRCLE_REQUEST_5B, UNICORNS_HORN, 20, 14160},
    {SECOND_CIRCLE_REQUEST_6B, KERUNOSS_GOLD_MANE, 1, 15960},
    {SECOND_CIRCLE_REQUEST_1A, SKULL_OF_EXECUTED, 20, 39100},
    {SECOND_CIRCLE_REQUEST_2A, BUST_OF_TRAVIS, 1, 39550},
    {SECOND_CIRCLE_REQUEST_3A, SWORD_OF_CADMUS, 10, 41200}
  }

  # Monsters drop
  private DROPLIST = {
    {BREKA_ORC_SHAMAN, FIRST_CIRCLE_REQUEST_3B, COILED_SERPENT_TOTEM, 1, 50, 93},
    {BREKA_ORC_WARRIOR, FIRST_CIRCLE_REQUEST_3B, COILED_SERPENT_TOTEM, 1, 50, 100},
    {GUARDIAN_BASILISK, TEST_INSTRUCTIONS_1, GUARDIAN_BASILISK_SCALE, 1, 40, 90},
    {GUARDIAN_BASILISK, FIRST_CIRCLE_REQUEST_6C, GUARDIAN_BASILISK_TALON, Rnd.rand(100) < 60 ? 2 : 1, 100, 100},
    {FETTERED_SOUL, FIRST_CIRCLE_REQUEST_7C, REVENANTS_CHAINS, 1, 50, 100},
    {WINDSUS, FIRST_CIRCLE_REQUEST_8C, WINDSUS_TUSK, 1, 30, 63},
    {GRANDIS, FIRST_CIRCLE_REQUEST_9C, GRANDISS_SKULL, 2, 100, 100},
    {GIANT_FUNGUS, TEST_INSTRUCTIONS_1, SPORESEA_SEED, 1, 30, 84},
    {GIANT_MONSTEREYE, FIRST_CIRCLE_REQUEST_4C, GIANT_MONSTER_EYE_MEAT, 1, 30, 60},
    {DIRE_WYRM, FIRST_CIRCLE_REQUEST_5C, DIRE_WYRM_EGG, 1, 40, 90},
    {ROTTING_TREE, SECOND_CIRCLE_REQUEST_1C, ROTTING_TREE_SPORES, 1, 40, 77},
    {TRISALIM_SPIDER, TEST_INSTRUCTIONS_2, TRISALIM_SILK, 1, 20, 60},
    {TRISALIM_SPIDER, SECOND_CIRCLE_REQUEST_2C, TRISALIM_VENOM_SAC, 1, 40, 76},
    {TRISALIM_TARANTULA, TEST_INSTRUCTIONS_2, TRISALIM_SILK, 1, 20, 60},
    {TRISALIM_TARANTULA, SECOND_CIRCLE_REQUEST_2C, TRISALIM_VENOM_SAC, 1, 40, 85},
    {SPORE_ZOMBIE, SECOND_CIRCLE_REQUEST_2C, TRISALIM_VENOM_SAC, 1, 30, 60},
    {MANASHEN_GARGOYLE, TEST_INSTRUCTIONS_1, INDIGO_SPIRIT_ORE, 1, 20, 60},
    {ENCHANTED_STONE_GOLEM, FIRST_CIRCLE_REQUEST_3C, ENCHANTED_GOLEM_SHARD, 1, 50, 100},
    {ENCHANTED_STONE_GOLEM, TEST_INSTRUCTIONS_1, INDIGO_SPIRIT_ORE, 1, 20, 62},
    {ENCHANTED_GARGOYLE, FIRST_CIRCLE_REQUEST_2B, ENCHANTED_GARGOYLES_HORN, 1, 50, 60},
    {TARLK_BUGBEAR_WARRIOR, SECOND_CIRCLE_REQUEST_12C, TALK_BUGBEAR_TOTEM, 1, 30, 73},
    {LETO_LIZARDMAN_ARCHER, FIRST_CIRCLE_REQUEST_1C, CHARM_OF_KADESH, 1, 40, 90},
    {LETO_LIZARDMAN_SOLDIER, FIRST_CIRCLE_REQUEST_1C, CHARM_OF_KADESH, 1, 40, 93},
    {LETO_LIZARDMAN_SHAMAN, TEST_INSTRUCTIONS_1, KARUT_WEED, 1, 20, 60},
    {LETO_LIZARDMAN_OVERLORD, TEST_INSTRUCTIONS_1, KARUT_WEED, 1, 20, 60},
    {TIMAK_ORC_WARRIOR, FIRST_CIRCLE_REQUEST_2C, TIMAK_JADE_NECKLACE, 1, 50, 95},
    {TIMAK_ORC_WARRIOR, TEST_INSTRUCTIONS_2, TIMAK_ORC_TOTEM, 1, 20, 60},
    {TIMAK_ORC_OVERLORD, FIRST_CIRCLE_REQUEST_2C, TIMAK_JADE_NECKLACE, 1, 50, 100},
    {FLINE, SECOND_CIRCLE_REQUEST_7C, TEMPEST_SHARD, 1, 40, 59},
    {LIELE, SECOND_CIRCLE_REQUEST_8C, TSUNAMI_SHARD, 1, 40, 61},
    {VALLEY_TREANT, TEST_INSTRUCTIONS_2, AMBROSIUS_FRUIT, 1, 30, 85},
    {SATYR, SECOND_CIRCLE_REQUEST_9C, SATYR_MANE, 1, 40, 90},
    {UNICORN, SECOND_CIRCLE_REQUEST_5B, UNICORNS_HORN, 1, 20, 78},
    {FOREST_RUNNER, SECOND_CIRCLE_REQUEST_10C, HAMADRYAD_SHARD, 1, 40, 74},
    {VALLEY_TREANT_ELDER, TEST_INSTRUCTIONS_2, AMBROSIUS_FRUIT, 1, 30, 85},
    {SATYR_ELDER, SECOND_CIRCLE_REQUEST_9C, SATYR_MANE, 1, 40, 100},
    {UNICORN_ELDER, SECOND_CIRCLE_REQUEST_5B, UNICORNS_HORN, 1, 20, 96},
    {KARUL_BUGBEAR, FIRST_CIRCLE_REQUEST_11C, KARUL_BUGBEAR_HEAD, 1, 30, 60},
    {TAMLIN_ORC, FIRST_CIRCLE_REQUEST_12C, TAMLIN_IVORY_CHARM, 1, 40, 72},
    {TAMLIN_ORC_ARCHER, FIRST_CIRCLE_REQUEST_12C, TAMLIN_IVORY_CHARM, 1, 40, 90},
    {KRONBE_SPIDER, FIRST_CIRCLE_REQUEST_6B, KRONBE_VENOM_SAC, 1, 30, 60},
    {TAIK_ORC_ARCHER, FIRST_CIRCLE_REQUEST_10C, TAIK_OBSIDIAN_AMULET, 1, 50, 100},
    {TAIK_ORC_WARRIOR, FIRST_CIRCLE_REQUEST_10C, TAIK_OBSIDIAN_AMULET, 1, 50, 93},
    {TAIK_ORC_SHAMAN, SECOND_CIRCLE_REQUEST_3C, TAIK_ORC_TOTEM, 1, 50, 63},
    {TAIK_ORC_CAPTAIN, SECOND_CIRCLE_REQUEST_3C, TAIK_ORC_TOTEM, 1, 50, 99},
    {MIRROR, SECOND_CIRCLE_REQUEST_3B, NARCISSUSS_SOULSTONE, 1, 40, 96},
    {HARIT_LIZARDMAN_GRUNT, SECOND_CIRCLE_REQUEST_4C, HARIT_BARBED_NECKLACE, 1, 40, 98},
    {HARIT_LIZARDMAN_ARCHER, SECOND_CIRCLE_REQUEST_4C, HARIT_BARBED_NECKLACE, 1, 40, 98},
    {HARIT_LIZARDMAN_WARRIOR, SECOND_CIRCLE_REQUEST_4C, HARIT_BARBED_NECKLACE, 1, 40, 100},
    {GRAVE_WANDERER, SECOND_CIRCLE_REQUEST_1A, SKULL_OF_EXECUTED, 1, 20, 83},
    {ARCHER_OF_GREED, TEST_INSTRUCTIONS_2, IMPERIAL_ARROWHEAD, 1, 20, 60},
    {HATAR_RATMAN_THIEF, SECOND_CIRCLE_REQUEST_5C, COIN_OF_OLD_EMPIRE, 1, 20, 60},
    {HATAR_RATMAN_BOSS, SECOND_CIRCLE_REQUEST_5C, COIN_OF_OLD_EMPIRE, 1, 20, 62},
    {DEPRIVE, SECOND_CIRCLE_REQUEST_4B, DEPRIVE_EYE, 1, 20, 87},
    {FARCRAN, SECOND_CIRCLE_REQUEST_6C, SKIN_OF_FARCRAN, 1, 30, 100},
    {TAIRIM, TEST_INSTRUCTIONS_2, BALEFIRE_CRYSTAL, 1, 20, 60},
    {JUDGE_OF_MARSH, SECOND_CIRCLE_REQUEST_3A, SWORD_OF_CADMUS, 1, 10, 74},
    {VANOR_SILENOS_GRUNT, SECOND_CIRCLE_REQUEST_11C, VANOR_SILENOS_MANE, 1, 30, 80},
    {VANOR_SILENOS_SCOUT, SECOND_CIRCLE_REQUEST_11C, VANOR_SILENOS_MANE, 1, 30, 95},
    {VANOR_SILENOS_WARRIOR, SECOND_CIRCLE_REQUEST_11C, VANOR_SILENOS_MANE, 1, 30, 100},
    {BREKA_OVERLORD_HAKA, TEST_INSTRUCTIONS_1, HAKAS_HEAD, 1, 1, 100},
    {BREKA_OVERLORD_JAKA, TEST_INSTRUCTIONS_1, JAKAS_HEAD, 1, 1, 100},
    {BREKA_OVERLORD_MARKA, TEST_INSTRUCTIONS_1, MARKAS_HEAD, 1, 1, 100},
    {WINDSUS_ALEPH, TEST_INSTRUCTIONS_1, WINDSUS_ALEPH_SKIN, 1, 1, 100},
    {TARLK_RAIDER_ATHU, TEST_INSTRUCTIONS_2, ATHUS_HEAD, 1, 1, 100},
    {TARLK_RAIDER_LANKA, TEST_INSTRUCTIONS_2, LANKAS_HEAD, 1, 1, 100},
    {TARLK_RAIDER_TRISKA, TEST_INSTRUCTIONS_2, TRISKAS_HEAD, 1, 1, 100},
    {TARLK_RAIDER_MOTURA, TEST_INSTRUCTIONS_2, MOTURAS_HEAD, 1, 1, 100},
    {TARLK_RAIDER_KALATH, TEST_INSTRUCTIONS_2, KALATHS_HEAD, 1, 1, 100},
    {LETO_SHAMAN_KETZ, FIRST_CIRCLE_REQUEST_4B, TOTEM_OF_KADESH, 1, 1, 100},
    {LETO_CHIEF_NARAK, FIRST_CIRCLE_REQUEST_1B, FANG_OF_NARAK, 1, 1, 100},
    {TIMAK_RAIDER_KAIKEE, FIRST_CIRCLE_REQUEST_5B, KAIKIS_HEAD, 1, 1, 100},
    {TIMAK_OVERLORD_OKUN, SECOND_CIRCLE_REQUEST_1B, OKUNS_HEAD, 1, 1, 100},
    {GOK_MAGOK, FIRST_CIRCLE_REQUEST_2A, TITANS_TABLET, 1, 1, 100},
    {TAIK_OVERLORD_KAKRAN, SECOND_CIRCLE_REQUEST_2B, KAKRANS_HEAD, 1, 1, 100},
    {HATAR_CHIEFTAIN_KUBEL, SECOND_CIRCLE_REQUEST_2A, BUST_OF_TRAVIS, 1, 1, 100},
    {VANOR_ELDER_KERUNOS, SECOND_CIRCLE_REQUEST_6B, KERUNOSS_GOLD_MANE, 1, 1, 100},
    {KARUL_CHIEF_OROOTO, FIRST_CIRCLE_REQUEST_3A, BOOK_OF_SHUNAIMAN, 1, 1, 100}
  }

  # Links
  private LINKS = {
    33520 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10a.html\">C: 40 Totems of Kadesh</a><br>",
    33521 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10b.html\">C: 50 Jade Necklaces of Timak</a><br>",
    33522 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10c.html\">C: 50 Enchanted Golem Shards</a><br>",
    33523 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10d.html\">C: 30 Pieces Monster Eye Meat</a><br>",
    33524 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10e.html\">C: 40 Eggs of Dire Wyrm</a><br>",
    33525 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10f.html\">C: 100 Claws of Guardian Basilisk</a><br>",
    33526 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10g.html\">C: 50 Revenant Chains </a><br>",
    33527 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10h.html\">C: 30 Windsus Tusks</a><br>",
    33528 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10i.html\">C: 100 Skulls of Grandis</a><br>",
    33529 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10j.html\">C: 50 Taik Obsidian Amulets</a><br>",
    33530 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10k.html\">C: 30 Heads of Karul Bugbear</a><br>",
    33531 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-10l.html\">C: 40 Ivory Charms of Tamlin</a><br>",
    33532 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-11a.html\">B: Situation Preparation - Leto Chief</a><br>",
    33533 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-11b.html\">B: 50 Enchanted Gargoyle Horns</a><br>",
    33534 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-11c.html\">B: 50 Coiled Serpent Totems</a><br>",
    33535 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-11d.html\">B: Situation Preparation - Sorcerer Catch of Leto</a><br>",
    33536 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-11e.html\">B: Situation Preparation - Timak Raider Kaikee</a><br>",
    33537 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-11f.html\">B: 30 Kronbe Venom Sacs</a><br>",
    33538 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-12a.html\">A: 30 Charms of Eva</a><br>",
    33539 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-12b.html\">A: Titan's Tablet</a><br>",
    33540 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-12c.html\">A: Book of Shunaiman</a><br>",
    33541 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13a.html\">C: 40 Rotted Tree Spores</a><br>",
    33542 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13b.html\">C: 40 Trisalim Venom Sacs</a><br>",
    33543 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13c.html\">C: 50 Totems of Taik Orc</a><br>",
    33544 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13d.html\">C: 40 Harit Barbed Necklaces</a><br>",
    33545 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13e.html\">C: 20 Coins of Ancient Empire</a><br>",
    33546 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13f.html\">C: 30 Skins of Farkran</a><br>",
    33547 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13g.html\">C: 40 Tempest Shards</a><br>",
    33548 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13k.html\">C: 30 Vanor Silenos Manes</a><br>",
    33549 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13i.html\">C: 40 Manes of Pan Ruem</a><br>",
    33550 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13j.html\">C: hamadryad shards</a><br>",
    33551 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13k.html\">C: 30 Manes of Vanor Silenos</a><br>",
    33552 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-13l.html\">C: 30 Totems of Talk Bugbears</a><br>",
    33553 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-14a.html\">B: Situation Preparation - Overlord Okun of Timak</a><br>",
    33554 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-14b.html\">B: Situation Preparation - Overlord Kakran of Taik</a><br>",
    33555 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-14c.html\">B: 40 Narcissus Soulstones</a><br>",
    33556 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-14d.html\">B: 20 Eyes of Deprived</a><br>",
    33557 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-14e.html\">B: 20 Unicorn Horns</a><br>",
    33558 => "<a action=\"bypass -h Quest Q00335_TheSongOfTheHunter 30745-14f.html\">B: Kerunos's Gold Mane</a><br>"
  }

  def initialize
    super(335, self.class.simple_name, "The Song of the Hunter")

    add_start_npc(GREY)
    add_talk_id(GREY, TOR, CYBELLIN)
    add_kill_id(
      BREKA_ORC_SHAMAN, BREKA_ORC_WARRIOR, GUARDIAN_BASILISK, FETTERED_SOUL,
      WINDSUS, GRANDIS, GIANT_FUNGUS, GIANT_MONSTEREYE, DIRE_WYRM, ROTTING_TREE,
      TRISALIM_SPIDER, TRISALIM_TARANTULA, SPORE_ZOMBIE, MANASHEN_GARGOYLE,
      ENCHANTED_STONE_GOLEM, ENCHANTED_GARGOYLE, TARLK_BUGBEAR_WARRIOR,
      LETO_LIZARDMAN_ARCHER, LETO_LIZARDMAN_SOLDIER, LETO_LIZARDMAN_SHAMAN,
      LETO_LIZARDMAN_OVERLORD, TIMAK_ORC_WARRIOR, TIMAK_ORC_OVERLORD, FLINE,
      LIELE, VALLEY_TREANT, SATYR, UNICORN, FOREST_RUNNER, VALLEY_TREANT_ELDER,
      SATYR_ELDER, UNICORN_ELDER, KARUL_BUGBEAR, TAMLIN_ORC, TAMLIN_ORC_ARCHER,
      KRONBE_SPIDER, TAIK_ORC_ARCHER, TAIK_ORC_WARRIOR, TAIK_ORC_SHAMAN,
      TAIK_ORC_CAPTAIN, MIRROR, HARIT_LIZARDMAN_GRUNT, HARIT_LIZARDMAN_ARCHER,
      HARIT_LIZARDMAN_WARRIOR, GRAVE_WANDERER, ARCHER_OF_GREED,
      HATAR_RATMAN_THIEF, HATAR_RATMAN_BOSS, DEPRIVE, FARCRAN, TAIRIM,
      JUDGE_OF_MARSH, VANOR_SILENOS_GRUNT, VANOR_SILENOS_SCOUT,
      VANOR_SILENOS_WARRIOR, BREKA_OVERLORD_HAKA, BREKA_OVERLORD_JAKA,
      BREKA_OVERLORD_MARKA, WINDSUS_ALEPH, TARLK_RAIDER_ATHU,
      TARLK_RAIDER_LANKA, TARLK_RAIDER_TRISKA, TARLK_RAIDER_MOTURA,
      TARLK_RAIDER_KALATH, GREMLIN_FILCHER, LETO_SHAMAN_KETZ, LETO_CHIEF_NARAK,
      TIMAK_RAIDER_KAIKEE, TIMAK_OVERLORD_OKUN, GOK_MAGOK, TAIK_OVERLORD_KAKRAN,
      HATAR_CHIEFTAIN_KUBEL, VANOR_ELDER_KERUNOS, KARUL_CHIEF_OROOTO,
      VANOR_SILENOS_CHIEFTAIN
    )
    register_quest_items(
      CYBELLINS_DAGGER, FIRST_CIRCLE_HUNTER_LICENSE,
      SECOND_CIRCLE_HUNTER_LICENSE, LAUREL_LEAF_PIN, TEST_INSTRUCTIONS_1,
      TEST_INSTRUCTIONS_2, CYBELLINS_REQUEST, BLOOD_CRYSTAL_PURITY_1,
      BLOOD_CRYSTAL_PURITY_2, BLOOD_CRYSTAL_PURITY_3, BLOOD_CRYSTAL_PURITY_4,
      BLOOD_CRYSTAL_PURITY_5, BLOOD_CRYSTAL_PURITY_6, BLOOD_CRYSTAL_PURITY_7,
      BLOOD_CRYSTAL_PURITY_8, BLOOD_CRYSTAL_PURITY_9, BLOOD_CRYSTAL_PURITY_10,
      BROKEN_BLOOD_CRYSTAL, GUARDIAN_BASILISK_SCALE, KARUT_WEED, HAKAS_HEAD,
      JAKAS_HEAD, MARKAS_HEAD, WINDSUS_ALEPH_SKIN, INDIGO_SPIRIT_ORE,
      SPORESEA_SEED, TIMAK_ORC_TOTEM, TRISALIM_SILK, AMBROSIUS_FRUIT,
      BALEFIRE_CRYSTAL, IMPERIAL_ARROWHEAD, ATHUS_HEAD, LANKAS_HEAD,
      TRISKAS_HEAD, MOTURAS_HEAD, KALATHS_HEAD, FIRST_CIRCLE_REQUEST_1C,
      FIRST_CIRCLE_REQUEST_2C, FIRST_CIRCLE_REQUEST_3C, FIRST_CIRCLE_REQUEST_4C,
      FIRST_CIRCLE_REQUEST_5C, FIRST_CIRCLE_REQUEST_6C, FIRST_CIRCLE_REQUEST_7C,
      FIRST_CIRCLE_REQUEST_8C, FIRST_CIRCLE_REQUEST_9C, FIRST_CIRCLE_REQUEST_10C,
      FIRST_CIRCLE_REQUEST_11C, FIRST_CIRCLE_REQUEST_12C,
      FIRST_CIRCLE_REQUEST_1B, FIRST_CIRCLE_REQUEST_2B, FIRST_CIRCLE_REQUEST_3B,
      FIRST_CIRCLE_REQUEST_4B, FIRST_CIRCLE_REQUEST_5B, FIRST_CIRCLE_REQUEST_6B,
      FIRST_CIRCLE_REQUEST_1A, FIRST_CIRCLE_REQUEST_2A, FIRST_CIRCLE_REQUEST_3A,
      SECOND_CIRCLE_REQUEST_1C, SECOND_CIRCLE_REQUEST_2C,
      SECOND_CIRCLE_REQUEST_3C, SECOND_CIRCLE_REQUEST_4C,
      SECOND_CIRCLE_REQUEST_5C, SECOND_CIRCLE_REQUEST_6C,
      SECOND_CIRCLE_REQUEST_7C, SECOND_CIRCLE_REQUEST_8C,
      SECOND_CIRCLE_REQUEST_9C, SECOND_CIRCLE_REQUEST_10C,
      SECOND_CIRCLE_REQUEST_11C, SECOND_CIRCLE_REQUEST_12C,
      SECOND_CIRCLE_REQUEST_1B, SECOND_CIRCLE_REQUEST_2B,
      SECOND_CIRCLE_REQUEST_3B, SECOND_CIRCLE_REQUEST_4B,
      SECOND_CIRCLE_REQUEST_5B, SECOND_CIRCLE_REQUEST_6B,
      SECOND_CIRCLE_REQUEST_1A, SECOND_CIRCLE_REQUEST_2A,
      SECOND_CIRCLE_REQUEST_3A, CHARM_OF_KADESH, TIMAK_JADE_NECKLACE,
      ENCHANTED_GOLEM_SHARD, GIANT_MONSTER_EYE_MEAT, DIRE_WYRM_EGG,
      GUARDIAN_BASILISK_TALON, REVENANTS_CHAINS, WINDSUS_TUSK, GRANDISS_SKULL,
      TAIK_OBSIDIAN_AMULET, KARUL_BUGBEAR_HEAD, TAMLIN_IVORY_CHARM,
      FANG_OF_NARAK, ENCHANTED_GARGOYLES_HORN, COILED_SERPENT_TOTEM,
      TOTEM_OF_KADESH, KAIKIS_HEAD, KRONBE_VENOM_SAC, EVAS_CHARM, TITANS_TABLET,
      BOOK_OF_SHUNAIMAN, ROTTING_TREE_SPORES, TRISALIM_VENOM_SAC,
      TAIK_ORC_TOTEM, HARIT_BARBED_NECKLACE, COIN_OF_OLD_EMPIRE,
      SKIN_OF_FARCRAN, TEMPEST_SHARD, TSUNAMI_SHARD, SATYR_MANE,
      HAMADRYAD_SHARD, VANOR_SILENOS_MANE, TALK_BUGBEAR_TOTEM, OKUNS_HEAD,
      KAKRANS_HEAD, NARCISSUSS_SOULSTONE, DEPRIVE_EYE, UNICORNS_HORN,
      KERUNOSS_GOLD_MANE, SKULL_OF_EXECUTED, BUST_OF_TRAVIS, SWORD_OF_CADMUS
    )
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)

    if qs.created?
      html = player.level < MIN_LEVEL ? "30744-01.htm" : "30744-02.htm"
    elsif qs.started?
      case npc.id
      when GREY
        if has_quest_items?(player, TEST_INSTRUCTIONS_1)
          count = {
            get_quest_items_count(player, GUARDIAN_BASILISK_SCALE) >= 40,
            get_quest_items_count(player, KARUT_WEED) >= 20,
            get_quest_items_count(player, HAKAS_HEAD) + get_quest_items_count(player, JAKAS_HEAD) + get_quest_items_count(player, MARKAS_HEAD) >= 3,
            has_quest_items?(player, WINDSUS_ALEPH_SKIN),
            get_quest_items_count(player, INDIGO_SPIRIT_ORE) >= 20,
            get_quest_items_count(player, SPORESEA_SEED) >= 30
          }.count &.itself
          if count < 3
            html = "30744-05.html"
          else
            qs.set_cond(2, true)
            give_items(player, FIRST_CIRCLE_HUNTER_LICENSE, 1)
            take_items(player, GUARDIAN_BASILISK_SCALE, -1)
            take_items(player, KARUT_WEED, -1)
            take_items(player, HAKAS_HEAD, -1)
            take_items(player, JAKAS_HEAD, -1)
            take_items(player, MARKAS_HEAD, -1)
            take_items(player, WINDSUS_ALEPH_SKIN, -1)
            take_items(player, INDIGO_SPIRIT_ORE, -1)
            take_items(player, SPORESEA_SEED, -1)
            take_items(player, TEST_INSTRUCTIONS_1, -1)
            html = "30744-06.html"
          end
        end

        if has_quest_items?(player, FIRST_CIRCLE_HUNTER_LICENSE)
          if player.level < MAX_LEVEL
            html = "30744-07.html"
          elsif !has_quest_items?(player, TEST_INSTRUCTIONS_2)
            html = "30744-08.html"
          end
        end

        if has_quest_items?(player, TEST_INSTRUCTIONS_2)
          count = {
            get_quest_items_count(player, TIMAK_ORC_TOTEM) >= 20,
            get_quest_items_count(player, TRISALIM_SILK) >= 20,
            get_quest_items_count(player, AMBROSIUS_FRUIT) >= 30,
            get_quest_items_count(player, BALEFIRE_CRYSTAL) >= 20,
            get_quest_items_count(player, IMPERIAL_ARROWHEAD) >= 20,
            get_quest_items_count(player, ATHUS_HEAD) + get_quest_items_count(player, LANKAS_HEAD) + get_quest_items_count(player, TRISKAS_HEAD) + get_quest_items_count(player, MOTURAS_HEAD) + get_quest_items_count(player, KALATHS_HEAD) >= 5
          }.count &.itself
          if count < 3
            html = "30744-11.html"
          else
            qs.set_cond(3, true)
            give_items(player, SECOND_CIRCLE_HUNTER_LICENSE, 1)
            take_items(player, TRISALIM_SILK, -1)
            take_items(player, TIMAK_ORC_TOTEM, -1)
            take_items(player, AMBROSIUS_FRUIT, -1)
            take_items(player, BALEFIRE_CRYSTAL, -1)
            take_items(player, IMPERIAL_ARROWHEAD, -1)
            take_items(player, ATHUS_HEAD, -1)
            take_items(player, LANKAS_HEAD, -1)
            take_items(player, TRISKAS_HEAD, -1)
            take_items(player, MOTURAS_HEAD, -1)
            take_items(player, KALATHS_HEAD, -1)
            take_items(player, TEST_INSTRUCTIONS_2, -1)
            take_items(player, FIRST_CIRCLE_HUNTER_LICENSE, -1)
            html = "30744-12.html"
          end
        end

        if has_quest_items?(player, SECOND_CIRCLE_HUNTER_LICENSE)
          html = "30744-14.html"
        end
      when CYBELLIN
        if !has_quest_items?(player, SECOND_CIRCLE_HUNTER_LICENSE) && !has_quest_items?(player, FIRST_CIRCLE_HUNTER_LICENSE)
          html = "30746-01.html"
        elsif !has_quest_items?(player, CYBELLINS_REQUEST)
          html = "30746-02.html"
        elsif has_quest_items?(player, BLOOD_CRYSTAL_PURITY_1)
          html = "30746-04.html"
        elsif has_quest_items?(player, BLOOD_CRYSTAL_PURITY_2) || has_quest_items?(player, BLOOD_CRYSTAL_PURITY_3) || has_quest_items?(player, BLOOD_CRYSTAL_PURITY_4) || has_quest_items?(player, BLOOD_CRYSTAL_PURITY_5) || has_quest_items?(player, BLOOD_CRYSTAL_PURITY_6) || has_quest_items?(player, BLOOD_CRYSTAL_PURITY_7) || has_quest_items?(player, BLOOD_CRYSTAL_PURITY_8) || has_quest_items?(player, BLOOD_CRYSTAL_PURITY_9)
          html = "30746-05.html"
        elsif has_quest_items?(player, BLOOD_CRYSTAL_PURITY_10)
          give_adena(player, 870400, true)
          take_items(player, BLOOD_CRYSTAL_PURITY_10, -1)
          html = "30746-05a.html"
        elsif !has_quest_items?(player, BROKEN_BLOOD_CRYSTAL)
          html = "30746-08.html"
        else
          take_items(player, BROKEN_BLOOD_CRYSTAL, -1)
          html = "30746-09.html"
        end
      when TOR
        if !has_quest_items?(player, SECOND_CIRCLE_HUNTER_LICENSE) && !has_quest_items?(player, FIRST_CIRCLE_HUNTER_LICENSE)
          html = "30745-01a.html"
        else
          request_count = get_quest_items_count(player, FIRST_CIRCLE_REQUEST_1C, FIRST_CIRCLE_REQUEST_2C, FIRST_CIRCLE_REQUEST_3C, FIRST_CIRCLE_REQUEST_4C, FIRST_CIRCLE_REQUEST_5C, FIRST_CIRCLE_REQUEST_6C, FIRST_CIRCLE_REQUEST_7C, FIRST_CIRCLE_REQUEST_8C, FIRST_CIRCLE_REQUEST_9C, FIRST_CIRCLE_REQUEST_10C, FIRST_CIRCLE_REQUEST_11C, FIRST_CIRCLE_REQUEST_12C, FIRST_CIRCLE_REQUEST_1B, FIRST_CIRCLE_REQUEST_2B, FIRST_CIRCLE_REQUEST_3B, FIRST_CIRCLE_REQUEST_4B, FIRST_CIRCLE_REQUEST_5B, FIRST_CIRCLE_REQUEST_6B, FIRST_CIRCLE_REQUEST_1A, FIRST_CIRCLE_REQUEST_2A, FIRST_CIRCLE_REQUEST_3A, SECOND_CIRCLE_REQUEST_1C, SECOND_CIRCLE_REQUEST_2C, SECOND_CIRCLE_REQUEST_3C, SECOND_CIRCLE_REQUEST_4C, SECOND_CIRCLE_REQUEST_5C, SECOND_CIRCLE_REQUEST_6C, SECOND_CIRCLE_REQUEST_7C, SECOND_CIRCLE_REQUEST_8C, SECOND_CIRCLE_REQUEST_9C, SECOND_CIRCLE_REQUEST_10C, SECOND_CIRCLE_REQUEST_11C, SECOND_CIRCLE_REQUEST_12C, SECOND_CIRCLE_REQUEST_1B, SECOND_CIRCLE_REQUEST_2B, SECOND_CIRCLE_REQUEST_3B, SECOND_CIRCLE_REQUEST_4B, SECOND_CIRCLE_REQUEST_5B, SECOND_CIRCLE_REQUEST_6B, SECOND_CIRCLE_REQUEST_1A, SECOND_CIRCLE_REQUEST_2A, SECOND_CIRCLE_REQUEST_3A)
          if has_quest_items?(player, FIRST_CIRCLE_HUNTER_LICENSE)
            if request_count == 0
              if player.level < MAX_LEVEL
                html = "30745-01b.html"
              else
                if has_quest_items?(player, SECOND_CIRCLE_HUNTER_LICENSE)
                  html = "30745-03.html"
                else
                  html = "30745-03a.html"
                end
              end
            else
              html = reward(player, qs, REWARDS)
            end
          elsif has_quest_items?(player, SECOND_CIRCLE_HUNTER_LICENSE)
            if request_count == 0
              html = "30745-03b.html"
            else
              html = reward(player, qs, REWARDS)
            end
          end
        end
      end

    end

    html || get_no_quest_msg(player)
  end

  def on_adv_event(event, npc, player)
    player = player.not_nil!

    unless qs = get_quest_state(player, false)
      return
    end

    html = nil
    case event
    when "30744-03.htm"
      qs.start_quest
      unless has_quest_items?(player, TEST_INSTRUCTIONS_1)
        give_items(player, TEST_INSTRUCTIONS_1, 1)
      end
      qs.memo_state = 0
      html = event
    when "30744-04.html", "30744-04a.html", "30744-04b.html", "30744-04c.html",
         "30744-04d.html", "30744-04e.html", "30744-04f.html", "30744-07.html",
         "30744-07a.html", "30744-07b.html", "30744-08.html", "30744-08a.html",
         "30744-10.html", "30744-10a.html", "30744-10b.html", "30744-10c.html",
         "30744-10d.html", "30744-10e.html", "30744-10f.html", "30744-14.html",
         "30744-14a.html", "30744-15.html", "30744-18.html", "30745-09.html",
         "30746-03a.html", "30746-07.html", "30745-04.html", "30745-05a.html",
         "30745-05c.html"
      html = event
    when "30744-09.html"
      if (get_quest_items_count(player, FIRST_CIRCLE_REQUEST_1C) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_2C) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_3C) +
          get_quest_items_count(player, FIRST_CIRCLE_REQUEST_4C) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_4C) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_6C) +
          get_quest_items_count(player, FIRST_CIRCLE_REQUEST_7C) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_8C) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_9C) +
          get_quest_items_count(player, FIRST_CIRCLE_REQUEST_10C) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_11C) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_12C) +
          get_quest_items_count(player, FIRST_CIRCLE_REQUEST_1B) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_2B) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_3B) +
          get_quest_items_count(player, FIRST_CIRCLE_REQUEST_4B) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_5B) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_6B) +
          get_quest_items_count(player, FIRST_CIRCLE_REQUEST_1A) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_2A) + get_quest_items_count(player, FIRST_CIRCLE_REQUEST_3A)) == 0
        give_items(player, TEST_INSTRUCTIONS_2, 1)
        html = event
      else
        html = "30744-09a.html"
      end
    when "30744-16.html"
      qs.exit_quest(true, true)

      take_items(player, -1, {FIRST_CIRCLE_HUNTER_LICENSE, SECOND_CIRCLE_HUNTER_LICENSE, LAUREL_LEAF_PIN, TEST_INSTRUCTIONS_1, TEST_INSTRUCTIONS_2, CYBELLINS_REQUEST, BLOOD_CRYSTAL_PURITY_1, BLOOD_CRYSTAL_PURITY_2, BLOOD_CRYSTAL_PURITY_3, BLOOD_CRYSTAL_PURITY_4, BLOOD_CRYSTAL_PURITY_5, BLOOD_CRYSTAL_PURITY_6, BLOOD_CRYSTAL_PURITY_7, BLOOD_CRYSTAL_PURITY_8, BLOOD_CRYSTAL_PURITY_9, BLOOD_CRYSTAL_PURITY_10, BROKEN_BLOOD_CRYSTAL, CYBELLINS_DAGGER, GUARDIAN_BASILISK_SCALE, KARUT_WEED, HAKAS_HEAD, JAKAS_HEAD, MARKAS_HEAD, WINDSUS_ALEPH_SKIN, INDIGO_SPIRIT_ORE, SPORESEA_SEED, TIMAK_ORC_TOTEM, TRISALIM_SILK, AMBROSIUS_FRUIT, BALEFIRE_CRYSTAL, IMPERIAL_ARROWHEAD, ATHUS_HEAD, LANKAS_HEAD, TRISKAS_HEAD, MOTURAS_HEAD, KALATHS_HEAD, FIRST_CIRCLE_REQUEST_1C, FIRST_CIRCLE_REQUEST_2C, FIRST_CIRCLE_REQUEST_3C, FIRST_CIRCLE_REQUEST_4C, FIRST_CIRCLE_REQUEST_5C, FIRST_CIRCLE_REQUEST_6C, FIRST_CIRCLE_REQUEST_7C, FIRST_CIRCLE_REQUEST_8C, FIRST_CIRCLE_REQUEST_9C, FIRST_CIRCLE_REQUEST_10C, FIRST_CIRCLE_REQUEST_11C, FIRST_CIRCLE_REQUEST_12C, FIRST_CIRCLE_REQUEST_1B, FIRST_CIRCLE_REQUEST_2B, FIRST_CIRCLE_REQUEST_3B, FIRST_CIRCLE_REQUEST_4B, FIRST_CIRCLE_REQUEST_5B, FIRST_CIRCLE_REQUEST_6B, FIRST_CIRCLE_REQUEST_1A, FIRST_CIRCLE_REQUEST_2A, FIRST_CIRCLE_REQUEST_3A, SECOND_CIRCLE_REQUEST_1C, SECOND_CIRCLE_REQUEST_2C, SECOND_CIRCLE_REQUEST_3C, SECOND_CIRCLE_REQUEST_4C, SECOND_CIRCLE_REQUEST_5C, SECOND_CIRCLE_REQUEST_6C, SECOND_CIRCLE_REQUEST_7C, SECOND_CIRCLE_REQUEST_8C, SECOND_CIRCLE_REQUEST_9C, SECOND_CIRCLE_REQUEST_10C, SECOND_CIRCLE_REQUEST_11C, SECOND_CIRCLE_REQUEST_12C, SECOND_CIRCLE_REQUEST_1B, SECOND_CIRCLE_REQUEST_2B, SECOND_CIRCLE_REQUEST_3B, SECOND_CIRCLE_REQUEST_4B, SECOND_CIRCLE_REQUEST_5B, SECOND_CIRCLE_REQUEST_6B, SECOND_CIRCLE_REQUEST_1A, SECOND_CIRCLE_REQUEST_2A, SECOND_CIRCLE_REQUEST_3A, CHARM_OF_KADESH, TIMAK_JADE_NECKLACE, ENCHANTED_GOLEM_SHARD, GIANT_MONSTER_EYE_MEAT, DIRE_WYRM_EGG, GUARDIAN_BASILISK_TALON, REVENANTS_CHAINS, WINDSUS_TUSK, GRANDISS_SKULL, TAIK_OBSIDIAN_AMULET, KARUL_BUGBEAR_HEAD, TAMLIN_IVORY_CHARM, FANG_OF_NARAK, ENCHANTED_GARGOYLES_HORN, COILED_SERPENT_TOTEM, TOTEM_OF_KADESH, KAIKIS_HEAD, KRONBE_VENOM_SAC, EVAS_CHARM, TITANS_TABLET, BOOK_OF_SHUNAIMAN, ROTTING_TREE_SPORES, TRISALIM_VENOM_SAC, TAIK_ORC_TOTEM, HARIT_BARBED_NECKLACE, COIN_OF_OLD_EMPIRE, SKIN_OF_FARCRAN, TEMPEST_SHARD, TSUNAMI_SHARD, SATYR_MANE, HAMADRYAD_SHARD, VANOR_SILENOS_MANE, TALK_BUGBEAR_TOTEM, OKUNS_HEAD, KAKRANS_HEAD, NARCISSUSS_SOULSTONE, DEPRIVE_EYE, UNICORNS_HORN, KERUNOSS_GOLD_MANE, SKULL_OF_EXECUTED, BUST_OF_TRAVIS, SWORD_OF_CADMUS})

      # TODO(Zoey76): This is dead code.
      if get_quest_items_count(player, LAUREL_LEAF_PIN) < 20
        html = event
      else
        give_adena(player, 20000, true)
        html = "30744-17.html"
      end
    when "30745-02.html"
      if !has_quest_items?(player, TEST_INSTRUCTIONS_2)
        html = event
      else
        html = "30745-03.html"
      end
    when "LIST_1"
      i0 = 0
      i1 = 0
      i2 = 0
      i3 = 0
      i4 = 0
      i5 = 0

      if qs.memo_state?(0)
        while i0 == i1 || i1 == i2 || i2 == i3 || i3 == i4 || i0 == i4 || i0 == i2 || i0 == i3 || i1 == i3 || i1 == i4 || i2 == i4
          if !has_quest_items?(player, LAUREL_LEAF_PIN)
            i0 = Rnd.rand(12)
            i1 = Rnd.rand(12)
            i2 = Rnd.rand(12)
            i3 = Rnd.rand(12)
            i4 = Rnd.rand(12)
            qs.memo_state = (i0 * 32 * 32 * 32 * 32) + (i1 * 32 * 32 * 32) + (i2 * 32 * 32) + (i3 * 32 * 1) + (i4 * 1 * 1)
          elsif get_quest_items_count(player, LAUREL_LEAF_PIN) < 4
            if Rnd.rand(100) < 20
              i0 = Rnd.rand(6) + 12
              i1 = Rnd.rand(12)
              i2 = Rnd.rand(6)
              i3 = Rnd.rand(6) + 6
              i4 = Rnd.rand(12)
              qs.memo_state = (i0 * 32 * 32 * 32 * 32) + (i1 * 32 * 32 * 32) + (i2 * 32 * 32) + (i3 * 32 * 1) + (i4 * 1 * 1)
            else
              i0 = Rnd.rand(12)
              i1 = Rnd.rand(12)
              i2 = Rnd.rand(12)
              i3 = Rnd.rand(12)
              i4 = Rnd.rand(12)
              qs.memo_state = (i0 * 32 * 32 * 32 * 32) + (i1 * 32 * 32 * 32) + (i2 * 32 * 32) + (i3 * 32 * 1) + (i4 * 1 * 1)
            end
          elsif Rnd.rand(100) < 20
            i0 = Rnd.rand(6) + 12
            if Rnd.rand(20) == 0
              i1 = Rnd.rand(2) + 18
            else
              i1 = Rnd.rand(12)
            end
            i2 = Rnd.rand(6)
            i3 = Rnd.rand(6) + 6
            i4 = Rnd.rand(12)
            qs.memo_state = (i0 * 32 * 32 * 32 * 32) + (i1 * 32 * 32 * 32) + (i2 * 32 * 32) + (i3 * 32 * 1) + (i4 * 1 * 1)
          else
            i0 = Rnd.rand(12)
            if Rnd.rand(20) == 0
              i1 = Rnd.rand(2) + 18
            else
              i1 = Rnd.rand(12)
            end
            i2 = Rnd.rand(6)
            i3 = Rnd.rand(6) + 6
            i4 = Rnd.rand(12)
            qs.memo_state = (i0 * 32 * 32 * 32 * 32) + (i1 * 32 * 32 * 32) + (i2 * 32 * 32) + (i3 * 32 * 1) + (i4 * 1 * 1)
          end
        end

        i0 = 33520 + i0
        i1 = 33520 + i1
        i2 = 33520 + i2
        i3 = 33520 + i3
        i4 = 33520 + i4

        html = get_html(player, "30745-16.html", i0, i1, i2, i3, i4)
      else
        i5 = qs.memo_state
        i0 = i5 % 32
        i5 = i5 // 32
        i1 = i5 % 32
        i5 = i5 // 32
        i2 = i5 % 32
        i5 = i5 // 32
        i3 = i5 % 32
        i5 = i5 // 32
        i4 = i5 % 32
        i5 = i5 // 32
        i0 = 33520 + i0
        i1 = 33520 + i1
        i2 = 33520 + i2
        i3 = 33520 + i3
        i4 = 33520 + i4

        html = get_html(player, "30745-16.html", i4, i3, i2, i1, i0)
      end
    when "LIST_2"
      i0 = 0
      i1 = 0
      i2 = 0
      i3 = 0
      i4 = 0
      i5 = 0

      if qs.memo_state?(0)
        while i0 == i1 || i1 == i2 || i2 == i3 || i3 == i4 || i0 == i4 || i0 == i2 || i0 == i3 || i1 == i3 || i1 == i4 || i2 == i4
          if !has_quest_items?(player, LAUREL_LEAF_PIN)
            i0 = Rnd.rand(10)
            i1 = Rnd.rand(10)
            i2 = Rnd.rand(5)
            i3 = Rnd.rand(5) + 5
            i4 = Rnd.rand(10)
            qs.memo_state = (i0 * 32 * 32 * 32 * 32) + (i1 * 32 * 32 * 32) + (i2 * 32 * 32) + (i3 * 32 * 1) + (i4 * 1 * 1)
          elsif get_quest_items_count(player, LAUREL_LEAF_PIN) < 4
            if Rnd.rand(100) < 20
              i0 = Rnd.rand(6) + 10
              i1 = Rnd.rand(10)
              i2 = Rnd.rand(5)
              i3 = Rnd.rand(5) + 5
              i4 = Rnd.rand(10)
              qs.memo_state = (i0 * 32 * 32 * 32 * 32) + (i1 * 32 * 32 * 32) + (i2 * 32 * 32) + (i3 * 32 * 1) + (i4 * 1 * 1)
            else
              i0 = Rnd.rand(10)
              i1 = Rnd.rand(10)
              i2 = Rnd.rand(5)
              i3 = Rnd.rand(5) + 5
              i4 = Rnd.rand(10)
              qs.memo_state = (i0 * 32 * 32 * 32 * 32) + (i1 * 32 * 32 * 32) + (i2 * 32 * 32) + (i3 * 32 * 1) + (i4 * 1 * 1)
            end
          elsif Rnd.rand(100) < 20
            i0 = Rnd.rand(6) + 10
            if Rnd.rand(20) == 0
              i1 = Rnd.rand(3) + 16
            else
              i1 = Rnd.rand(10)
            end
            i2 = Rnd.rand(5)
            i3 = Rnd.rand(5) + 5
            i4 = Rnd.rand(10)
            qs.memo_state = (i0 * 32 * 32 * 32 * 32) + (i1 * 32 * 32 * 32) + (i2 * 32 * 32) + (i3 * 32 * 1) + (i4 * 1 * 1)
          else
            i0 = Rnd.rand(10)
            if Rnd.rand(20) == 0
              i1 = Rnd.rand(3) + 16
            else
              i1 = Rnd.rand(10)
            end
            i2 = Rnd.rand(5)
            i3 = Rnd.rand(5) + 5
            i4 = Rnd.rand(10)
            qs.memo_state = (i0 * 32 * 32 * 32 * 32) + (i1 * 32 * 32 * 32) + (i2 * 32 * 32) + (i3 * 32 * 1) + (i4 * 1 * 1)
          end
        end

        i0 = 33520 + (i0 + 20)
        i1 = 33520 + (i1 + 20)
        i2 = 33520 + (i2 + 20)
        i3 = 33520 + (i3 + 20)
        i4 = 33520 + (i4 + 20)

        html = get_html(player, "30745-16.html", i0, i1, i2, i3, i4)
      else
        i5 = qs.memo_state
        i0 = i5 % 32
        i5 = i5 // 32
        i1 = i5 % 32
        i5 = i5 // 32
        i2 = i5 % 32
        i5 = i5 // 32
        i3 = i5 % 32
        i5 = i5 // 32
        i4 = i5 % 32
        i5 = i5 // 32
        i0 = 33520 + (i0 + 20)
        i1 = 33520 + (i1 + 20)
        i2 = 33520 + (i2 + 20)
        i3 = 33520 + (i3 + 20)
        i4 = 33520 + (i4 + 20)

        html = get_html(player, "30745-16.html", i4, i3, i2, i1, i0)
      end
    when "30746-03.html"
      unless has_quest_items?(player, CYBELLINS_DAGGER)
        give_items(player, CYBELLINS_DAGGER, 1)
      end
      if get_quest_items_count(player, CYBELLINS_REQUEST) == 0
        give_items(player, CYBELLINS_REQUEST, 1)
      end
      give_items(player, BLOOD_CRYSTAL_PURITY_1, 1)
      if has_quest_items?(player, BROKEN_BLOOD_CRYSTAL)
        take_items(player, BROKEN_BLOOD_CRYSTAL, -1)
      end
      html = event
    when "30746-06.html"
      if has_quest_items?(player, BLOOD_CRYSTAL_PURITY_2)
        give_adena(player, 3400, true)
      elsif has_quest_items?(player, BLOOD_CRYSTAL_PURITY_3)
        give_adena(player, 6800, true)
      elsif has_quest_items?(player, BLOOD_CRYSTAL_PURITY_4)
        give_adena(player, 13600, true)
      elsif has_quest_items?(player, BLOOD_CRYSTAL_PURITY_5)
        give_adena(player, 27200, true)
      elsif has_quest_items?(player, BLOOD_CRYSTAL_PURITY_6)
        give_adena(player, 54400, true)
      elsif has_quest_items?(player, BLOOD_CRYSTAL_PURITY_7)
        give_adena(player, 108800, true)
      elsif has_quest_items?(player, BLOOD_CRYSTAL_PURITY_8)
        give_adena(player, 217600, true)
      elsif has_quest_items?(player, BLOOD_CRYSTAL_PURITY_9)
        give_adena(player, 435200, true)
      elsif has_quest_items?(player, BLOOD_CRYSTAL_PURITY_10)
        give_adena(player, 870400, true)
      end
      take_items(player, BLOOD_CRYSTAL_PURITY_2, -1)
      take_items(player, BLOOD_CRYSTAL_PURITY_3, -1)
      take_items(player, BLOOD_CRYSTAL_PURITY_4, -1)
      take_items(player, BLOOD_CRYSTAL_PURITY_5, -1)
      take_items(player, BLOOD_CRYSTAL_PURITY_6, -1)
      take_items(player, BLOOD_CRYSTAL_PURITY_7, -1)
      take_items(player, BLOOD_CRYSTAL_PURITY_8, -1)
      take_items(player, BLOOD_CRYSTAL_PURITY_9, -1)
      take_items(player, BLOOD_CRYSTAL_PURITY_10, -1)
      html = event
    when "30746-10.html"
      take_items(player, BLOOD_CRYSTAL_PURITY_1, -1)
      take_items(player, CYBELLINS_DAGGER, -1)
      take_items(player, CYBELLINS_REQUEST, -1)
      html = event
    when "30745-05b.html"
      html = event
      if has_quest_items?(player, LAUREL_LEAF_PIN)
        take_items(player, LAUREL_LEAF_PIN, 1)
      end

      take_items(player, -1, {FIRST_CIRCLE_REQUEST_1C, FIRST_CIRCLE_REQUEST_2C, FIRST_CIRCLE_REQUEST_3C, FIRST_CIRCLE_REQUEST_4C, FIRST_CIRCLE_REQUEST_5C, FIRST_CIRCLE_REQUEST_6C, FIRST_CIRCLE_REQUEST_7C, FIRST_CIRCLE_REQUEST_8C, FIRST_CIRCLE_REQUEST_9C, FIRST_CIRCLE_REQUEST_10C, FIRST_CIRCLE_REQUEST_11C, FIRST_CIRCLE_REQUEST_12C})
      take_items(player, -1, {FIRST_CIRCLE_REQUEST_1B, FIRST_CIRCLE_REQUEST_2B, FIRST_CIRCLE_REQUEST_3B, FIRST_CIRCLE_REQUEST_4B, FIRST_CIRCLE_REQUEST_5B, FIRST_CIRCLE_REQUEST_6B})
      take_items(player, -1, {FIRST_CIRCLE_REQUEST_1A, FIRST_CIRCLE_REQUEST_2A, FIRST_CIRCLE_REQUEST_3A})
      take_items(player, -1, {SECOND_CIRCLE_REQUEST_1C, SECOND_CIRCLE_REQUEST_2C, SECOND_CIRCLE_REQUEST_3C, SECOND_CIRCLE_REQUEST_4C, SECOND_CIRCLE_REQUEST_5C, SECOND_CIRCLE_REQUEST_6C, SECOND_CIRCLE_REQUEST_7C, SECOND_CIRCLE_REQUEST_8C, SECOND_CIRCLE_REQUEST_9C, SECOND_CIRCLE_REQUEST_10C, SECOND_CIRCLE_REQUEST_11C, SECOND_CIRCLE_REQUEST_12C})
      take_items(player, -1, {SECOND_CIRCLE_REQUEST_1B, SECOND_CIRCLE_REQUEST_2B, SECOND_CIRCLE_REQUEST_3B, SECOND_CIRCLE_REQUEST_4B, SECOND_CIRCLE_REQUEST_5B, SECOND_CIRCLE_REQUEST_6B})
      take_items(player, -1, {SECOND_CIRCLE_REQUEST_1A, SECOND_CIRCLE_REQUEST_2A, SECOND_CIRCLE_REQUEST_3A})
      take_items(player, -1, {CHARM_OF_KADESH, TIMAK_JADE_NECKLACE, ENCHANTED_GOLEM_SHARD, GIANT_MONSTER_EYE_MEAT, DIRE_WYRM_EGG, GUARDIAN_BASILISK_TALON})
      take_items(player, -1, {REVENANTS_CHAINS, WINDSUS_TUSK, GRANDISS_SKULL, TAIK_OBSIDIAN_AMULET, KARUL_BUGBEAR_HEAD, TAMLIN_IVORY_CHARM})
      take_items(player, -1, {FANG_OF_NARAK, ENCHANTED_GARGOYLES_HORN, COILED_SERPENT_TOTEM, TOTEM_OF_KADESH, KAIKIS_HEAD, KRONBE_VENOM_SAC})
      take_items(player, -1, {EVAS_CHARM, TITANS_TABLET, BOOK_OF_SHUNAIMAN, ROTTING_TREE_SPORES, TRISALIM_VENOM_SAC, TAIK_ORC_TOTEM})
      take_items(player, -1, {HARIT_BARBED_NECKLACE, COIN_OF_OLD_EMPIRE, SKIN_OF_FARCRAN, TEMPEST_SHARD, TSUNAMI_SHARD, SATYR_MANE})
      take_items(player, -1, {HAMADRYAD_SHARD, VANOR_SILENOS_MANE, TALK_BUGBEAR_TOTEM, OKUNS_HEAD, KAKRANS_HEAD, NARCISSUSS_SOULSTONE})
      take_items(player, -1, {DEPRIVE_EYE, UNICORNS_HORN, KERUNOSS_GOLD_MANE, SKULL_OF_EXECUTED, BUST_OF_TRAVIS, SWORD_OF_CADMUS})
    when "30745-10a.html"
      give_items(player, FIRST_CIRCLE_REQUEST_1C, 1)
      html = event
    when "30745-10b.html"
      give_items(player, FIRST_CIRCLE_REQUEST_2C, 1)
      html = event
    when "30745-10c.html"
      give_items(player, FIRST_CIRCLE_REQUEST_3C, 1)
      html = event
    when "30745-10d.html"
      give_items(player, FIRST_CIRCLE_REQUEST_4C, 1)
      html = event
    when "30745-10e.html"
      give_items(player, FIRST_CIRCLE_REQUEST_5C, 1)
      html = event
    when "30745-10f.html"
      give_items(player, FIRST_CIRCLE_REQUEST_6C, 1)
      html = event
    when "30745-10g.html"
      give_items(player, FIRST_CIRCLE_REQUEST_7C, 1)
      html = event
    when "30745-10h.html"
      give_items(player, FIRST_CIRCLE_REQUEST_8C, 1)
      html = event
    when "30745-10i.html"
      give_items(player, FIRST_CIRCLE_REQUEST_9C, 1)
      html = event
    when "30745-10j.html"
      give_items(player, FIRST_CIRCLE_REQUEST_10C, 1)
      html = event
    when "30745-10k.html"
      give_items(player, FIRST_CIRCLE_REQUEST_11C, 1)
      html = event
    when "30745-10l.html"
      give_items(player, FIRST_CIRCLE_REQUEST_12C, 1)
      html = event
    when "30745-11a.html"
      give_items(player, FIRST_CIRCLE_REQUEST_1B, 1)
      html = event
    when "30745-11b.html"
      give_items(player, FIRST_CIRCLE_REQUEST_2B, 1)
      html = event
    when "30745-11c.html"
      give_items(player, FIRST_CIRCLE_REQUEST_3B, 1)
      html = event
    when "30745-11d.html"
      give_items(player, FIRST_CIRCLE_REQUEST_4B, 1)
      html = event
    when "30745-11e.html"
      give_items(player, FIRST_CIRCLE_REQUEST_5B, 1)
      html = event
    when "30745-11f.html"
      give_items(player, FIRST_CIRCLE_REQUEST_6B, 1)
      html = event
    when "30745-12a.html"
      give_items(player, FIRST_CIRCLE_REQUEST_1A, 1)
      html = event
    when "30745-12b.html"
      give_items(player, FIRST_CIRCLE_REQUEST_2A, 1)
      html = event
    when "30745-12c.html"
      give_items(player, FIRST_CIRCLE_REQUEST_3A, 1)
      html = event
    when "30745-13a.html"
      give_items(player, SECOND_CIRCLE_REQUEST_1C, 1)
      html = event
    when "30745-13b.html"
      give_items(player, SECOND_CIRCLE_REQUEST_2C, 1)
      html = event
    when "30745-13c.html"
      give_items(player, SECOND_CIRCLE_REQUEST_3C, 1)
      html = event
    when "30745-13d.html"
      give_items(player, SECOND_CIRCLE_REQUEST_4C, 1)
      html = event
    when "30745-13e.html"
      give_items(player, SECOND_CIRCLE_REQUEST_5C, 1)
      html = event
    when "30745-13f.html"
      give_items(player, SECOND_CIRCLE_REQUEST_6C, 1)
      html = event
    when "30745-13g.html"
      give_items(player, SECOND_CIRCLE_REQUEST_7C, 1)
      html = event
    when "30745-13k.html"
      give_items(player, SECOND_CIRCLE_REQUEST_11C, 1)
      html = event
    when "30745-13i.html"
      give_items(player, SECOND_CIRCLE_REQUEST_9C, 1)
      html = event
    when "30745-13j.html"
      give_items(player, SECOND_CIRCLE_REQUEST_10C, 1)
      html = event
    when "30745-13l.html"
      give_items(player, SECOND_CIRCLE_REQUEST_12C, 1)
      html = event
    when "30745-14a.html"
      give_items(player, SECOND_CIRCLE_REQUEST_1B, 1)
      html = event
    when "30745-14b.html"
      give_items(player, SECOND_CIRCLE_REQUEST_2B, 1)
      html = event
    when "30745-14c.html"
      give_items(player, SECOND_CIRCLE_REQUEST_3B, 1)
      html = event
    when "30745-14d.html"
      give_items(player, SECOND_CIRCLE_REQUEST_4B, 1)
      html = event
    when "30745-14e.html"
      give_items(player, SECOND_CIRCLE_REQUEST_5B, 1)
      html = event
    when "30745-14f.html"
      give_items(player, SECOND_CIRCLE_REQUEST_6B, 1)
      html = event
    end


    html
  end

  def on_kill(npc, player, is_summon)
    if qs = get_random_party_member_state(player, -1, 3, npc)
      DROPLIST.reverse_each do |droplist|
        if npc.id == droplist[0]
          if has_quest_items?(qs.player, droplist[1]) && give_item_randomly(qs.player, npc, droplist[2], droplist[3], droplist[4], droplist[5] / 100, true)
            play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
          end
        end
      end

      case npc.id
      when BREKA_ORC_WARRIOR
        if has_quest_items?(qs.player, TEST_INSTRUCTIONS_1) && get_quest_items_count(qs.player, HAKAS_HEAD) + get_quest_items_count(qs.player, JAKAS_HEAD) + get_quest_items_count(qs.player, MARKAS_HEAD) < 3
          if Rnd.rand(10) < 2
            if !has_quest_items?(qs.player, HAKAS_HEAD)
              add_spawn(BREKA_OVERLORD_HAKA, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
            elsif !has_quest_items?(qs.player, JAKAS_HEAD)
              add_spawn(BREKA_OVERLORD_JAKA, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
            elsif !has_quest_items?(qs.player, MARKAS_HEAD)
              add_spawn(BREKA_OVERLORD_MARKA, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
            end
          end
        end
      when WINDSUS
        if has_quest_items?(qs.player, TEST_INSTRUCTIONS_1) && !has_quest_items?(qs.player, WINDSUS_ALEPH_SKIN) && Rnd.rand(10) < 2
          add_spawn(WINDSUS_ALEPH, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
        end
      when GRANDIS
        if has_quest_items?(qs.player, FIRST_CIRCLE_REQUEST_2A) && !has_quest_items?(qs.player, TITANS_TABLET) && Rnd.rand(10) < 2
          add_spawn(GOK_MAGOK, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
        end
      when TARLK_BUGBEAR_WARRIOR
        if has_quest_items?(qs.player, TEST_INSTRUCTIONS_2) && get_quest_items_count(qs.player, ATHUS_HEAD) + get_quest_items_count(qs.player, LANKAS_HEAD) + get_quest_items_count(qs.player, TRISKAS_HEAD) + get_quest_items_count(qs.player, MOTURAS_HEAD) + get_quest_items_count(qs.player, KALATHS_HEAD) < 5
          if Rnd.rand(10) < 2
            if !has_quest_items?(qs.player, ATHUS_HEAD)
              add_spawn(TARLK_RAIDER_ATHU, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
            elsif !has_quest_items?(qs.player, LANKAS_HEAD)
              add_spawn(TARLK_RAIDER_LANKA, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
            elsif !has_quest_items?(qs.player, TRISKAS_HEAD)
              add_spawn(TARLK_RAIDER_TRISKA, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
            elsif !has_quest_items?(qs.player, MOTURAS_HEAD)
              add_spawn(TARLK_RAIDER_MOTURA, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
            elsif !has_quest_items?(qs.player, KALATHS_HEAD)
              add_spawn(TARLK_RAIDER_KALATH, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
            end
          end
        end
      when LETO_LIZARDMAN_SHAMAN
        if has_quest_items?(qs.player, FIRST_CIRCLE_REQUEST_4B) && !has_quest_items?(qs.player, TOTEM_OF_KADESH) && Rnd.rand(10) < 2
          add_spawn(LETO_SHAMAN_KETZ, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
        end

        evolve_blood_crystal(qs.player)
      when LETO_LIZARDMAN_OVERLORD
        if has_quest_items?(qs.player, FIRST_CIRCLE_REQUEST_1B) && !has_quest_items?(qs.player, FANG_OF_NARAK) && Rnd.rand(10) < 2
          add_spawn(LETO_CHIEF_NARAK, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
        end

        evolve_blood_crystal(qs.player)
      when TIMAK_ORC_WARRIOR
        if has_quest_items?(qs.player, FIRST_CIRCLE_REQUEST_5B) && !has_quest_items?(qs.player, KAIKIS_HEAD) && Rnd.rand(10) < 2
          add_spawn(TIMAK_RAIDER_KAIKEE, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
        end
      when TIMAK_ORC_OVERLORD
        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_1B) && !has_quest_items?(qs.player, OKUNS_HEAD) && Rnd.rand(10) == 0
          add_spawn(TIMAK_OVERLORD_OKUN, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
        end
      when FLINE, LIELE
        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_7C) && get_quest_items_count(qs.player, TEMPEST_SHARD) < 40 && Rnd.rand(20) < 2
          add_spawn(GREMLIN_FILCHER, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::SHOW_ME_THE_PRETTY_SPARKLING_THINGS_THEYRE_ALL_MINE))
        end
      when FOREST_RUNNER
        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_10C) && get_quest_items_count(qs.player, HAMADRYAD_SHARD) < 40 && Rnd.rand(20) < 2
          add_spawn(GREMLIN_FILCHER, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::SHOW_ME_THE_PRETTY_SPARKLING_THINGS_THEYRE_ALL_MINE))
        end
      when KARUL_BUGBEAR
        if has_quest_items?(qs.player, FIRST_CIRCLE_REQUEST_3A) && !has_quest_items?(qs.player, BOOK_OF_SHUNAIMAN) && Rnd.rand(10) < 2
          add_spawn(KARUL_CHIEF_OROOTO, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
        end
      when TAIK_ORC_CAPTAIN
        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_2B) && !has_quest_items?(qs.player, KAKRANS_HEAD) && Rnd.rand(10) < 2
          add_spawn(TAIK_OVERLORD_KAKRAN, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
        end
      when MIRROR
        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_3B) && get_quest_items_count(qs.player, NARCISSUSS_SOULSTONE) < 40 && Rnd.rand(20) < 2
          add_spawn(GREMLIN_FILCHER, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::SHOW_ME_THE_PRETTY_SPARKLING_THINGS_THEYRE_ALL_MINE))
        end
      when HATAR_RATMAN_THIEF
        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_5C) && get_quest_items_count(qs.player, COIN_OF_OLD_EMPIRE) < 20 && Rnd.rand(20) < 2
          add_spawn(GREMLIN_FILCHER, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::SHOW_ME_THE_PRETTY_SPARKLING_THINGS_THEYRE_ALL_MINE))
        end
      when HATAR_RATMAN_BOSS
        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_5C) && get_quest_items_count(qs.player, COIN_OF_OLD_EMPIRE) < 20 && Rnd.rand(20) < 2
          add_spawn(GREMLIN_FILCHER, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::SHOW_ME_THE_PRETTY_SPARKLING_THINGS_THEYRE_ALL_MINE))
        end

        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_2A) && !has_quest_items?(qs.player, BUST_OF_TRAVIS) && Rnd.rand(10) < 2
          add_spawn(HATAR_CHIEFTAIN_KUBEL, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
        end
      when VANOR_SILENOS_CHIEFTAIN
        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_6B) && !has_quest_items?(qs.player, KERUNOSS_GOLD_MANE) && Rnd.rand(10) < 2
          add_spawn(VANOR_ELDER_KERUNOS, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
        end
      when GREMLIN_FILCHER
        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_7C) && get_quest_items_count(qs.player, TEMPEST_SHARD) < 40
          if give_item_randomly(qs.player, npc, TEMPEST_SHARD, 5, 40, 1.0, true)
            play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
          end

          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::PRETTY_GOOD))
        end

        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_8C) && get_quest_items_count(qs.player, TSUNAMI_SHARD) < 40
          if give_item_randomly(qs.player, npc, TSUNAMI_SHARD, 5, 40, 1.0, true)
            play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
          end

          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::PRETTY_GOOD))
        end

        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_10C) && get_quest_items_count(qs.player, HAMADRYAD_SHARD) < 40
          if give_item_randomly(qs.player, npc, HAMADRYAD_SHARD, 5, 40, 1.0, true)
            play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
          end

          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::PRETTY_GOOD))
        end

        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_3B) && get_quest_items_count(qs.player, NARCISSUSS_SOULSTONE) < 40
          if give_item_randomly(qs.player, npc, NARCISSUSS_SOULSTONE, 5, 40, 1.0, true)
            play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
          end

          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::PRETTY_GOOD))
        end

        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_5C) && get_quest_items_count(qs.player, COIN_OF_OLD_EMPIRE) < 20
          if give_item_randomly(qs.player, npc, COIN_OF_OLD_EMPIRE, 3, 20, 1.0, true)
            play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
          end

          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::PRETTY_GOOD))
        end
      when GOK_MAGOK
        if has_quest_items?(qs.player, FIRST_CIRCLE_REQUEST_2A) && !has_quest_items?(qs.player, TITANS_TABLET) && Rnd.rand(2).zero?
          add_spawn(BLACK_LEGION_STORMTROOPER, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
          add_spawn(BLACK_LEGION_STORMTROOPER, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::WELL_TAKE_THE_PROPERTY_OF_THE_ANCIENT_EMPIRE))
        end
      when HATAR_CHIEFTAIN_KUBEL
        if has_quest_items?(qs.player, SECOND_CIRCLE_REQUEST_2A) && !has_quest_items?(qs.player, BUST_OF_TRAVIS) && Rnd.rand(2).zero?
          add_spawn(BLACK_LEGION_STORMTROOPER, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
          add_spawn(BLACK_LEGION_STORMTROOPER, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::WELL_TAKE_THE_PROPERTY_OF_THE_ANCIENT_EMPIRE))
        end
      when KARUL_CHIEF_OROOTO
        if has_quest_items?(qs.player, FIRST_CIRCLE_REQUEST_3A) && !has_quest_items?(qs.player, BOOK_OF_SHUNAIMAN) && Rnd.rand(2).zero?
          add_spawn(BLACK_LEGION_STORMTROOPER, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
          add_spawn(BLACK_LEGION_STORMTROOPER, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, true)
          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::WELL_TAKE_THE_PROPERTY_OF_THE_ANCIENT_EMPIRE))
        end
      when LETO_LIZARDMAN_ARCHER, LETO_LIZARDMAN_SOLDIER, HARIT_LIZARDMAN_GRUNT,
           HARIT_LIZARDMAN_ARCHER, HARIT_LIZARDMAN_WARRIOR
        evolve_blood_crystal(qs.player)
      end

    end

    super
  end

  private def reward(pc, qs, rewards)
    rewards.reverse_each do |reward|
      if has_quest_items?(pc, reward[0])
        if get_quest_items_count(pc, reward[1]) >= reward[2]
          give_items(pc, LAUREL_LEAF_PIN, 1)
          give_adena(pc, reward[3], true)
          play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
          qs.memo_state = 0
          take_items(pc, reward[0], -1)
          if reward[1] == GIANT_MONSTER_EYE_MEAT
            take_items(pc, reward[1], reward[2])
          else
            take_items(pc, reward[1], -1)
          end
          if has_quest_items?(pc, FIRST_CIRCLE_HUNTER_LICENSE)
            return "30745-06a.html"
          else
            return "30745-06b.html"
          end
        end

        return "30745-05.html"
      end
    end

    nil
  end

  private def get_html(pc, html_name, i0, i1, i2, i3, i4)
    html = get_htm(pc, html_name)
    html = html.sub("<?reply1?>", LINKS[i0])
    html = html.sub("<?reply2?>", LINKS[i1])
    html = html.sub("<?reply3?>", LINKS[i2])
    html = html.sub("<?reply4?>", LINKS[i3])
    html.sub("<?reply5?>", LINKS[i4])
  end

  private def evolve_blood_crystal(pc)
    weapon = pc.active_weapon_item
    if weapon && weapon.id == CYBELLINS_DAGGER && (has_quest_items?(pc, FIRST_CIRCLE_HUNTER_LICENSE) || has_quest_items?(pc, SECOND_CIRCLE_HUNTER_LICENSE))
      if Rnd.rand(100) < 60
        if has_quest_items?(pc, CYBELLINS_REQUEST)
          if has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_1)
            give_items(pc, BLOOD_CRYSTAL_PURITY_2, 1)
            take_items(pc, BLOOD_CRYSTAL_PURITY_1, -1)
          elsif has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_2)
            give_items(pc, BLOOD_CRYSTAL_PURITY_3, 1)
            take_items(pc, BLOOD_CRYSTAL_PURITY_2, -1)
          elsif has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_3)
            give_items(pc, BLOOD_CRYSTAL_PURITY_4, 1)
            take_items(pc, BLOOD_CRYSTAL_PURITY_3, -1)
          elsif has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_4)
            give_items(pc, BLOOD_CRYSTAL_PURITY_5, 1)
            take_items(pc, BLOOD_CRYSTAL_PURITY_4, -1)
          elsif has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_5)
            give_items(pc, BLOOD_CRYSTAL_PURITY_6, 1)
            take_items(pc, BLOOD_CRYSTAL_PURITY_5, -1)
          elsif has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_6)
            give_items(pc, BLOOD_CRYSTAL_PURITY_7, 1)
            play_sound(pc, Sound::ITEMSOUND_QUEST_JACKPOT)
            take_items(pc, BLOOD_CRYSTAL_PURITY_6, -1)
          elsif has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_7)
            give_items(pc, BLOOD_CRYSTAL_PURITY_8, 1)
            play_sound(pc, Sound::ITEMSOUND_QUEST_JACKPOT)
            take_items(pc, BLOOD_CRYSTAL_PURITY_7, -1)
          elsif has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_8)
            give_items(pc, BLOOD_CRYSTAL_PURITY_9, 1)
            play_sound(pc, Sound::ITEMSOUND_QUEST_JACKPOT)
            take_items(pc, BLOOD_CRYSTAL_PURITY_8, -1)
          elsif has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_9)
            give_items(pc, BLOOD_CRYSTAL_PURITY_10, 1)
            play_sound(pc, Sound::ITEMSOUND_QUEST_JACKPOT)
            take_items(pc, BLOOD_CRYSTAL_PURITY_9, -1)
          end
        end
      elsif has_quest_items?(pc, CYBELLINS_REQUEST) && (has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_1) || has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_2) || has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_3) || has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_4) || has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_5) || has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_6) || has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_7) || has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_8) || has_quest_items?(pc, BLOOD_CRYSTAL_PURITY_9))
        take_items(pc, -1, {BLOOD_CRYSTAL_PURITY_1, BLOOD_CRYSTAL_PURITY_2, BLOOD_CRYSTAL_PURITY_3, BLOOD_CRYSTAL_PURITY_4, BLOOD_CRYSTAL_PURITY_5, BLOOD_CRYSTAL_PURITY_6, BLOOD_CRYSTAL_PURITY_7, BLOOD_CRYSTAL_PURITY_8, BLOOD_CRYSTAL_PURITY_9})
        give_items(pc, BROKEN_BLOOD_CRYSTAL, 1)
      end
    end
  end
end
