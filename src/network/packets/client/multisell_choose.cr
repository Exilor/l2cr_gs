class Packets::Incoming::MultisellChoose < GameClientPacket
  @list_id = 0
  @entry_id = 0
  @amount = 0i64

  private def read_impl
    @list_id = d
    @entry_id = d
    @amount = q
  end

  private def run_impl
    return unless pc = active_char

    unless flood_protectors.multisell.try_perform_action("multisell choose")
      debug { "#{pc.name} is spamming multisell." }
      pc.multisell = nil
      return
    end

    if @amount < 1 || @amount > 5000
      pc.multisell = nil
      return
    end

    list = pc.multisell

    if list.nil? || list.list_id != @list_id
      debug "Missing or wrong multisell list."
      pc.multisell = nil
      return
    end

    npc = pc.last_folk_npc

    if (npc && !list.npc_allowed?(npc.id)) || (!npc && list.npc_only?)
      pc.multisell = nil
      return
    end

    if !pc.gm? && npc
      if !pc.inside_radius?(npc, L2Npc::INTERACTION_DISTANCE, true, false) || pc.instance_id != npc.instance_id
        pc.multisell = nil
        return
      end
    end

    list.entries.each do |entry|
      if entry.entry_id == @entry_id
        if !entry.stackable? && @amount > 1
          warn { "#{pc} tried to buy more than one non-stackable items." }
          pc.multisell = nil
          return
        end

        inv = pc.inventory

        slots = weight = 0

        entry.products.each do |e|
          next if e.item_id < 0

          if !e.stackable?
            slots += e.item_count * @amount
          elsif inv.get_item_by_item_id(e.item_id).nil?
            slots += 1
          end
          weight += e.item_count * @amount * e.weight
        end

        if !inv.validate_weight(weight)
          pc.send_packet(SystemMessageId::WEIGHT_LIMIT_EXCEEDED)
          return
        end

        ingredients_list = [] of Multisell::Ingredient

        entry.ingredients.each do |e|
          new_ing = true

          (ingredients_list.size - 1).downto(0) do |i|
            ex = ingredients_list[i]
            if ex.item_id == e.item_id && ex.enchant_level == e.enchant_level
              if ex.item_count + e.item_count > Int32::MAX
                pc.send_packet(SystemMessageId::YOU_HAVE_EXCEEDED_QUANTITY_THAT_CAN_BE_INPUTTED)
                return
              end

              ing = ex.clone
              ing.item_count = ex.item_count + e.item_count
              ingredients_list[i] = ing
              new_ing = false
              break
            end
          end

          ingredients_list << e if new_ing
        end

        ingredients_list.each do |e|
          if e.item_count * @amount > Int32::MAX
            pc.send_packet(SystemMessageId::YOU_HAVE_EXCEEDED_QUANTITY_THAT_CAN_BE_INPUTTED)
            return
          end

          if e.item_id < 0

            unless MultisellData.has_special_ingredient?(e.item_id, e.item_count * @amount, pc)
              debug "MultisellData.has_special_ingredient? returned false (1)"
              return
            end
          else
            if Config.alt_blacksmith_use_recipes || !e.maintain_ingredient?
              required = e.item_count * @amount
            else
              required = e.item_count
            end

            if inv.get_inventory_item_count(e.item_id, list.maintain_enchantment? ? e.enchant_level : -1, false) < required
              sm = SystemMessage.s2_unit_of_the_item_s1_required
              sm.add_item_name(e.template.not_nil!)
              sm.add_long(required)
              pc.send_packet(sm)
              return
            end
          end
        end

        augmentation = [] of L2Augmentation
        elementals = [] of Elementals

        entry.ingredients.each do |e|
          if e.item_id < 0
            unless MultisellData.take_special_ingredient(e.item_id, e.item_count * @amount, pc)
              debug "MultisellData.has_special_ingredient? returned false (2)"
              return
            end
          else
            unless item_to_take = inv.get_item_by_item_id(e.item_id)
              warn { "#{pc} doesn't have an item with item_id #{e.item_id}." }
              pc.multisell = nil
              return
            end

            if Config.alt_blacksmith_use_recipes || !e.maintain_ingredient?
              if item_to_take.stackable?
                unless pc.destroy_item("Multisell", item_to_take.l2id, e.item_count * @amount, pc.target, true)
                  debug { "Couldn't destroy #{item_to_take}." }
                  pc.multisell = nil
                  return
                end
              else
                if list.maintain_enchantment?
                  contents = inv.get_all_items_by_item_id(e.item_id, e.enchant_level, false)
                  (e.item_count * @amount).times do |i|
                    if contents[i].augmented?
                      augmentation << contents[i].augmentation
                    end

                    if elem = contents[i].elementals
                      elementals = elem
                    end

                    unless pc.destroy_item("Multisell", contents[i].l2id, 1, pc.target, true)
                      pc.multisell = nil
                      return
                    end
                  end
                else
                  contents = inv.get_all_items_by_item_id(e.item_id, e.enchant_level, false)
                  item_to_take = contents[0]
                  if item_to_take.enchant_level > 0
                    contents.each do |item|
                      if item.enchant_level < item_to_take.enchant_level
                        item_to_take = item
                        if item_to_take.enchant_level == 0
                          break
                        end
                      end
                    end
                  end

                  unless pc.destroy_item("Multisell", item_to_take.l2id, 1, pc.target, true)
                    pc.multisell = nil
                    return
                  end
                end
              end
            end
          end
        end

        entry.products.each do |e|
          if e.item_id < 0
            MultisellData.give_special_product(e.item_id, e.item_count * @amount, pc)
          else
            if e.stackable?
              inv.add_item("Multisell", e.item_id, e.item_count * @amount, pc, pc.target)
            else
              (e.item_count * @amount).times do |i|
                product = inv.add_item("Multisell", e.item_id, 1, pc, pc.target)
                if product && list.maintain_enchantment?
                  if i < augmentation.size
                    product.set_augmentation(L2Augmentation.new(augmentation[i].augmentation_id))
                  end
                  elementals.try &.each do |elm|
                    product.set_element_attr(elm.element, elm.value)
                  end
                  product.enchant_level = e.enchant_level
                  product.update_database
                end
              end
            end

            if e.item_count * @amount > 1
              sm = SystemMessage.earned_s2_s1_s
              sm.add_item_name(e.item_id)
              sm.add_long(e.item_count * @amount)
              pc.send_packet(sm)
            else
              if list.maintain_enchantment? && e.enchant_level > 0
                sm = SystemMessage.acquired_s1_s2
                sm.add_long(e.enchant_level)
                sm.add_item_name(e.item_id)
              else
                sm = SystemMessage.earned_item_s1
                sm.add_item_name(e.item_id)
              end

              pc.send_packet(sm)
            end
          end
        end

        pc.send_packet(ItemList.new(pc, false))
        pc.send_packet(StatusUpdate.current_load(pc))

        if npc && entry.tax_amount > 0
          npc.castle.add_to_treasury(entry.tax_amount * @amount)
        end

        break
      end
    end
  end
end
