class Scripts::Katenar < AbstractNpcAI
  # NPC
  KATENAR = 32242
  # Item
  SEALED_DOCUMENT = 9803

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(KATENAR)
    add_talk_id(KATENAR)
    add_first_talk_id(KATENAR)
    add_spawn_id(KATENAR)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    npc0 = npc.variables.get_object("npc0", L2Npc)

    case event
    when "CREATED_50"
      if npc0
        unless npc.variables.get_bool("SPAWNED", false)
          npc0.variables["SPAWNED"] = false
        end
      end
      npc.delete_me
    when "GOOD_LUCK"
      pc = pc.not_nil!
      qs = pc.get_quest_state!(Scripts::Q00065_CertifiedSoulBreaker.simple_name)
      if qs.memo_state?(14)
        if npc0
          unless npc.variables.get_bool("SPAWNED", false)
            npc0.variables["SPAWNED"] = false
            broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::GOOD_LUCK)
          end
        end
        npc.delete_me
      end
    end

    nil
  end

  def on_first_talk(npc, talker)
    qs = talker.get_quest_state!(Scripts::Q00065_CertifiedSoulBreaker.simple_name)
    memo_state = qs.memo_state
    if memo_state == 12
      html = "32242-01.html"
    elsif memo_state == 13
      pc = npc.variables.get_object("player0", L2PcInstance)
      if pc == talker
        qs.memo_state = 14
        qs.set_cond(13, true)
        html = "32242-02.html"
      else
        qs.memo_state = 14
        qs.set_cond(13, true)
        html = "32242-03.html"
      end

      unless has_quest_items?(pc, SEALED_DOCUMENT)
        give_items(pc, SEALED_DOCUMENT, 1)
      end
    elsif memo_state == 14
      html = "32242-04.html"
    end

    html || get_no_quest_msg(talker)
  end

  def on_spawn(npc)
    start_quest_timer("CREATED_50", 50000, npc, nil)
    if npc.variables.get_object("player0", L2PcInstance?)
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::I_AM_LATE)
    end

    super
  end
end
