class NpcAI::OracleTeleport < AbstractNpcAI
  private TOWN_DAWN = {
    31078, 31079, 31080, 31081, 31083, 31084, 31082, 31692, 31694, 31997, 31168
  }

  private TOWN_DUSK = {
    31085, 31086, 31087, 31088, 31090, 31091, 31089, 31693, 31695, 31998, 31169
  }

  private TEMPLE_PRIEST = {
    31127, 31128, 31129, 31130, 31131, 31137, 31138, 31139, 31140, 31141
  }

  private RIFT_POSTERS = {
    31488, 31489, 31490, 31491, 31492, 31493
  }

  private TELEPORTERS = {
    31078, 31079, 31080, 31081, 31082, 31083, 31084, 31692, 31694, 31997, 31168,
    31085, 31086, 31087, 31088, 31089, 31090, 31091, 31693, 31695, 31998, 31169,
    31494, 31495, 31496, 31497, 31498, 31499, 31500, 31501, 31502, 31503, 31504,
    31505, 31506, 31507, 31095, 31096, 31097, 31098, 31099, 31100, 31101, 31102,
    31103, 31104, 31105, 31106, 31107, 31108, 31109, 31110, 31114, 31115, 31116,
    31117, 31118, 31119, 31120, 31121, 31122, 31123, 31124, 31125
  }

  private RETURN_LOCS = {
    Location.new(-80555, 150337, -3040),
    Location.new(-13953, 121404, -2984),
    Location.new(16354, 142820, -2696),
    Location.new(83369, 149253, -3400),
    Location.new(111386, 220858, -3544),
    Location.new(83106, 53965, -1488),
    Location.new(146983, 26595, -2200),
    Location.new(148256, -55454, -2779),
    Location.new(45664, -50318, -800),
    Location.new(86795, -143078, -1341),
    Location.new(115136, 74717, -2608),
    Location.new(-82368, 151568, -3120),
    Location.new(-14748, 123995, -3112),
    Location.new(18482, 144576, -3056),
    Location.new(81623, 148556, -3464),
    Location.new(112486, 220123, -3592),
    Location.new(82819, 54607, -1520),
    Location.new(147570, 28877, -2264),
    Location.new(149888, -56574, -2979),
    Location.new(44528, -48370, -800),
    Location.new(85129, -142103, -1542),
    Location.new(116642, 77510, -2688),
    Location.new(-41572, 209731, -5087),
    Location.new(-52872, -250283, -7908),
    Location.new(45256, 123906, -5411),
    Location.new(46192, 170290, -4981),
    Location.new(111273, 174015, -5437),
    Location.new(-20604, -250789, -8165),
    Location.new(-21726, 77385, -5171),
    Location.new(140405, 79679, -5427),
    Location.new(-52366, 79097, -4741),
    Location.new(118311, 132797, -4829),
    Location.new(172185, -17602, -4901),
    Location.new(83000, 209213, -5439),
    Location.new(-19500, 13508, -4901),
    Location.new(12525, -248496, -9580),
    Location.new(-41561, 209225, -5087),
    Location.new(45242, 124466, -5413),
    Location.new(110711, 174010, -5439),
    Location.new(-22341, 77375, -5173),
    Location.new(-52889, 79098, -4741),
    Location.new(117760, 132794, -4831),
    Location.new(171792, -17609, -4901),
    Location.new(82564, 209207, -5439),
    Location.new(-41565, 210048, -5085),
    Location.new(45278, 123608, -5411),
    Location.new(111510, 174013, -5437),
    Location.new(-21489, 77372, -5171),
    Location.new(-52016, 79103, -4739),
    Location.new(118557, 132804, -4829),
    Location.new(172570, -17605, -4899),
    Location.new(83347, 209215, -5437),
    Location.new(42495, 143944, -5381),
    Location.new(45666, 170300, -4981),
    Location.new(77138, 78389, -5125),
    Location.new(139903, 79674, -5429),
    Location.new(-20021, 13499, -4901),
    Location.new(113418, 84535, -6541),
    Location.new(-52940, -250272, -7907),
    Location.new(46499, 170301, -4979),
    Location.new(-20280, -250785, -8163),
    Location.new(140673, 79680, -5437),
    Location.new(-19182, 13503, -4899),
    Location.new(12837, -248483, -9579)
  }

  # Item
  DIMENSIONAL_FRAGMENT = 7079

  def initialize
    super(OracleTeleport.simple_name, "ai/npc/Teleports")

    add_start_npc(RIFT_POSTERS)
    add_start_npc(TELEPORTERS)
    add_start_npc(TEMPLE_PRIEST)
    add_start_npc(TOWN_DAWN)
    add_start_npc(TOWN_DUSK)
    add_talk_id(RIFT_POSTERS)
    add_talk_id(TELEPORTERS)
    add_talk_id(TEMPLE_PRIEST)
    add_talk_id(TOWN_DAWN)
    add_talk_id(TOWN_DUSK)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc
    return unless st = get_quest_state(pc, false)

    htmltext = ""

    npc_id = npc.id
    if event.casecmp?("Return")
      if TEMPLE_PRIEST.includes?(npc_id) && st.state.started?
        pc.tele_to_location(RETURN_LOCS[st.get_int("id")])
        pc.in_7s_dungeon = false
        st.exit_quest(true)
      elsif RIFT_POSTERS.includes?(npc_id) && st.state.started?
        pc.tele_to_location(RETURN_LOCS[st.get_int("id")])
        htmltext = "rift_back.htm"
        st.exit_quest(true)
      end
    elsif event.casecmp?("Festival")
      id = st.get_int("id")
      if TOWN_DAWN.includes?(id)
        pc.tele_to_location(Location.new(-80157, 111344, -4901))
        pc.in_7s_dungeon = true
      elsif TOWN_DUSK.includes?(id)
        pc.tele_to_location(Location.new(-81261, 86531, -5157))
        pc.in_7s_dungeon = true
      else
        htmltext = "oracle1.htm"
      end
    elsif event.casecmp?("Dimensional")
      htmltext = "oracle.htm"
      pc.tele_to_location(Location.new(-114755, -179466, -6752))
    elsif event.casecmp?("5.htm")
      id = st.get_int("id")
      if id > -1
        htmltext = "5a.htm"
      end
      i = 0
      TELEPORTERS.each do |id1|
        if id1 == npc_id
          break
        end
        i += 1
      end
      st.set("id", i.to_s)
      st.state = State::STARTED
      pc.tele_to_location(Location.new(-114755, -179466, -6752))
    elsif event.casecmp?("6.htm")
      htmltext = "6.htm"
      st.exit_quest(true)
    elsif event.casecmp?("zigurratDimensional")
      lvl = pc.level
      if lvl >= 20 && lvl < 30
        take_items(pc, Inventory::ADENA_ID, 2000)
      elsif lvl >= 30 && lvl < 40
        take_items(pc, Inventory::ADENA_ID, 4500)
      elsif lvl >= 40 && lvl < 50
        take_items(pc, Inventory::ADENA_ID, 8000)
      elsif lvl >= 50 && lvl < 60
        take_items(pc, Inventory::ADENA_ID, 12500)
      elsif lvl >= 60 && lvl < 70
        take_items(pc, Inventory::ADENA_ID, 18000)
      elsif lvl >= 70
        take_items(pc, Inventory::ADENA_ID, 24500)
      end
      i = 0
      TELEPORTERS.each do |ziggurat|
        if ziggurat == npc_id
          break
        end
        i += 1
      end
      st.set("id", i.to_s)
      st.state = State::STARTED
      play_sound(pc, Sound::ITEMSOUND_QUEST_ACCEPT)
      htmltext = "ziggurat_rift.htm"
      pc.tele_to_location(Location.new(-114755, -179466, -6752))
    end

    htmltext
  end

  def on_talk(npc, pc)
    htmltext = ""
    st = get_quest_state!(pc)

    npc_id = npc.id
    if TOWN_DAWN.includes?(npc_id)
      st.state = State::STARTED
      i = 0
      TELEPORTERS.each do |dawn|
        if dawn == npc_id
          break
        end
        i += 1
      end
      st.set("id", i.to_s)
      play_sound(pc, Sound::ITEMSOUND_QUEST_ACCEPT)
      pc.tele_to_location(Location.new(-80157, 111344, -4901))
      pc.in_7s_dungeon = true
    end
    if TOWN_DUSK.includes?(npc_id)
      st.state = State::STARTED
      i = 0
      TELEPORTERS.each do |dusk|
        if dusk == npc_id
          break
        end
        i += 1
      end
      st.set("id", i.to_s)
      play_sound(pc, Sound::ITEMSOUND_QUEST_ACCEPT)
      pc.tele_to_location(Location.new(-81261, 86531, -5157))
      pc.in_7s_dungeon = true
    elsif npc_id.between?(31494, 31507)
      if pc.level < 20
        htmltext = "1.htm"
        st.exit_quest(true)
      elsif pc.all_active_quests.size > 23
        htmltext = "1a.htm"
        st.exit_quest(true)
      elsif !has_quest_items?(pc, DIMENSIONAL_FRAGMENT)
        htmltext = "3.htm"
      else
        st.state = State::CREATED
        htmltext = "4.htm"
      end
    elsif npc_id.between?(31095, 31111) || npc_id.between?(31114, 31126)
      lvl = pc.level
      if lvl < 20
        htmltext = "ziggurat_lowlevel.htm"
        st.exit_quest(true)
      elsif pc.all_active_quests.size > 40
        pc.send_packet(SystemMessageId::TOO_MANY_QUESTS)
        st.exit_quest(true)
      elsif !has_quest_items?(pc, DIMENSIONAL_FRAGMENT)
        htmltext = "ziggurat_nofrag.htm"
        st.exit_quest(true)
      elsif lvl >= 20 && lvl < 30 && pc.adena < 2000
        htmltext = "ziggurat_noadena.htm"
        st.exit_quest(true)
      elsif lvl >= 30 && lvl < 40 && pc.adena < 4500
        htmltext = "ziggurat_noadena.htm"
        st.exit_quest(true)
      elsif lvl >= 40 && lvl < 50 && pc.adena < 8000
        htmltext = "ziggurat_noadena.htm"
        st.exit_quest(true)
      elsif lvl >= 50 && lvl < 60 && pc.adena < 12500
        htmltext = "ziggurat_noadena.htm"
        st.exit_quest(true)
      elsif lvl >= 60 && lvl < 70 && pc.adena < 18000
        htmltext = "ziggurat_noadena.htm"
        st.exit_quest(true)
      elsif lvl >= 70 && pc.adena < 24500
        htmltext = "ziggurat_noadena.htm"
        st.exit_quest(true)
      else
        htmltext = "ziggurat.htm"
      end
    end

    htmltext
  end
end
