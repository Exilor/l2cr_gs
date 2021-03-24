class Packets::Outgoing::ExPartyPetWindowUpdate < GameServerPacket
  initializer summon : L2Summon

  private def write_impl
    c 0xfe
    h 0x19

    d @summon.l2id
    d @summon.template.display_id &+ 1_000_000
    d @summon.summon_type
    d @summon.owner.l2id

    s @summon.name

    d @summon.current_hp
    d @summon.max_hp
    d @summon.current_mp
    d @summon.max_mp
    d @summon.level
  end
end
