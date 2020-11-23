require "./l2_npc_instance"

class L2MerchantInstance < L2NpcInstance
  getter! mpc : MerchantPriceConfigTable::MerchantPriceConfig

  def instance_type : InstanceType
    InstanceType::L2MerchantInstance
  end

  def on_spawn
    super
    @mpc = MerchantPriceConfigTable.get_merchant_price_config(self)
  end

  def get_html_path(npc_id : Int32, val : Int32) : String
    if val == 0
      "data/html/merchant/#{npc_id}.htm"
    else
      "data/html/merchant/#{npc_id}-#{val}.htm"
    end
  end

  def show_buy_window(pc : L2PcInstance, val : Int32, apply_tax : Bool = true)
    unless buy_list = BuyListData.get_buy_list(val)
      warn "BuyList not found."
      pc.action_failed
      return
    end

    unless buy_list.npc_allowed?(id)
      warn { "Npc not allowed in BuyList. BuyList ID: #{val}, Npc ID: #{id}." }
      pc.action_failed
      return
    end

    tax_rate = apply_tax ? mpc.total_tax_rate : 0.0

    pc.inventory_blocking_status = true

    if pc.gm?
      pc.send_message("BuyList [#{buy_list.list_id}]")
    end

    pc.send_packet(BuyList.new(buy_list, pc.adena, tax_rate))
    pc.send_packet(ExBuySellList.new(pc, false))
    pc.action_failed
  end
end
