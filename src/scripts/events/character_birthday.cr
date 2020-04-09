class Scripts::CharacterBirthday < Quest
  private ALEGRIA = 32600

  private GK = {
    30006,
    30059,
    30080,
    30134,
    30146,
    30177,
    30233,
    30256,
    30320,
    30540,
    30576,
    30836,
    30848,
    30878,
    30899,
    31275,
    31320,
    31964,
    32163
  }

  def initialize
    super(-1, self.class.simple_name, "events")

    @spawns = 0

    add_start_npc(ALEGRIA)
    add_start_npc(GK)
    add_talk_id(ALEGRIA)
    add_talk_id(GK)
  end

  def on_adv_event(event, npc, pc)
    html = event

    pc = pc.not_nil!
    npc = npc.not_nil!

    case event.casecmp
    when "despawn_npc"
      npc.do_die(pc)
      @spawns -= 1
    when "change"
      if has_quest_items?(pc, 10250)
        take_items(pc, 10250, 1)
        give_items(pc, 21594, 1)
        html = nil
        npc.do_die(pc)
        @spawns -= 1
      else
        html = "32600-nohat.htm"
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    if @spawns >= 3
      return "busy.htm"
    end

    if Util.in_range?(10, npc, pc, true)
      return "tooclose.htm"
    else
      spawned = add_spawn(32600, pc.x + 10, pc.y + 10, pc.z + 10, 0, false, 0, true)
      start_quest_timer("despawn_npc", 180000, spawned, pc)
      @spawns += 1
    end

    nil
  end
end
