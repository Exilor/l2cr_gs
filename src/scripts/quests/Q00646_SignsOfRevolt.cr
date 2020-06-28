# Not available since Gracia Epilogue.
class Scripts::Q00646_SignsOfRevolt < Quest
  # NPC
  private TORRANT = 32016
  # Misc
  private MIN_LEVEL = 80

  def initialize
    super(646, self.class.simple_name, "Signs of Revolt")

    add_start_npc(TORRANT)
    add_talk_id(TORRANT)
  end

  def on_talk(npc, pc)
    if st = get_quest_state!(pc)
      st.exit_quest(true)
    end

    pc.level >= MIN_LEVEL ? "32016-01.html" : "32016-02.html"
  end
end
