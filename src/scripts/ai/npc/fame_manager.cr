class Scripts::FameManager < AbstractNpcAI
  # Npc
  private FAME_MANAGER = {
    36479, # Rapidus
    36480  # Scipio
  }
  # Misc
  private MIN_LVL = 40
  private DECREASE_COST = 5000
  private REPUTATION_COST = 1000
  private MIN_CLAN_LVL = 5
  private CLASS_LVL = 2

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(FAME_MANAGER)
    add_talk_id(FAME_MANAGER)
    add_first_talk_id(FAME_MANAGER)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    npc = npc.not_nil!

    case event
    when "36479.html", "36479-02.html", "36479-07.html", "36480.html",
         "36480-02.html", "36480-07.html"
      html = event
    when "decreasePk"
      if pc.pk_kills > 0
        if pc.fame >= DECREASE_COST && pc.level >= MIN_LVL && pc.class_id.level >= CLASS_LVL
          pc.fame = pc.fame - DECREASE_COST
          pc.pk_kills -= 1
          pc.send_packet(UserInfo.new(pc))
          html = "#{npc.id}-06.html"
        else
          html = "#{npc.id}-01.html"
        end
      else
        html = "#{npc.id}-05.html"
      end
    when "clanRep"
      if (clan = pc.clan) && clan.level >= MIN_CLAN_LVL
        if pc.fame >= REPUTATION_COST && pc.level >= MIN_LVL && pc.class_id.level >= CLASS_LVL
          pc.fame = pc.fame - REPUTATION_COST
          clan.add_reputation_score(50, true)
          pc.send_packet(UserInfo.new(pc))
          pc.send_packet(SystemMessageId::ACQUIRED_50_CLAN_FAME_POINTS)
          html = "#{npc.id}-04.html"
        else
          html = "#{npc.id}-01.html"
        end
      else
        html = "#{npc.id}-03.html"
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_first_talk(npc, pc)
    if pc.fame > 0 && pc.level >= MIN_LVL && pc.class_id.level >= CLASS_LVL
      return "#{npc.id}.html"
    end

    "#{npc.id}-01.html"
  end
end
