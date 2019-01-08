# Complements the quest Q00065_CertifiedSoulBreaker.
class NpcAI::Katenar < AbstractNpcAI
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

  def on_adv_event(event, npc, player)
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
      player = player.not_nil!
      qs = player.get_quest_state!(Quests::Q00065_CertifiedSoulBreaker.simple_name)
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
    qs = talker.get_quest_state!(Quests::Q00065_CertifiedSoulBreaker.simple_name)
    memo_state = qs.memo_state
    if memo_state == 12
      htmltext = "32242-01.html"
    elsif memo_state == 13
      player = npc.variables.get_object("player0", L2PcInstance?)
      if player == talker
        qs.memo_state = 14
        qs.set_cond(13, true)
        htmltext = "32242-02.html"
      else
        qs.memo_state = 14
        qs.set_cond(13, true)
        htmltext = "32242-03.html"
      end

      unless has_quest_items?(player, SEALED_DOCUMENT)
        give_items(player, SEALED_DOCUMENT, 1)
      end
    elsif memo_state == 14
      htmltext = "32242-04.html"
    end

    htmltext || get_no_quest_msg(talker)
  end

  def on_spawn(npc)
    start_quest_timer("CREATED_50", 50000, npc, nil)
    player = npc.variables.get_object("player0", L2PcInstance?)
    if player
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::I_AM_LATE)
    end

    super
  end
end
