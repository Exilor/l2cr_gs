class Packets::Outgoing::ServerStatus < MMO::OutgoingPacket(LoginServerClient)
  STATUS_STRING = {"Auto", "Good", "Normal", "Full", "Down", "Gm Only"}

  SERVER_LIST_STATUS = 0x01
  SERVER_TYPE = 0x02
  SERVER_LIST_SQUARE_BRACKET = 0x03
  MAX_PLAYERS = 0x04
  TEST_SERVER = 0x05
  SERVER_AGE = 0x06

  # Server Status
  STATUS_AUTO = 0x00
  STATUS_GOOD = 0x01
  STATUS_NORMAL = 0x02
  STATUS_FULL = 0x03
  STATUS_DOWN = 0x04
  STATUS_GM_ONLY = 0x05

  # Server Types
  SERVER_NORMAL = 0x01
  SERVER_RELAX = 0x02
  SERVER_TEST = 0x04
  SERVER_NOLABEL = 0x08
  SERVER_CREATION_RESTRICTED = 0x10
  SERVER_EVENT = 0x20
  SERVER_FREE = 0x40

  # Server Ages
  SERVER_AGE_ALL = 0x00
  SERVER_AGE_15 = 0x0F
  SERVER_AGE_18 = 0x12

  ON = 0x01
  OFF = 0x00

  private record Attribute, id : Int32, value : Int32

  @attributes = [] of Attribute

  def add(id : Int32, value : Int32)
    @attributes << Attribute.new(id, value)
  end

  def write
    c 0x06

    d @attributes.size
    @attributes.each do |attr|
      d attr.id
      d attr.value
    end
  end
end
