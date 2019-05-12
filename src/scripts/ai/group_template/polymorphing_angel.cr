class Scripts::PolymorphingAngel < AbstractNpcAI
  private ANGELS = {
    20830 => 20859,
    21067 => 21068,
    21062 => 21063,
    20831 => 20860,
    21070 => 21071
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_kill_id(ANGELS.keys)
  end

  def on_kill(npc, killer, is_summon)
    new_npc = add_spawn(ANGELS[npc.id], npc)
    new_npc.set_running

    super
  end
end
