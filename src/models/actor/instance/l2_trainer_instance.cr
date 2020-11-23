class L2TrainerInstance < L2NpcInstance
  def instance_type : InstanceType
    InstanceType::L2TrainerInstance
  end

  def get_html_path(npc_id : Int32, val : Int32) : String
    if val == 0
      "data/html/trainer/#{npc_id}.htm"
    else
      "data/html/trainer/#{npc_id}-#{val}.htm"
    end
  end
end
