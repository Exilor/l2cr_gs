class Packets::Outgoing::PackageToList < GameServerPacket
  initializer players : Hash(Int32, String)

  private def write_impl
    c 0xc8

    d @players.size
    @players.each do |key, value|
      d key
      s value
    end
  end
end
