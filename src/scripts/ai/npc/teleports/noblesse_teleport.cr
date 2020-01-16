class Scripts::NoblesseTeleport < AbstractNpcAI
  # Item
  private OLYMPIAD_TOKEN = 13722
  # NPCs
  private NPCs = {
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
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(NPCs)
    add_talk_id(NPCs)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    if event == "teleportWithToken"
      if has_quest_items?(pc, OLYMPIAD_TOKEN)
        npc.show_chat_window(pc, 3)
      else
        return "noble-nopass.htm"
      end
    end

    super
  end

  def on_talk(npc, pc)
    pc.noble? ? "nobleteleporter.htm" : "nobleteleporter-no.htm"
  end
end
