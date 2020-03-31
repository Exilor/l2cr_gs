class Scripts::TheValentineEvent < LongTimeEvent
  # NPC
  private NPC = 4301
  # Item
  private RECIPE = 20191
  # Misc
  private COMPLETED = simple_name + "_completed"

  def initialize
    super(self.class.simple_name, "events")

    add_start_npc(NPC)
    add_first_talk_id(NPC)
    add_talk_id(NPC)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!

    html = event
    if event.casecmp?("4301-3.htm")
      if pc.variables.get_bool(COMPLETED, false)
        html = "4301-4.htm"
      else
        give_items(pc, RECIPE, 1)
        play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    html
  end

  def on_first_talk(npc, pc)
    "#{npc.id}.htm"
  end
end
