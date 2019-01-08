class Packets::Outgoing::RecipeShopMsg < GameServerPacket
  initializer pc: L2PcInstance

  def write_impl
    c 0xe1

    d @pc.l2id
    s @pc.store_name
  end
end
