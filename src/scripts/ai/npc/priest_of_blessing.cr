class Scripts::PriestOfBlessing < AbstractNpcAI
  # NPC
  private PRIEST = 32783

  # Items
  private NEVIT_VOICE = 17094

  private HOURGLASSES = {
    {17095, 17096, 17097, 17098, 17099},
    {17100, 17101, 17102, 17103, 17104},
    {17105, 17106, 17107, 17108, 17109},
    {17110, 17111, 17112, 17113, 17114},
    {17115, 17116, 17117, 17118, 17119},
    {17120, 17121, 17122, 17123, 17124},
    {17125, 17126, 17127, 17128, 17129}
  }

  # Prices
  private PRICE_VOICE = 100000
  private PRICE_HOURGLASS = {
    4000,
    30000,
    110000,
    310000,
    970000,
    2160000,
    5000000
  }
  # Locations
  private SPAWNS = {
    Location.new(-84139, 243145, -3704, 8473),
    Location.new(-119702, 44557, 360, 33023),
    Location.new(45413, 48351, -3056, 50020),
    Location.new(115607, -177945, -896, 38058),
    Location.new(12086, 16589, -4584, 3355),
    Location.new(-45032, -113561, -192, 32767),
    Location.new(-83112, 150922, -3120, 2280),
    Location.new(-13931, 121938, -2984, 30212),
    Location.new(87127, -141330, -1336, 49153),
    Location.new(43520, -47590, -792, 43738),
    Location.new(148060, -55314, -2728, 40961),
    Location.new(82801, 149381, -3464, 53707),
    Location.new(82433, 53285, -1488, 22942),
    Location.new(147059, 25930, -2008, 56399),
    Location.new(111171, 221053, -3544, 2058),
    Location.new(15907, 142901, -2688, 14324),
    Location.new(116972, 77255, -2688, 41951)
  }

  # Spawn state
  @@spawned = false

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(PRIEST)
    add_first_talk_id(PRIEST)
    add_talk_id(PRIEST)

    unless @@spawned
      SPAWNS.each do |sp|
        add_spawn(PRIEST, sp, false, 0)
      end
      @@spawned = true
    end
  end

  def on_adv_event(event, npc, pc)
    html = event
    if event.casecmp?("buy_voice")
      pc = pc.not_nil!
      if pc.adena >= PRICE_VOICE
        value = load_global_quest_var(pc.account_name + "_voice")
        _reuse_time = value.empty? ? 0 : value.to_i64

        if Time.ms > _reuse_time
          take_items(pc, Inventory::ADENA_ID, PRICE_VOICE)
          give_items(pc, NEVIT_VOICE, 1)
          save_global_quest_var(pc.account_name + "_voice", (Time.ms + (20 * 3600000)).to_s)
        else
          rem_time = (_reuse_time - Time.ms) / 1000
          hours = (rem_time / 3600).to_i
          minutes = ((rem_time % 3600) / 60).to_i
          sm = SystemMessage.available_after_s1_s2_hours_s3_minutes
          sm.add_item_name(NEVIT_VOICE)
          sm.add_int(hours)
          sm.add_int(minutes)
          pc.send_packet(sm)
        end

        return
      end
      html = "32783-adena.htm"
    elsif event.casecmp?("buy_hourglass")
      pc = pc.not_nil!
      _index = get_hg_index(pc.level)
      _price_hourglass = PRICE_HOURGLASS[_index]

      if pc.adena >= _price_hourglass
        value = load_global_quest_var("#{pc.account_name}_hg_#{_index}")
        _reuse_time = value.empty? ? 0 : value.to_i64

        if Time.ms > _reuse_time
          _hg = HOURGLASSES[_index]
          _nevit_hourglass = _hg.sample(random: Rnd)
          take_items(pc, Inventory::ADENA_ID, _price_hourglass)
          give_items(pc, _nevit_hourglass, 1)
          save_global_quest_var("#{pc.account_name}_hg_#{_index}", (Time.ms + (20 * 3600000)).to_s)
        else
          rem_time = (_reuse_time - Time.ms) / 1000
          hours = (rem_time / 3600).to_i
          minutes = ((rem_time % 3600) / 60).to_i
          sm = SystemMessage.available_after_s1_s2_hours_s3_minutes
          sm.add_string("Nevit's Hourglass")
          sm.add_int(hours)
          sm.add_int(minutes)
          pc.send_packet(sm)
        end

        return
      end
      html = "32783-adena.htm"
    end

    html
  end

  def on_first_talk(npc, pc)
    content = get_htm(pc, "32783.htm")
    content.sub("%donate%", Util.format_adena(PRICE_HOURGLASS[get_hg_index(pc.level)]))
  end

  private def get_hg_index(lvl)
    case
    when lvl < 20 then 0
    when lvl < 40 then 1
    when lvl < 52 then 2
    when lvl < 61 then 3
    when lvl < 76 then 4
    when lvl < 80 then 5
    when lvl < 86 then 6
    else 0
    end
  end
end
