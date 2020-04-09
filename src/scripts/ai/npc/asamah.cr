class Scripts::Asamah < AbstractNpcAI
  # NPC
  private ASAMAH = 32115

  def initialize
    super(self.class.simple_name, "ai/npc")
    add_first_talk_id(ASAMAH)
  end

  def on_adv_event(event, npc, player)
    case event
    when "32115-03.htm", "32115-04.htm"
      event
    else
      # [automatically added else]
    end

  end

  def on_first_talk(npc, player)
    st = player.get_quest_state("Q00111_ElrokianHuntersProof")
    st && st.completed? ? "32115-01.htm" : "32115-02.htm"
  end
end
