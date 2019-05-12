class Scripts::Kanaf < AbstractNpcAI
  # NPCs
  private KANAF = 32346

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_start_npc(KANAF)
    add_talk_id(KANAF)
    add_first_talk_id(KANAF)
  end

  def on_adv_event(event, npc, player)
    if event == "info"
      return "32346-0#{rand(1..3)}.htm"
    end

    super
  end
end
