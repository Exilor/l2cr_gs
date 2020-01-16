require "../game_client"

abstract class GameServerPacket < MMO::OutgoingPacket(GameClient)
  include Loggable

  property? invisible : Bool = false

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
    client?.try &.active_char
  end

  def run_impl
    # no-op
  end

  private def paperdoll_order
    yield Inventory::UNDER
    yield Inventory::REAR
    yield Inventory::LEAR
    yield Inventory::NECK
    yield Inventory::RFINGER
    yield Inventory::LFINGER
    yield Inventory::HEAD
    yield Inventory::RHAND
    yield Inventory::LHAND
    yield Inventory::GLOVES
    yield Inventory::CHEST
    yield Inventory::LEGS
    yield Inventory::FEET
    yield Inventory::CLOAK
    yield Inventory::RHAND
    yield Inventory::HAIR
    yield Inventory::HAIR2
    yield Inventory::RBRACELET
    yield Inventory::LBRACELET
    yield Inventory::DECO1
    yield Inventory::DECO2
    yield Inventory::DECO3
    yield Inventory::DECO4
    yield Inventory::DECO5
    yield Inventory::DECO6
    yield Inventory::BELT
  end

  private macro static_packet
    private initializer
    STATIC_PACKET = new
  end
end
