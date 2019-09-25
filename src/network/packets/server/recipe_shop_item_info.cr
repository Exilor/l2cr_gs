class Packets::Outgoing::RecipeShopItemInfo < GameServerPacket
  initializer pc : L2PcInstance, recipe_id : Int32

  def write_impl
    c 0xe0

    d @pc.l2id
    d @recipe_id
    d @pc.current_mp.to_i
    d @pc.max_mp
    d 0xffffffff
  end
end
