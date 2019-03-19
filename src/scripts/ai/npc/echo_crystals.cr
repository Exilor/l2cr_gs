class NpcAI::EchoCrystals < AbstractNpcAI
  private record RewardInfo, crystal_id : Int32, ok_msg : String,
    no_adena_msg : String, no_score_msg : String

  private NPCS = {
    31042, # Kantabilon
    32043  # Octavia
  }
  private ADENA = 57
  private COST = 200
  private SCORES = {
    4410 => RewardInfo.new(4411, "01", "02", "03"),
    4409 => RewardInfo.new(4412, "04", "05", "06"),
    4408 => RewardInfo.new(4413, "07", "08", "09"),
    4420 => RewardInfo.new(4414, "10", "11", "12"),
    4421 => RewardInfo.new(4415, "13", "14", "15"),
    4419 => RewardInfo.new(4417, "16", "05", "06"),
    4418 => RewardInfo.new(4416, "17", "05", "06")
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    score = event.to_i
    if tmp = SCORES[score]?
      if !has_quest_items?(pc, score)
        noscore = tmp.no_score_msg
        htmltext = "#{npc.id}-#{noscore}.htm"
      elsif get_quest_items_count(pc, ADENA) < COST
        noadena = tmp.no_adena_msg
        htmltext = "#{npc.id}-#{noadena}.htm"
      else
        crystal = tmp.crystal_id
        ok = tmp.ok_msg
        take_items(pc, ADENA, COST)
        give_items(pc, crystal, 1)
        htmltext = "#{npc.id}-#{ok}.htm"
      end
    end

    htmltext
  end
end
