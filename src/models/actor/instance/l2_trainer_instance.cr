class L2TrainerInstance < L2NpcInstance
  def instance_type : InstanceType
    InstanceType::L2TrainerInstance
  end

  def get_html_path(npc_id, val)
    pom = val == 0 ? npc_id : "#{npc_id}-#{val}"
    "data/html/trainer/#{pom}.htm"
  end
end
