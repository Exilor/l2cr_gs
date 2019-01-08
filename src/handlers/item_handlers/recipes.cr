module ItemHandler::Recipes
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    unless pc = playable.as?(L2PcInstance)
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    if pc.in_craft_mode?
      pc.send_packet(SystemMessageId::CANT_ALTER_RECIPEBOOK_WHILE_CRAFTING)
      return false
    end

    return false unless rp = RecipeData.get_recipe_by_item_id(item.id)

    if pc.has_recipe_list?(rp.id)
      pc.send_packet(SystemMessageId::RECIPE_ALREADY_REGISTERED)
      return false
    end

    can_craft = false
    recipe_level = false
    recipe_limit = false

    if rp.dwarven_recipe?
      can_craft = pc.has_dwarven_craft?
      recipe_level = rp.level > pc.dwarven_craft
      recipe_limit = pc.dwarven_recipe_book.size >= pc.dwarf_recipe_limit
    else
      can_craft = pc.has_common_craft?
      recipe_level = rp.level > pc.common_craft
      recipe_limit = pc.common_recipe_book.size >= pc.common_recipe_limit
    end

    unless can_craft
      pc.send_packet(SystemMessageId::CANT_REGISTER_NO_ABILITY_TO_CRAFT)
      return false
    end

    if recipe_level
      pc.send_packet(SystemMessageId::CREATE_LVL_TOO_LOW_TO_REGISTER)
      return false
    end

    if recipe_limit
      sm = SystemMessage.up_to_s1_recipes_can_register
      if rp.dwarven_recipe?
        sm.add_int(pc.dwarf_recipe_limit)
      else
        sm.add_int(pc.common_recipe_limit)
      end
      pc.send_packet(sm)
      return false
    end

    if rp.dwarven_recipe?
      pc.register_dwarven_recipe_list(rp, true)
    else
      pc.register_common_recipe_list(rp, true)
    end

    pc.destroy_item("Consume", item.l2id, 1, nil, false)
    sm = SystemMessage.s1_added
    sm.add_item_name(item)
    pc.send_packet(sm)

    true
  end
end
