require "./l2_npc_instance"

class L2WarehouseInstance < L2NpcInstance
  def instance_type : InstanceType
    InstanceType::L2WarehouseInstance
  end

  def get_html_path(npc_id, val) : String
    if val == 0
      "data/html/warehouse/#{npc_id}.htm"
    else
      "data/html/warehouse/#{npc_id}-#{val}.htm"
    end
  end

  def warehouse? : Bool
    true
  end
end
