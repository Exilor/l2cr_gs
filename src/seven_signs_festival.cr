module SevenSignsFestival
  extend Synchronizable
  extend SpawnListener
  extend Loggable
  extend self

  GET_CLAN_NAME = "SELECT clan_name FROM clan_data WHERE clan_id = (SELECT clanid FROM characters WHERE char_name = ?)"

  FESTIVAL_MAX_OFFSET_X = 230
  FESTIVAL_MAX_OFFSET_Y = 230
  FESTIVAL_DEFAULT_RESPAWN = 60

  FESTIVAL_COUNT = 5
  FESTIVAL_LEVEL_MAX_31 = 0
  FESTIVAL_LEVEL_MAX_42 = 1
  FESTIVAL_LEVEL_MAX_53 = 2
  FESTIVAL_LEVEL_MAX_64 = 3
  FESTIVAL_LEVEL_MAX_NONE = 4
  FESTIVAL_LEVEL_SCORES = {60, 70, 100, 120, 150}

  FESTIVAL_OFFERING_ID = 5901
  FESTIVAL_OFFERING_VALUE = 5

  FESTIVAL_DAWN_PLAYER_SPAWNS = {
    {-79187, 113186, -4895, 0}, # 31 and below
    {-75918, 110137, -4895, 0}, # 42 and below
    {-73835, 111969, -4895, 0}, # 53 and below
    {-76170, 113804, -4895, 0}, # 64 and below
    {-78927, 109528, -4895, 0} # No level limit
  }

  FESTIVAL_DUSK_PLAYER_SPAWNS = {
    {-77200, 88966, -5151, 0}, # 31 and below
    {-76941, 85307, -5151, 0}, # 42 and below
    {-74855, 87135, -5151, 0}, # 53 and below
    {-80208, 88222, -5151, 0}, # 64 and below
    {-79954, 84697, -5151, 0} # No level limit
  }

  FESTIVAL_DAWN_WITCH_SPAWNS = {
    {-79183, 113052, -4891, 0, 31132}, # 31 and below
    {-75916, 110270, -4891, 0, 31133}, # 42 and below
    {-73979, 111970, -4891, 0, 31134}, # 53 and below
    {-76174, 113663, -4891, 0, 31135}, # 64 and below
    {-78930, 109664, -4891, 0, 31136} # No level limit
  }

  FESTIVAL_DUSK_WITCH_SPAWNS = {
    {-77199, 88830, -5147, 0, 31142}, # 31 and below
    {-76942, 85438, -5147, 0, 31143}, # 42 and below
    {-74990, 87135, -5147, 0, 31144}, # 53 and below
    {-80207, 88222, -5147, 0, 31145}, # 64 and below
    {-79952, 84833, -5147, 0, 31146} # No level limit
  }

  FESTIVAL_DAWN_PRIMARY_SPAWNS = {
    {
      # Level 31 and Below - Offering of the Branded
      {-78537, 113839, -4895, -1, 18009},
      {-78466, 113852, -4895, -1, 18010},
      {-78509, 113899, -4895, -1, 18010},

      {-78481, 112557, -4895, -1, 18009},
      {-78559, 112504, -4895, -1, 18010},
      {-78489, 112494, -4895, -1, 18010},

      {-79803, 112543, -4895, -1, 18012},
      {-79854, 112492, -4895, -1, 18013},
      {-79886, 112557, -4895, -1, 18014},

      {-79821, 113811, -4895, -1, 18015},
      {-79857, 113896, -4895, -1, 18017},
      {-79878, 113816, -4895, -1, 18018},

      # Archers and Marksmen
      {-79190, 113660, -4895, -1, 18011},
      {-78710, 113188, -4895, -1, 18011},
      {-79190, 112730, -4895, -1, 18016},
      {-79656, 113188, -4895, -1, 18016}
    },
    {
      # Level 42 and Below - Apostate Offering
      {-76558, 110784, -4895, -1, 18019},
      {-76607, 110815, -4895, -1, 18020}, # South West
      {-76559, 110820, -4895, -1, 18020},

      {-75277, 110792, -4895, -1, 18019},
      {-75225, 110801, -4895, -1, 18020}, # South East
      {-75262, 110832, -4895, -1, 18020},

      {-75249, 109441, -4895, -1, 18022},
      {-75278, 109495, -4895, -1, 18023}, # North East
      {-75223, 109489, -4895, -1, 18024},

      {-76556, 109490, -4895, -1, 18025},
      {-76607, 109469, -4895, -1, 18027}, # North West
      {-76561, 109450, -4895, -1, 18028},
      # Archers and Marksmen
      {-76399, 110144, -4895, -1, 18021},
      {-75912, 110606, -4895, -1, 18021},
      {-75444, 110144, -4895, -1, 18026},
      {-75930, 109665, -4895, -1, 18026}
    },
    {
      # Level 53 and Below - Witch's Offering
      {-73184, 111319, -4895, -1, 18029},
      {-73135, 111294, -4895, -1, 18030}, # South West
      {-73185, 111281, -4895, -1, 18030},

      {-74477, 111321, -4895, -1, 18029},
      {-74523, 111293, -4895, -1, 18030}, # South East
      {-74481, 111280, -4895, -1, 18030},

      {-74489, 112604, -4895, -1, 18032},
      {-74491, 112660, -4895, -1, 18033}, # North East
      {-74527, 112629, -4895, -1, 18034},

      {-73197, 112621, -4895, -1, 18035},
      {-73142, 112631, -4895, -1, 18037}, # North West
      {-73182, 112656, -4895, -1, 18038},

      # Archers and Marksmen
      {-73834, 112430, -4895, -1, 18031},
      {-74299, 111959, -4895, -1, 18031},
      {-73841, 111491, -4895, -1, 18036},
      {-73363, 111959, -4895, -1, 18036}
    },
    {
      # Level 64 and Below - Dark Omen Offering
      {-75543, 114461, -4895, -1, 18039},
      {-75514, 114493, -4895, -1, 18040}, # South West
      {-75488, 114456, -4895, -1, 18040},

      {-75521, 113158, -4895, -1, 18039},
      {-75504, 113110, -4895, -1, 18040}, # South East
      {-75489, 113142, -4895, -1, 18040},

      {-76809, 113143, -4895, -1, 18042},
      {-76860, 113138, -4895, -1, 18043}, # North East
      {-76831, 113112, -4895, -1, 18044},

      {-76831, 114441, -4895, -1, 18045},
      {-76840, 114490, -4895, -1, 18047}, # North West
      {-76864, 114455, -4895, -1, 18048},

      # Archers and Marksmen
      {-75703, 113797, -4895, -1, 18041},
      {-76180, 114263, -4895, -1, 18041},
      {-76639, 113797, -4895, -1, 18046},
      {-76180, 113337, -4895, -1, 18046}
    },
    {
      # No Level Limit - Offering of Forbidden Path
      {-79576, 108881, -4895, -1, 18049},
      {-79592, 108835, -4895, -1, 18050}, # South West
      {-79614, 108871, -4895, -1, 18050},

      {-79586, 110171, -4895, -1, 18049},
      {-79589, 110216, -4895, -1, 18050}, # South East
      {-79620, 110177, -4895, -1, 18050},

      {-78825, 110182, -4895, -1, 18052},
      {-78238, 110182, -4895, -1, 18053}, # North East
      {-78266, 110218, -4895, -1, 18054},

      {-78275, 108883, -4895, -1, 18055},
      {-78267, 108839, -4895, -1, 18057}, # North West
      {-78241, 108871, -4895, -1, 18058},

      # Archers and Marksmen
      {-79394, 109538, -4895, -1, 18051},
      {-78929, 109992, -4895, -1, 18051},
      {-78454, 109538, -4895, -1, 18056},
      {-78929, 109053, -4895, -1, 18056}
    }
  }

  FESTIVAL_DUSK_PRIMARY_SPAWNS = {
    {
      # Level 31 and Below - Offering of the Branded
      {-76542, 89653, -5151, -1, 18009},
      {-76509, 89637, -5151, -1, 18010},
      {-76548, 89614, -5151, -1, 18010},

      {-76539, 88326, -5151, -1, 18009},
      {-76512, 88289, -5151, -1, 18010},
      {-76546, 88287, -5151, -1, 18010},

      {-77879, 88308, -5151, -1, 18012},
      {-77886, 88310, -5151, -1, 18013},
      {-77879, 88278, -5151, -1, 18014},

      {-77857, 89605, -5151, -1, 18015},
      {-77858, 89658, -5151, -1, 18017},
      {-77891, 89633, -5151, -1, 18018},

      # Archers and Marksmen
      {-76728, 88962, -5151, -1, 18011},
      {-77194, 88494, -5151, -1, 18011},
      {-77660, 88896, -5151, -1, 18016},
      {-77195, 89438, -5151, -1, 18016}
    },
    {
      # Level 42 and Below - Apostate's Offering
      {-77585, 84650, -5151, -1, 18019},
      {-77628, 84643, -5151, -1, 18020},
      {-77607, 84613, -5151, -1, 18020},

      {-76603, 85946, -5151, -1, 18019},
      {-77606, 85994, -5151, -1, 18020},
      {-77638, 85959, -5151, -1, 18020},

      {-76301, 85960, -5151, -1, 18022},
      {-76257, 85972, -5151, -1, 18023},
      {-76286, 85992, -5151, -1, 18024},

      {-76281, 84667, -5151, -1, 18025},
      {-76291, 84611, -5151, -1, 18027},
      {-76257, 84616, -5151, -1, 18028},

      # Archers and Marksmen
      {-77419, 85307, -5151, -1, 18021},
      {-76952, 85768, -5151, -1, 18021},
      {-76477, 85312, -5151, -1, 18026},
      {-76942, 84832, -5151, -1, 18026}
    },
    {
      # Level 53 and Below - Witch's Offering
      {-74211, 86494, -5151, -1, 18029},
      {-74200, 86449, -5151, -1, 18030},
      {-74167, 86464, -5151, -1, 18030},

      {-75495, 86482, -5151, -1, 18029},
      {-75540, 86473, -5151, -1, 18030},
      {-75509, 86445, -5151, -1, 18030},

      {-75509, 87775, -5151, -1, 18032},
      {-75518, 87826, -5151, -1, 18033},
      {-75542, 87780, -5151, -1, 18034},

      {-74214, 87789, -5151, -1, 18035},
      {-74169, 87801, -5151, -1, 18037},
      {-74198, 87827, -5151, -1, 18038},

      # Archers and Marksmen
      {-75324, 87135, -5151, -1, 18031},
      {-74852, 87606, -5151, -1, 18031},
      {-74388, 87146, -5151, -1, 18036},
      {-74856, 86663, -5151, -1, 18036}
    },
    {
      # Level 64 and Below - Dark Omen Offering
      {-79560, 89007, -5151, -1, 18039},
      {-79521, 89016, -5151, -1, 18040},
      {-79544, 89047, -5151, -1, 18040},

      {-79552, 87717, -5151, -1, 18039},
      {-79552, 87673, -5151, -1, 18040},
      {-79510, 87702, -5151, -1, 18040},

      {-80866, 87719, -5151, -1, 18042},
      {-80897, 87689, -5151, -1, 18043},
      {-80850, 87685, -5151, -1, 18044},

      {-80848, 89013, -5151, -1, 18045},
      {-80887, 89051, -5151, -1, 18047},
      {-80891, 89004, -5151, -1, 18048},

      # Archers and Marksmen
      {-80205, 87895, -5151, -1, 18041},
      {-80674, 88350, -5151, -1, 18041},
      {-80209, 88833, -5151, -1, 18046},
      {-79743, 88364, -5151, -1, 18046}
    },
    {
      # No Level Limit - Offering of Forbidden Path
      {-80624, 84060, -5151, -1, 18049},
      {-80621, 84007, -5151, -1, 18050},
      {-80590, 84039, -5151, -1, 18050},

      {-80605, 85349, -5151, -1, 18049},
      {-80639, 85363, -5151, -1, 18050},
      {-80611, 85385, -5151, -1, 18050},

      {-79311, 85353, -5151, -1, 18052},
      {-79277, 85384, -5151, -1, 18053},
      {-79273, 85539, -5151, -1, 18054},

      {-79297, 84054, -5151, -1, 18055},
      {-79285, 84006, -5151, -1, 18057},
      {-79260, 84040, -5151, -1, 18058},

      # Archers and Marksmen
      {-79945, 85171, -5151, -1, 18051},
      {-79489, 84707, -5151, -1, 18051},
      {-79952, 84222, -5151, -1, 18056},
      {-80423, 84703, -5151, -1, 18056}
    }
  }

  FESTIVAL_DAWN_SECONDARY_SPAWNS = {
    {
      # 31 and Below
      {-78757, 112834, -4895, -1, 18016},
      {-78581, 112834, -4895, -1, 18016},
      {-78822, 112526, -4895, -1, 18011},

      {-78822, 113702, -4895, -1, 18011},
      {-78822, 113874, -4895, -1, 18011},
      {-79524, 113546, -4895, -1, 18011},

      {-79693, 113546, -4895, -1, 18011},
      {-79858, 113546, -4895, -1, 18011},
      {-79545, 112757, -4895, -1, 18016},
      {-79545, 112586, -4895, -1, 18016},
    },
    {
      # 42 and Below
      {-75565, 110580, -4895, -1, 18026},
      {-75565, 110740, -4895, -1, 18026},
      {-75577, 109776, -4895, -1, 18021},

      {-75413, 109776, -4895, -1, 18021},
      {-75237, 109776, -4895, -1, 18021},
      {-76274, 109468, -4895, -1, 18021},

      {-76274, 109635, -4895, -1, 18021},
      {-76274, 109795, -4895, -1, 18021},
      {-76351, 110500, -4895, -1, 18056},
      {-76528, 110500, -4895, -1, 18056},
    },
    {
      # 53 and Below
      {-74191, 111527, -4895, -1, 18036},
      {-74191, 111362, -4895, -1, 18036},
      {-73495, 111611, -4895, -1, 18031},

      {-73327, 111611, -4895, -1, 18031},
      {-73154, 111611, -4895, -1, 18031},
      {-73473, 112301, -4895, -1, 18031},

      {-73473, 112475, -4895, -1, 18031},
      {-73473, 112649, -4895, -1, 18031},
      {-74270, 112326, -4895, -1, 18036},
      {-74443, 112326, -4895, -1, 18036},
    },
    {
      # 64 and Below
      {-75738, 113439, -4895, -1, 18046},
      {-75571, 113439, -4895, -1, 18046},
      {-75824, 114141, -4895, -1, 18041},

      {-75824, 114309, -4895, -1, 18041},
      {-75824, 114477, -4895, -1, 18041},
      {-76513, 114158, -4895, -1, 18041},

      {-76683, 114158, -4895, -1, 18041},
      {-76857, 114158, -4895, -1, 18041},
      {-76535, 113357, -4895, -1, 18056},
      {-76535, 113190, -4895, -1, 18056},
    },
    {
      # No Level Limit
      {-79350, 109894, -4895, -1, 18056},
      {-79534, 109894, -4895, -1, 18056},
      {-79285, 109187, -4895, -1, 18051},

      {-79285, 109019, -4895, -1, 18051},
      {-79285, 108860, -4895, -1, 18051},
      {-78587, 109172, -4895, -1, 18051},

      {-78415, 109172, -4895, -1, 18051},
      {-78249, 109172, -4895, -1, 18051},
      {-78575, 109961, -4895, -1, 18056},
      {-78575, 110130, -4895, -1, 18056},
    }
  }

  FESTIVAL_DUSK_SECONDARY_SPAWNS = {
    {
      # 31 and Below
      {-76844, 89304, -5151, -1, 18011},
      {-76844, 89479, -5151, -1, 18011},
      {-76844, 89649, -5151, -1, 18011},

      {-77544, 89326, -5151, -1, 18011},
      {-77716, 89326, -5151, -1, 18011},
      {-77881, 89326, -5151, -1, 18011},

      {-77561, 88530, -5151, -1, 18016},
      {-77561, 88364, -5151, -1, 18016},
      {-76762, 88615, -5151, -1, 18016},
      {-76594, 88615, -5151, -1, 18016},
    },
    {
      # 42 and Below
      {-77307, 84969, -5151, -1, 18021},
      {-77307, 84795, -5151, -1, 18021},
      {-77307, 84623, -5151, -1, 18021},

      {-76614, 84944, -5151, -1, 18021},
      {-76433, 84944, -5151, -1, 18021},
      {-76251, 84944, -5151, -1, 18021},

      {-76594, 85745, -5151, -1, 18026},
      {-76594, 85910, -5151, -1, 18026},
      {-77384, 85660, -5151, -1, 18026},
      {-77555, 85660, -5151, -1, 18026},
    },
    {
      # 53 and Below
      {-74517, 86782, -5151, -1, 18031},
      {-74344, 86782, -5151, -1, 18031},
      {-74185, 86782, -5151, -1, 18031},

      {-74496, 87464, -5151, -1, 18031},
      {-74496, 87636, -5151, -1, 18031},
      {-74496, 87815, -5151, -1, 18031},

      {-75298, 87497, -5151, -1, 18036},
      {-75460, 87497, -5151, -1, 18036},
      {-75219, 86712, -5151, -1, 18036},
      {-75219, 86531, -5151, -1, 18036},
    },
    {
      # 64 and Below
      {-79851, 88703, -5151, -1, 18041},
      {-79851, 88868, -5151, -1, 18041},
      {-79851, 89040, -5151, -1, 18041},

      {-80548, 88722, -5151, -1, 18041},
      {-80711, 88722, -5151, -1, 18041},
      {-80883, 88722, -5151, -1, 18041},

      {-80565, 87916, -5151, -1, 18046},
      {-80565, 87752, -5151, -1, 18046},
      {-79779, 87996, -5151, -1, 18046},
      {-79613, 87996, -5151, -1, 18046},
    },
    {
      # No Level Limit
      {-79271, 84330, -5151, -1, 18051},
      {-79448, 84330, -5151, -1, 18051},
      {-79601, 84330, -5151, -1, 18051},

      {-80311, 84367, -5151, -1, 18051},
      {-80311, 84196, -5151, -1, 18051},
      {-80311, 84015, -5151, -1, 18051},

      {-80556, 85049, -5151, -1, 18056},
      {-80384, 85049, -5151, -1, 18056},
      {-79598, 85127, -5151, -1, 18056},
      {-79598, 85303, -5151, -1, 18056},
    }
  }

  FESTIVAL_DAWN_CHEST_SPAWNS = {
    {
      # Level 31 and Below
      {-78999, 112957, -4927, -1, 18109},
      {-79153, 112873, -4927, -1, 18109},
      {-79256, 112873, -4927, -1, 18109},

      {-79368, 112957, -4927, -1, 18109},
      {-79481, 113124, -4927, -1, 18109},
      {-79481, 113275, -4927, -1, 18109},

      {-79364, 113398, -4927, -1, 18109},
      {-79213, 113500, -4927, -1, 18109},
      {-79099, 113500, -4927, -1, 18109},

      {-78960, 113398, -4927, -1, 18109},
      {-78882, 113235, -4927, -1, 18109},
      {-78882, 113099, -4927, -1, 18109},
    },
    {
      # Level 42 and Below
      {-76119, 110383, -4927, -1, 18110},
      {-75980, 110442, -4927, -1, 18110},
      {-75848, 110442, -4927, -1, 18110},

      {-75720, 110383, -4927, -1, 18110},
      {-75625, 110195, -4927, -1, 18110},
      {-75625, 110063, -4927, -1, 18110},

      {-75722, 109908, -4927, -1, 18110},
      {-75863, 109832, -4927, -1, 18110},
      {-75989, 109832, -4927, -1, 18110},

      {-76130, 109908, -4927, -1, 18110},
      {-76230, 110079, -4927, -1, 18110},
      {-76230, 110215, -4927, -1, 18110},
    },
    {
      # Level 53 and Below
      {-74055, 111781, -4927, -1, 18111},
      {-74144, 111938, -4927, -1, 18111},
      {-74144, 112075, -4927, -1, 18111},

      {-74055, 112173, -4927, -1, 18111},
      {-73885, 112289, -4927, -1, 18111},
      {-73756, 112289, -4927, -1, 18111},

      {-73574, 112141, -4927, -1, 18111},
      {-73511, 112040, -4927, -1, 18111},
      {-73511, 111912, -4927, -1, 18111},

      {-73574, 111772, -4927, -1, 18111},
      {-73767, 111669, -4927, -1, 18111},
      {-73899, 111669, -4927, -1, 18111},
    },
    {
      # Level 64 and Below
      {-76008, 113566, -4927, -1, 18112},
      {-76159, 113485, -4927, -1, 18112},
      {-76267, 113485, -4927, -1, 18112},

      {-76386, 113566, -4927, -1, 18112},
      {-76482, 113748, -4927, -1, 18112},
      {-76482, 113885, -4927, -1, 18112},

      {-76371, 114029, -4927, -1, 18112},
      {-76220, 114118, -4927, -1, 18112},
      {-76092, 114118, -4927, -1, 18112},

      {-75975, 114029, -4927, -1, 18112},
      {-75861, 113851, -4927, -1, 18112},
      {-75861, 113713, -4927, -1, 18112},
    },
    {
      # No Level Limit
      {-79100, 109782, -4927, -1, 18113},
      {-78962, 109853, -4927, -1, 18113},
      {-78851, 109853, -4927, -1, 18113},

      {-78721, 109782, -4927, -1, 18113},
      {-78615, 109596, -4927, -1, 18113},
      {-78615, 109453, -4927, -1, 18113},

      {-78746, 109300, -4927, -1, 18113},
      {-78881, 109203, -4927, -1, 18113},
      {-79027, 109203, -4927, -1, 18113},

      {-79159, 109300, -4927, -1, 18113},
      {-79240, 109480, -4927, -1, 18113},
      {-79240, 109615, -4927, -1, 18113},
    }
  }

  FESTIVAL_DUSK_CHEST_SPAWNS = {
    {
      # Level 31 and Below
      {-77016, 88726, -5183, -1, 18114},
      {-77136, 88646, -5183, -1, 18114},
      {-77247, 88646, -5183, -1, 18114},

      {-77380, 88726, -5183, -1, 18114},
      {-77512, 88883, -5183, -1, 18114},
      {-77512, 89053, -5183, -1, 18114},

      {-77378, 89287, -5183, -1, 18114},
      {-77254, 89238, -5183, -1, 18114},
      {-77095, 89238, -5183, -1, 18114},

      {-76996, 89287, -5183, -1, 18114},
      {-76901, 89025, -5183, -1, 18114},
      {-76901, 88891, -5183, -1, 18114},
    },
    {
      # Level 42 and Below
      {-77128, 85553, -5183, -1, 18115},
      {-77036, 85594, -5183, -1, 18115},
      {-76919, 85594, -5183, -1, 18115},

      {-76755, 85553, -5183, -1, 18115},
      {-76635, 85392, -5183, -1, 18115},
      {-76635, 85216, -5183, -1, 18115},

      {-76761, 85025, -5183, -1, 18115},
      {-76908, 85004, -5183, -1, 18115},
      {-77041, 85004, -5183, -1, 18115},

      {-77138, 85025, -5183, -1, 18115},
      {-77268, 85219, -5183, -1, 18115},
      {-77268, 85410, -5183, -1, 18115},
    },
    {
      # Level 53 and Below
      {-75150, 87303, -5183, -1, 18116},
      {-75150, 87175, -5183, -1, 18116},
      {-75150, 87175, -5183, -1, 18116},

      {-75150, 87303, -5183, -1, 18116},
      {-74943, 87433, -5183, -1, 18116},
      {-74767, 87433, -5183, -1, 18116},

      {-74556, 87306, -5183, -1, 18116},
      {-74556, 87184, -5183, -1, 18116},
      {-74556, 87184, -5183, -1, 18116},

      {-74556, 87306, -5183, -1, 18116},
      {-74757, 86830, -5183, -1, 18116},
      {-74927, 86830, -5183, -1, 18116},
    },
    {
      # Level 64 and Below
      {-80010, 88128, -5183, -1, 18117},
      {-80113, 88066, -5183, -1, 18117},
      {-80220, 88066, -5183, -1, 18117},

      {-80359, 88128, -5183, -1, 18117},
      {-80467, 88267, -5183, -1, 18117},
      {-80467, 88436, -5183, -1, 18117},

      {-80381, 88639, -5183, -1, 18117},
      {-80278, 88577, -5183, -1, 18117},
      {-80142, 88577, -5183, -1, 18117},

      {-80028, 88639, -5183, -1, 18117},
      {-79915, 88466, -5183, -1, 18117},
      {-79915, 88322, -5183, -1, 18117},
    },
    {
      # No Level Limit
      {-80153, 84947, -5183, -1, 18118},
      {-80003, 84962, -5183, -1, 18118},
      {-79848, 84962, -5183, -1, 18118},

      {-79742, 84947, -5183, -1, 18118},
      {-79668, 84772, -5183, -1, 18118},
      {-79668, 84619, -5183, -1, 18118},

      {-79772, 84471, -5183, -1, 18118},
      {-79888, 84414, -5183, -1, 18118},
      {-80023, 84414, -5183, -1, 18118},

      {-80166, 84471, -5183, -1, 18118},
      {-80253, 84600, -5183, -1, 18118},
      {-80253, 84780, -5183, -1, 18118},
    }
  }

  private ACCUMULATED_BONUSES = Slice(Int32).new(FESTIVAL_COUNT)
  private DAWN_FESTIVAL_PARTICIPANTS = {} of Int32 => Array(Int32)
  private DUSK_FESTIVAL_PARTICIPANTS = {} of Int32 => Array(Int32)
  private DAWN_PREVIOUS_PARTICIPANTS = {} of Int32 => Array(Int32)
  private DUSK_PREVIOUS_PARTICIPANTS = {} of Int32 => Array(Int32)
  private DAWN_FESTIVAL_SCORES = {} of Int32 => Int64
  private DUSK_FESTIVAL_SCORES = {} of Int32 => Int64
  private FESTIVAL_DATA = {} of Int32 => Hash(Int32, StatsSet)

  @@manager_instance : FestivalManager?
  @@manager_scheduled_task : Runnable::PeriodicTask?
  class_property signs_cycle : Int32 = 0
  class_property festival_cycle : Int32 = 0
  @@next_festival_cycle_start = 0i64
  class_property next_festival_start : Int64 = 0i64
  class_property? festival_initialized : Bool = false
  class_property? festival_in_progress : Bool = false
  class_property? no_party_register : Bool = false
  @@dawn_chat_guide : L2Npc?
  @@dusk_chat_guide : L2Npc?

  def load
    restore_festival_data

    @@signs_cycle = SevenSigns.current_cycle

    if SevenSigns.seal_validation_period?
      info "Initialization bypassed due to Seal Validation being in effect."
      return
    end

    L2Spawn.add_spawn_listener(self)

    start_festival_manager
  end

  def festival_signup_time : Int64
    Config.alt_festival_cycle_length.to_i64 - Config.alt_festival_length - 60000
  end

  def get_festival_name(id : Int) : String
    case id
    when FESTIVAL_LEVEL_MAX_31
      "Level 31 or lower"
    when FESTIVAL_LEVEL_MAX_42
      "Level 42 or lower"
    when FESTIVAL_LEVEL_MAX_53
      "Level 53 or lower"
    when FESTIVAL_LEVEL_MAX_64
      "Level 64 or lower"
    else
      "No Level Limit"
    end
  end

  def get_max_level_for_festival(id : Int) : Int32
    case id
    when FESTIVAL_LEVEL_MAX_31
      31
    when FESTIVAL_LEVEL_MAX_42
      42
    when FESTIVAL_LEVEL_MAX_53
      53
    when FESTIVAL_LEVEL_MAX_64
      64
    else
      Config.max_player_level - 1
    end
  end

  def festival_archer?(npc_id : Int) : Bool
    return false unless 18009 <= npc_id <= 18108
    identifier = npc_id % 10
    identifier == 4 || identifier == 9
  end

  def festival_chest?(npc_id : Int) : Bool
    npc_id < 18109 || npc_id > 18118
    !(18109 <= npc_id <= 18118)
  end

  def festival_manager_schedule : Runnable::PeriodicTask
    @@manager_scheduled_task || start_festival_manager
    @@manager_scheduled_task.not_nil!
  end

  def start_festival_manager
    return if @@manager_instance
    @@manager_instance = FestivalManager.new
    set_next_festival_start(Config.alt_festival_manager_start + SevenSignsFestival.festival_signup_time)
    @@manager_scheduled_task = ThreadPoolManager.schedule_general_at_fixed_rate(@@manager_instance.not_nil!, Config.alt_festival_manager_start, Config.alt_festival_cycle_length)
    info "The first Festival of Darkness cycle begins in #{Time.ms_to_mins(Config.alt_festival_manager_start)} minutes."
  end

  def restore_festival_data
    begin
      sql = "SELECT festivalId, cabal, cycle, date, score, members FROM seven_signs_festival"
      GameDB.each(sql) do |rs|
        festival_cycle = rs.get_i32("cycle")
        festival_id = rs.get_i32("festivalId")
        cabal = rs.get_string("cabal")

        dat = StatsSet.new
        dat["festivalId"] = festival_id
        dat["cabal"] = cabal
        dat["cycle"] = festival_cycle
        dat["date"] = rs.get_i64("date").to_s
        dat["score"] = rs.get_i32("score")
        dat["members"] = rs.get_string("members")
        if cabal == "dawn"
          festival_id += FESTIVAL_COUNT
        end
        temp = FESTIVAL_DATA[festival_cycle] ||= {} of Int32 => StatsSet
        temp[festival_id] = dat
        # should be reflected inside FESTIVAL_DATA now
      end
    rescue e
      error e
    end

    begin
      query = String.build(300) do |io|
        io << "SELECT festival_cycle, "
        FESTIVAL_COUNT.times do |i|
          io << "accumulated_bonus"
          io << i
          io << ", "
        end
        io << "accumulated_bonus"
        io << FESTIVAL_COUNT - 1
        io << ' '
        io << "FROM seven_signs_status WHERE id=0"
      end

      GameDB.each(query) do |rs|
        @@festival_cycle = rs.get_i32("festival_cycle")
        FESTIVAL_COUNT.times do |i|
          ACCUMULATED_BONUSES[i] = rs.get_i32("accumulated_bonus#{i}")
        end
      end
    rescue e
      error e
    end
  end

  def save_festival_data(update_settings : Bool)
    sql = "REPLACE INTO seven_signs_festival (festivalId, cabal, cycle, date, score, members) VALUES (?,?,?,?,?,?)"
    begin
      FESTIVAL_DATA.each_value do |val|
        val.each_value do |dat|
          GameDB.exec(
            sql,
            dat.get_i32("festivalId"),
            dat.get_string("cabal"),
            dat.get_i32("cycle"),
            dat.get_string("date").to_i64,
            dat.get_i32("score"),
            dat.get_string("members")
          )
        end
      end
    rescue e
      error e
    end

    if update_settings
      SevenSigns.save_seven_signs_status
    end
  end

  def reward_highest_ranked
    if data = get_overall_highest_score_data(FESTIVAL_LEVEL_MAX_31)
      data.get_string("members").split(',').each do |name|
        add_reputation_points_for_party_member_clan(name)
      end
    end

    if data = get_overall_highest_score_data(FESTIVAL_LEVEL_MAX_42)
      data.get_string("members").split(',').each do |name|
        add_reputation_points_for_party_member_clan(name)
      end
    end

    if data = get_overall_highest_score_data(FESTIVAL_LEVEL_MAX_53)
      data.get_string("members").split(',').each do |name|
        add_reputation_points_for_party_member_clan(name)
      end
    end

    if data = get_overall_highest_score_data(FESTIVAL_LEVEL_MAX_64)
      data.get_string("members").split(',').each do |name|
        add_reputation_points_for_party_member_clan(name)
      end
    end

    if data = get_overall_highest_score_data(FESTIVAL_LEVEL_MAX_NONE)
      data.get_string("members").split(',').each do |name|
        add_reputation_points_for_party_member_clan(name)
      end
    end
  end

  private def add_reputation_points_for_party_member_clan(name : String)
    if pc = L2World.get_player(name)
      if clan = pc.clan?
        clan.add_reputation_score(Config.festival_win_points, true)
        sm = Packets::Outgoing::SystemMessage.clan_member_c1_was_in_highest_ranked_party_in_festival_of_darkness_and_gained_s2_reputation
        sm.add_string(name)
        sm.add_int(Config.festival_win_points)
        clan.broadcast_to_online_members(sm)
      end
    else
      GameDB.each(GET_CLAN_NAME, name) do |rs|
        if clan_name = rs.get_string?("clan_name")
          if clan = ClanTable.get_clan_by_name(clan_name)
            clan.add_reputation_score(Config.festival_win_points, true)
            sm = Packets::Outgoing::SystemMessage.clan_member_c1_was_in_highest_ranked_party_in_festival_of_darkness_and_gained_s2_reputation
            sm.add_string(name)
            sm.add_int(Config.festival_win_points)
            clan.broadcast_to_online_members(sm)
          else
            warn "No clan found with name #{name.inspect}."
          end
        else
          warn "clan_name column is nil."
        end
      end
    end
  end

  def reset_festival_data(update_settings : Bool)
    @@festival_cycle = 0
    @@signs_cycle = SevenSigns.current_cycle

    FESTIVAL_COUNT.times do |i|
      ACCUMULATED_BONUSES[i] = 0
    end

    DAWN_FESTIVAL_PARTICIPANTS.clear
    DAWN_PREVIOUS_PARTICIPANTS.clear
    DAWN_FESTIVAL_SCORES.clear
    DUSK_FESTIVAL_PARTICIPANTS.clear
    DUSK_PREVIOUS_PARTICIPANTS.clear
    DUSK_FESTIVAL_SCORES.clear

    new_data = {} of Int32 => StatsSet

    (FESTIVAL_COUNT * 2).times do |i|
      festival_id = i
      if i >= FESTIVAL_COUNT
        festival_id -= FESTIVAL_COUNT
      end

      temp = StatsSet.new
      temp["festivalId"] = festival_id
      temp["cycle"] = @@signs_cycle
      temp["date"] = "0"
      temp["score"] = 0
      temp["members"] = ""

      if i >= FESTIVAL_COUNT
        temp["cabal"] = SevenSigns.get_cabal_short_name(SevenSigns::CABAL_DAWN)
      else
        temp["cabal"] = SevenSigns.get_cabal_short_name(SevenSigns::CABAL_DUSK)
      end

      new_data[i] = temp
    end

    FESTIVAL_DATA[@@signs_cycle] = new_data

    save_festival_data(update_settings)

    L2World.players.each do |pc|
      if offerings = pc.inventory.get_item_by_item_id(FESTIVAL_OFFERING_ID)
        pc.destroy_item("SevenSigns", offerings, nil, false)
      end
    end

    info "Reinitialized engine for next competition period."
  end

  def current_festival_cycle : Int32
    @@festival_cycle
  end

  def festival_initialized? : Bool
    @@festival_initialized
  end

  def festival_in_progress? : Bool
    @@festival_in_progress
  end

  def set_next_cycle_start
    @@next_festival_cycle_start = Time.ms + Config.alt_festival_cycle_length
  end

  def set_next_festival_start(ms : Int64)
    @@next_festival_start = Time.ms + ms
  end

  def mins_to_next_cycle : Int64
    if SevenSigns.seal_validation_period?
      -1i64
    else
      (@@next_festival_cycle_start - Time.ms) / 60000
    end
  end

  def mins_to_next_festival : Int32
    if SevenSigns.seal_validation_period?
      -1
    else
      (((@@next_festival_start - Time.ms) / 60000) + 1).to_i32
    end
  end

  def time_to_next_festival_str : String
    if SevenSigns.seal_validation_period?
      "<font color=\"FF0000\">This is the Seal Validation period. Festivals will resume next week.</font>"
    else
      "<font color=\"FF0000\">The next festival will begin in #{mins_to_next_festival} minute(s).</font>"
    end
  end

  def get_festival_for_player(pc : L2PcInstance) : {Int32, Int32}
    FESTIVAL_COUNT.times do |id|
      if DAWN_FESTIVAL_PARTICIPANTS[id]?.try &.includes?(pc.l2id)
        return {SevenSigns::CABAL_DAWN, id}
      end

      if DUSK_FESTIVAL_PARTICIPANTS[id]?.try &.includes?(pc.l2id)
        return {SevenSigns::CABAL_DUSK, id}
      end
    end

    {-1, -1}
  end

  def participant?(pc : L2PcInstance) : Bool
    return false if SevenSigns.seal_validation_period?
    return false unless @@manager_instance

    id = pc.l2id
    DAWN_FESTIVAL_PARTICIPANTS.each_value do |participants|
      return true if participants.includes?(id)
    end
    DUSK_FESTIVAL_PARTICIPANTS.each_value do |participants|
      return true if participants.includes?(id)
    end

    false
  end

  def get_participants(oracle : Int, festival_id : Int) : Array(Int32)?
    if oracle == SevenSigns::CABAL_DAWN
      DAWN_FESTIVAL_PARTICIPANTS[festival_id]?
    else
      DUSK_FESTIVAL_PARTICIPANTS[festival_id]?
    end
  end

  def get_previous_participants(oracle : Int, festival_id : Int) : Array(Int32)?
    if oracle == SevenSigns::CABAL_DAWN
      DAWN_PREVIOUS_PARTICIPANTS[festival_id]?
    else
      DUSK_PREVIOUS_PARTICIPANTS[festival_id]?
    end
  end

  def set_participants(oracle : Int, festival_id : Int, festival_party : L2Party?)
    if festival_party
      participants = festival_party.members_l2id
    end

    if oracle == SevenSigns::CABAL_DAWN
      if participants
        DAWN_FESTIVAL_PARTICIPANTS[festival_id] = participants
      else
        DAWN_FESTIVAL_PARTICIPANTS.delete(festival_id)
      end
    else
      if participants
        DUSK_FESTIVAL_PARTICIPANTS[festival_id] = participants
      else
        DUSK_FESTIVAL_PARTICIPANTS.delete(festival_id)
      end
    end
  end

  def update_participants(pc : L2PcInstance, festival_party : L2Party?)
    return unless participant?(pc)

    oracle, festival_id = get_festival_for_player(pc)
    return unless festival_id > -1
    if @@festival_initialized
      festival_inst = @@manager_instance.not_nil!.get_festival_instance(oracle, festival_id)
      if festival_party.nil?
        get_participants(oracle, festival_id).not_nil!.each do |id|
          if member = L2World.get_player(id)
            festival_inst.not_nil!.relocate_player(member, true)
          end
        end
      else
        festival_inst.not_nil!.relocate_player(pc, true)
      end
    end

    set_participants(oracle, festival_id, festival_party)

    if festival_party && festival_party.size < Config.alt_festival_min_player
      update_participants(pc, nil)
      festival_party.remove_party_member(pc, L2Party::MessageType::Expelled)
    end
  end

  def get_final_score(oracle : Int, festival_id : Int) : Int64
    if oracle == SevenSigns::CABAL_DAWN
      DAWN_FESTIVAL_SCORES[festival_id]
    else
      DUSK_FESTIVAL_SCORES[festival_id]
    end
  end

  def get_highest_score(oracle : Int, festival_id : Int) : Int32
    get_highest_score_data(oracle, festival_id).get_i32("score")
  end

  def get_highest_score_data(oracle : Int, festival_id : Int) : StatsSet
    offset_id = festival_id

    if oracle == SevenSigns::CABAL_DAWN
      offset_id += 5
    end

    FESTIVAL_DATA[@@signs_cycle]?.try &.[offset_id]? || begin
      data = StatsSet.new
      data["score"] = 0
      data["members"] = ""
      data
    end
  end

  def get_overall_highest_score_data(festival_id : Int) : StatsSet?
    highest_score = 0
    result = nil

    FESTIVAL_DATA.each_value do |hash|
      hash.each_value do |data|
        id = data.get_i32("festivalId")
        score = data.get_i32("score")
        if festival_id != id
          next
        end
        if score > highest_score
          highest_score = score
          result = data
        end
      end
    end

    result
  end

  def set_final_score(pc : L2PcInstance, oracle : Int32, festival_id : Int32, offering_score : Int64) : Bool
    dawn_score = get_highest_score(SevenSigns::CABAL_DAWN, festival_id)
    dusk_score = get_highest_score(SevenSigns::CABAL_DUSK, festival_id)

    this_score = other_score = 0

    if oracle == SevenSigns::CABAL_DAWN
      this_score = dawn_score
      other_score = dusk_score
      DAWN_FESTIVAL_SCORES[festival_id] = offering_score
    else
      this_score = dusk_score
      other_score = dawn_score
      DUSK_FESTIVAL_SCORES[festival_id] = offering_score
    end

    data = get_highest_score_data(oracle, festival_id)

    if offering_score > this_score
      if this_score > other_score
        return false
      end

      unless temp = get_previous_participants(oracle, festival_id)
        raise "Couldn't get previous participants (oracle: #{oracle}, festival_id: #{festival_id})"
      end

      members = temp.map do |id|
        CharNameTable.get_name_by_id(id).not_nil!
      end

      data["date"] = Time.ms.to_s
      data["score"] = offering_score
      data["members"] = members.join(',')

      if offering_score > other_score
        points = FESTIVAL_LEVEL_SCORES[festival_id]
        SevenSigns.add_festival_score(oracle, points)
      end

      save_festival_data(true)

      return true
    end

    false
  end

  def get_accumulated_bonus(festival_id : Int) : Int32
    ACCUMULATED_BONUSES[festival_id]
  end

  def total_accumulated_bonus : Int32
    ACCUMULATED_BONUSES.sum
  end

  def add_accumulated_bonus(festival_id : Int32, stone_type : Int32, stone_amount : Int32)
    bonus = 0

    case stone_type
    when SevenSigns::SEAL_STONE_BLUE_ID
      bonus = SevenSigns::SEAL_STONE_BLUE_VALUE
    when SevenSigns::SEAL_STONE_GREEN_ID
      bonus = SevenSigns::SEAL_STONE_GREEN_VALUE
    when SevenSigns::SEAL_STONE_RED_ID
      bonus = SevenSigns::SEAL_STONE_RED_VALUE
    end

    total = ACCUMULATED_BONUSES[festival_id] + (stone_amount * bonus)
    ACCUMULATED_BONUSES[festival_id] = total
  end

  def distrib_accumulated_bonus(pc : L2PcInstance) : Int32
    bonus = 0
    name = pc.name
    cabal = SevenSigns.get_player_cabal(pc.l2id)

    if cabal != SevenSigns.cabal_highest_score
      return 0
    end

    if temp = FESTIVAL_DATA[@@signs_cycle]?
      temp.each_value do |data|
        if data.get_string("members").index(name)
          festival_id = data.get_i32("festival_id")
          num_party_members = data.get_string("members").split(',').size
          total_accum_bonus = ACCUMULATED_BONUSES[festival_id]

          bonus = total_accum_bonus / num_party_members
          ACCUMULATED_BONUSES[festival_id] = total_accum_bonus - bonus
          break
        end
      end
    end

    bonus
  end

  def send_message_to_all(name : String, string : NpcString)
    return unless @@dawn_chat_guide && @@dusk_chat_guide
      send_message_to_all(name, string, @@dawn_chat_guide.not_nil!)
      send_message_to_all(name, string, @@dusk_chat_guide.not_nil!)
  end

  def send_message_to_all(name : String, string : NpcString, npc : L2Npc)
    cs = Packets::Outgoing::CreatureSay.new(npc.l2id, Packets::Incoming::Say2::NPC_SHOUT, name, string)
    if string.param_count == 1
      cs.add_string(mins_to_next_festival.to_s)
    end
    npc.broadcast_packet(cs)
  end

  def increase_challenge(oracle : Int32, festival_id : Int32) : Bool
    @@manager_instance.not_nil!
    .get_festival_instance(oracle, festival_id).not_nil!
    .increase_challenge
  end

  def npc_spawned(npc : L2Npc?)
    return unless npc
    case npc.id
    when 31127
      @@dawn_chat_guide = npc
    when 31137
      @@dusk_chat_guide = npc
    end
  end

  private class FestivalManager
    include Runnable
    include Loggable

    @festival_instances = {} of Int32 => L2DarknessFestival

    def initialize
      SevenSignsFestival.festival_cycle += 1
      SevenSignsFestival.set_next_cycle_start
      SevenSignsFestival.set_next_festival_start(
        Config.alt_festival_cycle_length - SevenSignsFestival.festival_signup_time
      )
    end

    def run
      return if SevenSigns.seal_validation_period?

      if SevenSigns.milli_to_period_change < Config.alt_festival_cycle_length
        return
      elsif SevenSignsFestival.mins_to_next_festival == 2
        SevenSignsFestival.send_message_to_all("Festival Guide", NpcString::THE_MAIN_EVENT_WILL_START_IN_2_MINUTES_PLEASE_REGISTER_NOW)
      end

      wait(SevenSignsFestival.festival_signup_time)

      DAWN_PREVIOUS_PARTICIPANTS.clear
      DUSK_PREVIOUS_PARTICIPANTS.clear

      @festival_instances.each_value &.unspawn_mobs

      SevenSignsFestival.no_party_register = true

      while SevenSignsFestival.no_party_register?
        if DUSK_FESTIVAL_PARTICIPANTS.empty? && DAWN_FESTIVAL_PARTICIPANTS.empty?
          SevenSignsFestival.set_next_cycle_start
          SevenSignsFestival.set_next_festival_start(
            Config.alt_festival_cycle_length - SevenSignsFestival.festival_signup_time
          )
          wait(Config.alt_festival_cycle_length - SevenSignsFestival.festival_signup_time)
          @festival_instances.each_value do |inst|
            unless inst.npc_instances.empty?
              inst.unspawn_mobs
            end
          end
        else
          SevenSignsFestival.no_party_register = false
        end
      end

      elapsed_time = 0

      FESTIVAL_COUNT.times do |i|
        if DUSK_FESTIVAL_PARTICIPANTS[i]?
          @festival_instances[i + 10] = L2DarknessFestival.new(SevenSigns::CABAL_DUSK, i)
        end

        if DAWN_FESTIVAL_PARTICIPANTS[i]?
          @festival_instances[i + 20] = L2DarknessFestival.new(SevenSigns::CABAL_DAWN, i)
        end
      end

      SevenSignsFestival.festival_initialized = true

      SevenSignsFestival.next_festival_start = Config.alt_festival_cycle_length
      SevenSignsFestival.send_message_to_all(
        "Festival Guide", NpcString::THE_MAIN_EVENT_IS_NOW_STARTING
      )

      wait(Config.alt_festival_first_spawn)

      elapsed_time = Config.alt_festival_first_spawn

      SevenSignsFestival.festival_in_progress = true

      @festival_instances.each_value do |inst|
        inst.festival_start
        inst.send_message_to_participants(NpcString::THE_MAIN_EVENT_IS_NOW_STARTING)
      end

      wait(Config.alt_festival_first_swarm - Config.alt_festival_first_spawn)

      elapsed_time += Config.alt_festival_first_swarm - Config.alt_festival_first_spawn

      @festival_instances.each_value &.move_monsters_to_center

      wait(Config.alt_festival_second_spawn - Config.alt_festival_first_swarm)

      @festival_instances.each_value do |inst|
        inst.spawn_festival_monsters(FESTIVAL_DEFAULT_RESPAWN / 2, 2)
        _end = (Config.alt_festival_length - Config.alt_festival_second_spawn) / 60000
        if _end == 2
          inst.send_message_to_participants(NpcString::THE_FESTIVAL_OF_DARKNESS_WILL_END_IN_TWO_MINUTES)
        else
          inst.send_message_to_participants("The Festival of Darkness will end in #{_end} minute(s).")
        end
      end

      elapsed_time += Config.alt_festival_second_spawn - Config.alt_festival_first_swarm

      wait(Config.alt_festival_second_swarm - Config.alt_festival_second_spawn)

      @festival_instances.each_value &.move_monsters_to_center

      elapsed_time += Config.alt_festival_second_swarm - Config.alt_festival_second_spawn

      wait(Config.alt_festival_chest_spawn - Config.alt_festival_second_swarm)

      @festival_instances.each_value do |inst|
        inst.spawn_festival_monsters(FESTIVAL_DEFAULT_RESPAWN, 3)
        inst.send_message_to_participants("The chests have spawned! Be quick, the festival will end soon.")
      end

      elapsed_time += Config.alt_festival_chest_spawn - Config.alt_festival_second_swarm

      wait(Config.alt_festival_length - elapsed_time)

      SevenSignsFestival.festival_in_progress = false

      @festival_instances.each_value &.festival_end

      DAWN_FESTIVAL_PARTICIPANTS.clear
      DUSK_FESTIVAL_PARTICIPANTS.clear

      SevenSignsFestival.festival_initialized = false

      SevenSignsFestival.send_message_to_all("Festival Witch", NpcString::THAT_WILL_DO_ILL_MOVE_YOU_TO_THE_OUTSIDE_SOON)
    rescue e
      error e
    end

    def wait(time)
      sleep(Time.ms_to_s(time))
    end

    def get_festival_instance(oracle : Int, festival_id : Int) : L2DarknessFestival?
      return unless SevenSignsFestival.festival_initialized?
      festival_id += oracle == SevenSigns::CABAL_DUSK ? 10 : 20
      @festival_instances[festival_id]?
    end
  end

  private class L2DarknessFestival
    getter witch_instance : L2Npc?
    getter npc_instances = [] of L2FestivalMonsterInstance
    getter participants = [] of Int32
    getter cabal
    getter original_locations = {} of Int32 => FestivalSpawn
    getter level_range
    getter witch_spawn
    getter start_location
    @challenge_increased = false

    def initialize(@cabal : Int32, @level_range : Int32)
      if cabal == SevenSigns::CABAL_DAWN
        @participants = DAWN_FESTIVAL_PARTICIPANTS[level_range]
        @witch_spawn = FestivalSpawn.new(FESTIVAL_DAWN_WITCH_SPAWNS[level_range])
        @start_location = FestivalSpawn.new(FESTIVAL_DAWN_PLAYER_SPAWNS[level_range])
      else
        @participants = DUSK_FESTIVAL_PARTICIPANTS[level_range]
        @witch_spawn = FestivalSpawn.new(FESTIVAL_DUSK_WITCH_SPAWNS[level_range])
        @start_location = FestivalSpawn.new(FESTIVAL_DUSK_PLAYER_SPAWNS[level_range])
      end

      festival_init
    end

    def festival_init
      positive = false

      @participants.each do |id|
        next unless pc = L2World.get_player(id)
        @original_locations[id] = FestivalSpawn.new(*pc.xyz, pc.heading)
        x, y = @start_location.x, @start_location.y
        if positive = Rnd.bool
          x += Rnd.rand(FESTIVAL_MAX_OFFSET_X)
          y += Rnd.rand(FESTIVAL_MAX_OFFSET_Y)
        else
          x -= Rnd.rand(FESTIVAL_MAX_OFFSET_X)
          y -= Rnd.rand(FESTIVAL_MAX_OFFSET_Y)
        end

        pc.intention = AI::IDLE
        pc.tele_to_location(Location.new(x, y, @start_location.z), true)
        pc.stop_all_effects_except_those_that_last_through_death
        if offerings = pc.inventory.get_item_by_item_id(FESTIVAL_OFFERING_ID)
          pc.destroy_item("SevenSigns", offerings, nil, true)
        end
      end

      spawn = L2Spawn.new(@witch_spawn.npc_id)
      spawn.x = @witch_spawn.x
      spawn.y = @witch_spawn.y
      spawn.z = @witch_spawn.z
      spawn.heading = @witch_spawn.heading
      spawn.amount = 1
      spawn.respawn_delay = 1
      spawn.stop_respawn
      SpawnTable.add_new_spawn(spawn, false)
      @witch_instance = spawn.do_spawn
      witch = @witch_instance.not_nil!

      msu = Packets::Outgoing::MagicSkillUse.new(witch, witch, 2003, 1, 1, 0)
      witch.broadcast_packet(msu)
      msu = Packets::Outgoing::MagicSkillUse.new(witch, witch, 2133, 1, 1, 0)
      witch.broadcast_packet(msu)
      send_message_to_participants(NpcString::THE_MAIN_EVENT_WILL_START_IN_2_MINUTES_PLEASE_REGISTER_NOW)
    end

    def festival_start
      spawn_festival_monsters(FESTIVAL_DEFAULT_RESPAWN, 0)
    end

    def move_monsters_to_center
      @npc_instances.each do |mob|
        next if mob.dead?

        intention = mob.intention

        if !intention.idle? && !intention.active?
          next
        end

        x, y = @start_location.x, @start_location.y

        if Rnd.bool
          x += Rnd.rand(FESTIVAL_MAX_OFFSET_X)
          y += Rnd.rand(FESTIVAL_MAX_OFFSET_Y)
        else
          x -= Rnd.rand(FESTIVAL_MAX_OFFSET_X)
          y -= Rnd.rand(FESTIVAL_MAX_OFFSET_Y)
        end

        mob.set_running
        loc = Location.new(x, y, @start_location.z, Rnd.u16.to_i32)
        mob.set_intention(AI::MOVE_TO, loc)
      end
    end

    def spawn_festival_monsters(respawn_delay : Int32, spawn_type : Int32)
      case spawn_type
      when 0, 1
        if @cabal == SevenSigns::CABAL_DAWN
          npc_spawns = FESTIVAL_DAWN_PRIMARY_SPAWNS[@level_range]
        else
          npc_spawns = FESTIVAL_DUSK_PRIMARY_SPAWNS[@level_range]
        end
      when 2
        if @cabal == SevenSigns::CABAL_DAWN
          npc_spawns = FESTIVAL_DAWN_SECONDARY_SPAWNS[@level_range]
        else
          npc_spawns = FESTIVAL_DUSK_SECONDARY_SPAWNS[@level_range]
        end
      when 3
        if @cabal == SevenSigns::CABAL_DAWN
          npc_spawns = FESTIVAL_DAWN_CHEST_SPAWNS[@level_range]
        else
          npc_spawns = FESTIVAL_DUSK_CHEST_SPAWNS[@level_range]
        end
      else
        return
      end

      npc_spawns.each do |npc_spawn|
        curr_spawn = FestivalSpawn.new(npc_spawn)
        if spawn_type == 1
          if SevenSignsFestival.festival_archer?(curr_spawn.npc_id)
            next
          end
        end

        npc_spawn2 = L2Spawn.new(curr_spawn.npc_id)
        npc_spawn2.x = curr_spawn.x
        npc_spawn2.y = curr_spawn.y
        npc_spawn2.z = curr_spawn.z
        npc_spawn2.heading = Rnd.u16.to_i32
        npc_spawn2.amount = 1
        npc_spawn2.respawn_delay = respawn_delay

        npc_spawn2.start_respawn

        SpawnTable.add_new_spawn(npc_spawn2, false)
        festival_mob = npc_spawn2.do_spawn.as(L2FestivalMonsterInstance)

        if spawn_type == 1
          festival_mob.offering_bonus = 2
        elsif spawn_type == 3
          festival_mob.offering_bonus = 5
        end

        @npc_instances << festival_mob
      end
    end

    def increase_challenge : Bool
      return false if @challenge_increased
      @challenge_increased = true
      spawn_festival_monsters(FESTIVAL_DEFAULT_RESPAWN, 1)
      true
    end

    def send_message_to_participants(str : String | NpcString)
      return if @participants.empty?
      say = Packets::Incoming::Say2::NPC_ALL
      id = @witch_instance.not_nil!.l2id
      cs = Packets::Outgoing::CreatureSay.new(id, say, "Festival Witch", str)
      @witch_instance.not_nil!.broadcast_packet(cs)
    end

    def festival_end
      unless @participants.empty?
        @participants.each do |id|
          next unless pc = L2World.get_player(id)
          relocate_player(pc, false)
          pc.send_message("The festival has ended. Your party leader must now register your score before the next festival takes place.")
        end

        if @cabal == SevenSigns::CABAL_DAWN
          DAWN_PREVIOUS_PARTICIPANTS[@level_range] = @participants
        else
          DUSK_PREVIOUS_PARTICIPANTS[@level_range] = @participants
        end
      end

      # @participants = nil

      unspawn_mobs
    end

    def unspawn_mobs
      if temp = @witch_instance
        temp.spawn.stop_respawn
        temp.delete_me
        SpawnTable.delete_spawn(temp.spawn, false)
      end
      @npc_instances.each do |inst|
        inst.spawn.stop_respawn
        inst.delete_me
        SpawnTable.delete_spawn(inst.spawn, false)
      end
    end

    def relocate_player(pc : L2PcInstance, removing : Bool)
      orig_pos = @original_locations[pc.l2id]
      if removing
        @original_locations.delete(pc.l2id)
      end

      pc.intention = AI::IDLE
      loc = Location.new(orig_pos.x, orig_pos.y, orig_pos.z)
      pc.tele_to_location(loc, true)
      pc.send_message("You have been removed from the festival arena.")
    end
  end

  private struct FestivalSpawn
    getter x : Int32
    getter y : Int32
    getter z : Int32
    getter heading : Int32
    getter npc_id : Int32

    def initialize(@x : Int32, @y : Int32, @z : Int32, heading : Int32)
      @x, @y, @z = x, y, z
      @heading = heading < 0 ? Rnd.u16.to_i32 : heading
      @npc_id = -1
    end

    def initialize(data : Indexable(Int32))
      @x, @y, @z = data.values_at(0, 1, 2)
      @heading = data[3] < 3 ? Rnd.u16.to_i32 : data[3]
      @npc_id = data.size > 4 ? data[-1] : -1
    end
  end
end
