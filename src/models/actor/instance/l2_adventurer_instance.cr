require "./l2_npc_instance"

class L2AdventurerInstance < L2NpcInstance
  def instance_type : InstanceType
    InstanceType::L2AdventurerInstance
  end

  def get_html_path(npc_id, val)
    if val == 0
      "data/html/adventurer_guildsman/#{npc_id}.htm"
    else
      "data/html/adventurer_guildsman/#{npc_id}-#{val}.htm"
    end
  end
end
