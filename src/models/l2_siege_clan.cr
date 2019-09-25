class L2SiegeClan
  getter flag = [] of L2Npc
  setter type : SiegeClanType

  getter_initializer clan_id : Int32, type : SiegeClanType

  def add_flag(flag : L2Npc)
    @flag << flag
  end

  def num_flags : Int32
    @flag.size
  end

  def remove_flag(flag : L2Npc) : Bool
    ret = @flag.delete(flag)
    flag.delete_me
    !!ret
  end

  def remove_flags
    @flag.each &.decay_me
    @flag.clear
  end
end
