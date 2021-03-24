class Packets::Outgoing::PartySmallWindowAll < GameServerPacket
  initializer newcomer : L2PcInstance, party : L2Party

  private def write_impl
    c 0x4e

    d @party.leader_l2id
    d @party.distribution_type.to_i
    d @party.size &- 1

    @party.each do |m|
      next if m == @newcomer

      d m.l2id
      s m.name

      d m.current_cp
      d m.max_cp
      d m.current_hp
      d m.max_hp
      d m.current_mp
      d m.max_mp
      d m.level
      d m.class_id.to_i
      d 0x00
      d m.race.to_i
      d 0x00
      d 0x00

      if summon = m.summon
        d summon.l2id
        d summon.id &+ 1_000_000
        d summon.summon_type
        s summon.name

        d summon.current_hp
        d summon.max_hp
        d summon.current_mp
        d summon.max_mp
        d summon.level
      else
        d 0x00
      end
    end
  end
end
