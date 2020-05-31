class Scripts::SinWardens < AbstractNpcAI
  private SIN_WARDEN_MINIONS = {
    22424,
    22425,
    22426,
    22427,
    22428,
    22429,
    22430,
    22432,
    22433,
    22434,
    22435,
    22436,
    22437,
    22438
  }

  private KILLED_MINIONS = Concurrent::Map(Int32, Int32).new

  def initialize
    super(self.class.simple_name, "ai/individual")
    add_kill_id(SIN_WARDEN_MINIONS)
  end

  def on_kill(npc, killer, is_summon)
    if npc.minion?
      if (master = npc.leader) && master.alive?
        killed_count = KILLED_MINIONS.fetch(master.l2id, 0)
        killed_count &+= 1

        if killed_count == 5
          npc_str = NpcString::WE_MIGHT_NEED_NEW_SLAVES_ILL_BE_BACK_SOON_SO_WAIT
          ns = NpcSay.new(master.l2id, Say2::NPC_ALL, master.id, npc_str)
          master.broadcast_packet(ns)
          master.do_die(killer)
          KILLED_MINIONS.delete(master.l2id)
        else
          KILLED_MINIONS[master.l2id] = killed_count
        end
      end
    end

    super
  end
end
