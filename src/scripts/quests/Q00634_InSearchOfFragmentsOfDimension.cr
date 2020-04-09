class Scripts::Q00634_InSearchOfFragmentsOfDimension < Quest
  private DIMENSIONAL_GATE_KEEPER = {
    31494,
    31495,
    31496,
    31497,
    31498,
    31499,
    31500,
    31501,
    31502,
    31503,
    31504,
    31505,
    31506,
    31507
  }

  private MOBS = {
    21208, # Hallowed Watchman
    21209, # Hallowed Seer
    21210, # Vault Guardian
    21211, # Vault Seer
    21212, # Hallowed Sentinel
    21213, # Hallowed Monk
    21214, # Vault Sentinel
    21215, # Vault Monk
    21216, # Overlord of the Holy Lands
    21217, # Hallowed Priest
    21218, # Vault Overlord
    21219, # Vault Priest
    21220, # Sepulcher Archon
    21221, # Sepulcher Inquisitor
    21222, # Sepulcher Archon
    21223, # Sepulcher Inquisitor
    21224, # Sepulcher Guardian
    21225, # Sepulcher Sage
    21226, # Sepulcher Guardian
    21227, # Sepulcher Sage
    21228, # Sepulcher Guard
    21229, # Sepulcher Preacher
    21230, # Sepulcher Guard
    21231, # Sepulcher Preacher
    21232, # Barrow Guardian
    21233, # Barrow Seer
    21234, # Grave Guardian
    21235, # Grave Seer
    21236, # Barrow Sentinel
    21237, # Barrow Monk
    21238, # Grave Sentinel
    21239, # Grave Monk
    21240, # Barrow Overlord
    21241, # Barrow Priest
    21242, # Grave Overlord
    21243, # Grave Priest
    21244, # Crypt Archon
    21245, # Crypt Inquisitor
    21246, # Tomb Archon
    21247, # Tomb Inquisitor
    21248, # Crypt Guardian
    21249, # Crypt Sage
    21250, # Tomb Guardian
    21251, # Tomb Sage
    21252, # Crypt Guard
    21253, # Crypt Preacher
    21254, # Tomb Guard
    21255, # Tomb Preacher
    21256  # Underground Werewolf
  }

  private DIMENSIONAL_FRAGMENT = 7079
  private MIN_LEVEL = 20

  def initialize
    super(634, self.class.simple_name, "In Search of Fragments of Dimension")

    add_start_npc(DIMENSIONAL_GATE_KEEPER)
    add_talk_id(DIMENSIONAL_GATE_KEEPER)
    add_kill_id(MOBS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "31494-02.htm"
      qs.start_quest
      event
    when "31494-05.html", "31494-06.html"
      if qs.started?
        event
      end
    when "31494-07.html"
      if qs.started?
        qs.exit_quest(true, true)
        event
      end
    else
      # [automatically added else]
    end

  end

  def on_kill(npc, pc, is_summon)
    if qs = get_random_party_member_state(pc, -1, 3, npc)
      i0 = ((0.15 * npc.level) + 1.6).to_i
      if Rnd.rand(100) < 10
        give_item_randomly(qs.player, npc, DIMENSIONAL_FRAGMENT, i0, 0, 1.0, true)
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      return pc.level >= MIN_LEVEL ? "31494-01.htm" : "31494-03.htm"
    elsif qs.started?
      return "31494-04.html"
    end

    get_no_quest_msg(pc)
  end
end
