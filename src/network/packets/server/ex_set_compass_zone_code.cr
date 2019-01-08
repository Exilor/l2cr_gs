class Packets::Outgoing::ExSetCompassZoneCode < GameServerPacket
  ALTEREDZONE = 0x08u8
  SIEGEWARZONE1 = 0x0Au8
  SIEGEWARZONE2 = 0x0Bu8
  PEACEZONE = 0x0Cu8
  SEVENSIGNSZONE = 0x0Du8
  PVPZONE = 0x0Eu8
  GENERALZONE = 0x0Fu8

  initializer zone_type: UInt8

  def write_impl
    c 0xfe
    h 0x33

    d @zone_type
  end
end
