require "../game_client"

abstract class GameServerPacket < MMO::OutgoingPacket(MMO::Client(GameClient))
  include Loggable

  property? invisible : Bool = false

  private PAPERDOLL_ORDER = {
    Inventory::UNDER,
    Inventory::REAR,
    Inventory::LEAR,
    Inventory::NECK,
    Inventory::RFINGER,
    Inventory::LFINGER,
    Inventory::HEAD,
    Inventory::RHAND,
    Inventory::LHAND,
    Inventory::GLOVES,
    Inventory::CHEST,
    Inventory::LEGS,
    Inventory::FEET,
    Inventory::CLOAK,
    Inventory::RHAND,
    Inventory::HAIR,
    Inventory::HAIR2,
    Inventory::RBRACELET,
    Inventory::LBRACELET,
    Inventory::DECO1,
    Inventory::DECO2,
    Inventory::DECO3,
    Inventory::DECO4,
    Inventory::DECO5,
    Inventory::DECO6,
    Inventory::BELT
  }

  def l(loc)
    d loc.x
    d loc.y
    d loc.z
  end

  def write
    write_impl
  rescue e
    error e
  end

  abstract def write_impl

  def active_char : L2PcInstance?
    client.active_char
  end

  def run_impl
    # no-op
  end

  private macro static_packet
    private initializer
    STATIC_PACKET = new
  end
end
