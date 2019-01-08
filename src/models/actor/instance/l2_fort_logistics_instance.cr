class L2FortLogisticsInstance < L2MerchantInstance
  private SUPPLY_BOX_IDS = {
    35665,
    35697,
    35734,
    35766,
    35803,
    35834,
    35866,
    35903,
    35935,
    35973,
    36010,
    36042,
    36080,
    36117,
    36148,
    36180,
    36218,
    36256,
    36293,
    36325,
    36363
  }

  def get_html_path(npc_id, val)
    pom = val == 0 ? "logistics" : "logistics-#{val}"
    "data/html/fortress/#{pom}.htm"
  end

  def instance_type
    InstanceType::L2FortLogisticsInstance
  end
end
