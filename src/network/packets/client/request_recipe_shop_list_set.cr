class Packets::Incoming::RequestRecipeShopListSet < GameClientPacket
  no_action_request

  BATCH_LENGTH = 12

  @items = Slice(L2ManufactureItem).empty

  private def read_impl
    count = d
    if count <= 0 || count > Config.max_item_in_packet || count * BATCH_LENGTH != buffer.remaining
      return
    end

    items = Slice.new(count) do
      id = d
      cost = q
      if cost < 0
        return
      end

      L2ManufactureItem.new(id, cost)
    end

    @items = items
  end

  private def run_impl
    return unless pc = active_char

    if @items.empty?
      pc.private_store_type = PrivateStoreType::NONE
      pc.broadcast_user_info
      return
    end

    if AttackStances.includes?(pc) || pc.in_duel?
      send_packet(SystemMessageId::CANT_OPERATE_PRIVATE_STORE_DURING_COMBAT)
      action_failed
      return
    end

    if pc.inside_no_store_zone?
      send_packet(SystemMessageId::NO_PRIVATE_WORKSHOP_HERE)
      action_failed
      return
    end

    dwarf_recipes = pc.dwarven_recipe_book
    common_recipes = pc.common_recipe_book

    @items.each do |i|
      list = RecipeData.get_recipe_list(i.recipe_id)
      unless dwarf_recipes.includes?(list) || common_recipes.includes?(list)
        Util.punish(pc, "tried to set a recipe he doesn't have for private manifacture.")
        return
      end

      if i.cost > Inventory.max_adena
        Util.punish(pc, "tried to set price to more than #{Inventory.max_adena} adena in private manufacture.")
        return
      end

      pc.manufacture_items[i.recipe_id] = i
    end

    pc.store_name = pc.has_manufacture_shop? ? pc.store_name : ""
    pc.private_store_type = PrivateStoreType::MANUFACTURE
    pc.sit_down
    pc.broadcast_user_info
    Broadcast.to_self_and_known_players(pc, RecipeShopMsg.new(pc))
  end
end
