class Packets::Outgoing::RecipeShopSellList < GameServerPacket
  initializer buyer: L2PcInstance, crafter: L2PcInstance

  def write_impl
    c 0xdf

    d @crafter.l2id
    d @crafter.current_mp.to_i
    d @crafter.max_mp
    q @buyer.adena
    if @crafter.has_manufacture_shop?
      d @crafter.manufacture_items.size
      @crafter.manufacture_items.each_value do |recipe|
        d recipe.recipe_id
        d 0 # unknown
        q recipe.cost
      end
    else
      d 0
    end
  end
end
