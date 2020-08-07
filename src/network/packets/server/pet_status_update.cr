class Packets::Outgoing::PetStatusUpdate < GameServerPacket
  @cur_fed = 0
  @max_fed = 0

  def initialize(summon : L2Summon)
    @summon = summon
    if summon.is_a?(L2PetInstance)
      @cur_fed = summon.current_feed
      @max_fed = summon.max_fed
    elsif summon.is_a?(L2ServitorInstance)
      @cur_fed = summon.life_time_remaining
      @max_fed = summon.life_time
    end
  end

  private def write_impl
    c 0xb6

    d @summon.summon_type
    d @summon.l2id
    l @summon
    s @summon.title
    d @cur_fed
    d @max_fed
    d @summon.current_hp.to_i
    d @summon.max_hp
    d @summon.current_mp.to_i
    d @summon.max_mp
    d @summon.level
    q @summon.stat.exp
    q @summon.exp_for_this_level # 0% absolute value
    q @summon.exp_for_next_level # 100% absolute value
  end
end
