class EffectHandler::CallPc < AbstractEffect
  @item_id : Int32
  @item_count : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @item_id = params.get_i32("itemId", 0)
    @item_count = params.get_i32("itemCount", 0)
  end

  def instant?
    true
  end

  def on_start(info)
    return if info.effected == info.effector

    target = info.effected.acting_player
    char = info.effector.acting_player

    if char.can_summon_target?(target)
      target.add_script(SummonRequestHolder.new(char, @item_id, @item_count))
      confirm = ConfirmDlg.c1_wishes_to_summon_you_from_s2_do_you_accept
      confirm.add_char_name(char)
      confirm.add_zone_name(*char.xyz)
      confirm.time = 30_000
      confirm.requester_id = char.l2id
      target.send_packet(confirm)
    end
  end
end
