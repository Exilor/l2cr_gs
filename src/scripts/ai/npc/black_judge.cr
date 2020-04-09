class Scripts::BlackJudge < AbstractNpcAI
  # NPC
  private BLACK_JUDGE = 30981
  # Misc
  private COSTS = {3600, 8640, 25200, 50400, 86400, 144000}

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(BLACK_JUDGE)
    add_talk_id(BLACK_JUDGE)
    add_first_talk_id(BLACK_JUDGE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    level = pc.expertise_level < 5 ? pc.expertise_level : 5

    case event
    when "remove_info"
      html = "30981-0#{level + 1}.html"
    when "remove_dp"
      if pc.death_penalty_buff_level > 0
        cost = COSTS[level]
        if pc.adena >= cost
          take_items(pc, Inventory::ADENA_ID, cost)
          pc.death_penalty_buff_level -= 1
          pc.send_packet(SystemMessageId::DEATH_PENALTY_LIFTED)
          pc.send_packet(EtcStatusUpdate.new(pc))
        else
          html = "30981-07.html"
        end
      else
        html = "30981-08.html"
      end
    else
      # [automatically added else]
    end


    html
  end
end
