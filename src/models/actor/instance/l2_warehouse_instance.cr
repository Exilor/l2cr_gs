require "./l2_npc_instance"

class L2WarehouseInstance < L2NpcInstance
  def instance_type : InstanceType
    InstanceType::L2WarehouseInstance
  end

  def get_html_path(npc_id, val) : String
    pom = val == 0 ? npc_id : "#{npc_id}-#{val}"
    "data/html/warehouse/#{pom}.htm"
  end

  def warehouse? : Bool
    true
  end
end
