class Scripts::NpcBuffers < AbstractNpcAI
  def initialize
    super(self.class.simple_name, "ai/npc")

    NpcBuffersData.load
    NpcBuffersData.npc_buffer_ids.each do |npc_id|
      add_first_talk_id(npc_id)
      add_spawn_id(npc_id)
    end
  end

  def on_first_talk(npc, pc)
    # return nil
  end

  def on_spawn(npc)
    debug "#on_spawn: npc: #{npc}."
    data = NpcBuffersData.get_npc_buffer(npc.id)
    data.skills.each do |skill|
      task = NpcBufferAI.new(npc, skill)
      ThreadPoolManager.schedule_ai(task, skill.initial_delay)
    end

    super
  end
end
