class Packets::Outgoing::ExCursedWeaponLocation < GameServerPacket
  initializer infos: Array(Incoming::RequestCursedWeaponLocation::CursedWeaponInfo)

  def write_impl
    c 0xfe
    h 0x47

    if @infos.empty?
      d 0
      d 0
    else
      d @infos.size
      @infos.each do |cw|
        d cw.id
        d cw.status
        l cw.pos
      end
    end
  end
end
