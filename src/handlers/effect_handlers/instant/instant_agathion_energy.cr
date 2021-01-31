require "../../../agathion/agathion_repository"

class EffectHandler::InstantAgathionEnergy < AbstractEffect
  @energy : Float64
  @mode : EffectCalculationType

  def initialize(attach_cond, apply_cond, set, params)
    super

    @energy = params.get_f64("energy", 0)
    @mode = params.get_enum("mode", EffectCalculationType, EffectCalculationType::DIFF)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    target = info.effected
    return if target.dead? || !target.is_a?(L2PcInstance)

    agathion_info = AgathionRepository.get_by_npc_id(target.agathion_id)
    if agathion_info.nil? || agathion_info.max_energy <= 0
      return
    end

    agathion_item = target.inventory.lbracelet_slot
    if agathion_item.nil? || agathion_info.item_id != agathion_item.id
      return
    end

    agathion_energy =
      if @mode.diff?
        Math.max(0, agathion_item.agathion_remaining_energy + @energy).to_i
      elsif @mode.per?
        (agathion_item.agathion_remaining_energy * @energy / 100).to_i
      end

    agathion_item.agathion_remaining_energy = agathion_energy || 0

    target.send_packet(ExBrAgathionEnergyInfo.new(agathion_item))
  end
end
