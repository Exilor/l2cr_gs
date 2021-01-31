class EffectHandler::Restoration < AbstractEffect
  @item_id : Int32
  @item_count : Int64

  def initialize(attach_cond, apply_cond, set, params)
    super

    @item_id = params.get_i32("itemId", 0)
    @item_count = params.get_i64("itemCount", 0)
  end

  def on_start(info : BuffInfo)
    return unless info.effected.playable?

    if @item_id <= 0 || @item_count <= 0
      info.effected.send_packet(SystemMessageId::NOTHING_INSIDE_THAT)
      return
    end

    if pc = info.effected.as?(L2PcInstance)
      pc.add_item("Skill", @item_id, @item_count, info.effector, true)
    elsif pet = info.effected.as?(L2PetInstance)
      owner = pet.acting_player
      pet.inventory.add_item("Skill", @item_id, @item_count, owner, info.effector)
      owner.send_packet(PetItemList.new(pet.inventory.items))
    end
  end

  def instant? : Bool
    true
  end
end
