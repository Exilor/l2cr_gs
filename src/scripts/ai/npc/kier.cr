class Scripts::Kier < AbstractNpcAI
  # NPC
  private KIER = 32022

  def initialize
    super(self.class.simple_name, "ai/npc")
    add_first_talk_id(KIER)
  end

  def on_first_talk(npc, pc)
    st_q00115 = pc.get_quest_state(Q00115_TheOtherSideOfTruth.simple_name)
    if st_q00115.nil?
      html = "32022-02.html"
    elsif !st_q00115.completed?
      html = "32022-01.html"
    end

    st_q10283 = pc.get_quest_state(Q10283_RequestOfIceMerchant.simple_name)
    if st_q10283
      if st_q10283.memo_state?(2)
        html = "32022-03.html"
      elsif st_q10283.completed?
        html = "32022-04.html"
      end
    end

    html
  end
end
