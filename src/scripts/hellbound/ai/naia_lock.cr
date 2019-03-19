class NpcAI::NaiaLock < AbstractNpcAI
  private LOCK = 18491

  def initialize
    super(self.class.simple_name, "hellbound/AI")
    add_kill_id(LOCK)
  end

  def on_kill(npc, killer, is_summon)
    npc.as(L2MonsterInstance).minion_list.on_master_die(true)
    super
  end
end
