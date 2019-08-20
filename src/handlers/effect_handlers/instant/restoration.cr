class EffectHandler::Restoration < AbstractEffect
  @item_id : Int32
  @item_count : Int64

  def initialize(attach_cond, apply_cond, set, params)
    super

    @item_id = params.get_i32("itemId", 0)
    @item_count = params.get_i64("itemCount", 0)
  end

  def on_start(info)
    return unless info.effected.playable?

    if @item_id <= 0 || @item_count <= 0
      info.effected.send_packet(SystemMessageId::NOTHING_INSIDE_THAT)
      warn { "Effect with wrong item id or count (id: #{@item_id}, count: #{@item_count})." }
      return
    end

    if info.effected.player?
      info.effected.acting_player.add_item("Skill", @item_id, @item_count, info.effector, true)
    elsif info.effected.pet?
      info.effected.inventory.add_item("Skill", @item_id, @item_count, info.effected.acting_player, info.effector)
      info.effected.acting_player.send_packet(PetItemList.new(info.effected.inventory.items))
    end
  end

  def instant?
    true
  end
end
