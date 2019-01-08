class Packets::Outgoing::ExPartyPetWindowDelete < GameServerPacket
  initializer summon: L2Summon

  def write_impl
    c 0xfe
    h 0x6a

    d @summon.l2id
    d @summon.owner.l2id
    s @summon.name
  end
end
