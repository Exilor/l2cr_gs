class Packets::Outgoing::SellList < GameServerPacket
  @sell_list = [] of L2ItemInstance
  @money : Int64

  def initialize(pc : L2PcInstance, lease : L2MerchantInstance? = nil)
    @pc = pc
    @lease = lease
    @money = pc.adena
    do_lease
  end

  private def do_lease
    unless @lease
      @pc.inventory.items.each do |item|
        if !item.equipped? && item.sellable?
          if !@pc.has_summon? || item.l2id != @pc.summon.control_l2id
            @sell_list << item
          end
        end
      end
    end
  end

  private def write_impl
    c 0x06

    q @money

    if lease = @lease
      d 1_000_000 + lease.template.id
    else
      d 0
    end

    h @sell_list.size
    @sell_list.each do |item|
      h item.template.type_1.id
      d item.l2id
      d item.display_id
      q item.count
      h item.template.type_2.id
      h item.equipped? ? 1 : 0
      d item.template.body_part
      h item.enchant_level
      h 0
      h item.custom_type_2
      q item.reference_price / 2
      h item.attack_element_type
      h item.attack_element_power
      6.times { |i| h item.get_element_def_attr(i) }
      item.enchant_options.each { |op| h op }
    end
  end
end
