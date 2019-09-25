class Packets::Outgoing::ExPartyPetWindowAdd < GameServerPacket
  initializer summon : L2Summon

  def write_impl
    c 0xfe
    h 0x18

    d @summon.l2id
    d @summon.template.display_id + 1_000_000
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
