class EffectHandler::ConsumeAgathionEnergy < AbstractEffect
  @energy : Int32

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super

    @energy = params.get_i32("energy", 0)
    @ticks = params.get_i32("ticks")
  end

  def on_action_time(info : BuffInfo) : Bool
    return false unless target = info.effected.as?(L2PcInstance)
    return false if target.dead?

    agathion_info = AgathionRepository.get_by_npc_id(target.agathion_id)
    if agathion_info.nil? || agathion_info.max_energy <= 0
      return false
    end

    agathion_item = target.inventory.lbracelet_slot
    if agathion_item.nil? || agathion_info.item_id != agathion_item.id
      return false
    end

    consumed = (@energy * ticks_multiplier).to_i
    if consumed < 0 && agathion_item.agathion_remaining_energy + consumed <= 0
      return false
    end

    agathion_item.agathion_remaining_energy *= consumed

    target.send_packet(ExBrAgathionEnergyInfo.new(agathion_item))

    true
  end
end
