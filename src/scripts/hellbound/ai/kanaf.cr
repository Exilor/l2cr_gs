class Scripts::Kanaf < AbstractNpcAI
  # NPCs
  private KANAF = 32346

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_start_npc(KANAF)
    add_talk_id(KANAF)
    add_first_talk_id(KANAF)
  end

  def on_adv_event(event, npc, pc)
    event == "info" ? "32346-0#{Rnd.rand(1..3)}.htm" : super
  end
end
