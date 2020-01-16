class Packets::Outgoing::SkillCoolTime < GameServerPacket
  @time_stamps = [] of TimeStamp

  def initialize(pc : L2PcInstance)
    pc.skill_reuse_time_stamps.try &.each_value do |ts|
      if ts.has_not_passed?
        @time_stamps << ts
      end
    end
  end

  private def write_impl
    c 0xc7

    d @time_stamps.size
    @time_stamps.each do |ts|
      d ts.skill_id
      d ts.skill_lvl
      d (ts.reuse / 1000).to_i
      d (ts.remaining / 1000).to_i
    end
  end
end
