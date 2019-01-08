class Packets::Outgoing::ExCursedWeaponList < GameServerPacket
  initializer cursed_weapon_ids: Array(Int32)

  def write_impl
    c 0xfe
    h 0x46

    d @cursed_weapon_ids.size
    @cursed_weapon_ids.each { |id| d id }
  end
end
