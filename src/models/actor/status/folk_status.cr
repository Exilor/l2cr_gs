require "./npc_status"

class FolkStatus < NpcStatus
  def reduce_hp(value : Float64, attacker : L2Character?)
    reduce_hp(value, attacker, true, false, false)
  end

  def reduce_hp(value : Float64, attacker : L2Character?, awake : Bool, dot : Bool, hp_consume : Bool)
    # no-op
  end

  def reduce_mp(value : Float64)
    unless Config.ch_buff_free && @active_char.is_a?(L2ClanHallManagerInstance)
      super
    end
  end

  def active_char : L2NpcInstance
    super.as(L2NpcInstance)
  end
end
