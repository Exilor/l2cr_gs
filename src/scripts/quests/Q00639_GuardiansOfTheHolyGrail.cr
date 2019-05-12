# Deprecated in CT2.5
class Scripts::Q00639_GuardiansOfTheHolyGrail < Quest
  # NPC
  private DOMINIC = 31350

  def initialize
    super(639, self.class.simple_name, "Guardians of the Holy Grail")

    add_start_npc(DOMINIC)
    add_talk_id(DOMINIC)
  end

  def on_talk(npc, pc)
    if st = get_quest_state!(pc)
      st.exit_quest(true)
    end

    "31350-01.html"
  end
end
