module AdminCommandHandler::AdminCreateItem
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    case command
    when "admin_itemcreate"
      AdminHtml.show_admin_html(pc, "itemcreation.htm")
    when /\Aadmin_create_item.*/
      begin
        st = command.from(17).split
        if st.size == 2
          val = st.shift.to_i
          num = st.shift.to_i64
          create_item(pc, pc, val, num)
        elsif st.size == 1
          val = st.shift.to_i
          create_item(pc, pc, val, 1)
        end
      rescue
        pc.send_message("Usage: //create_item <itemId> [amount]")
      end
      AdminHtml.show_admin_html(pc, "itemcreation.htm")
    when /\Aadmin_create_coin.*/
      begin
        st = command.from(17).split
        if st.size == 2
          name = st.shift
          val = get_coin_id(name)
          if val > 0
            num = st.shift.to_i64
            create_item(pc, pc, val, num)
          end
        elsif st.size == 1
          name = st.shift
          val = get_coin_id(name)
          create_item(pc, pc, val, 1)
        end
      rescue
        pc.send_message("Usage: //create_coin <name> [amount]")
      end
      AdminHtml.show_admin_html(pc, "itemcreation.htm")
    when /admin_give_item_target.*/
      begin
        unless target = pc.target.as?(L2PcInstance)
          pc.send_message("Invalid target.")
          return false
        end

        st = command.from(22).split
        if st.size == 2
          id = st.shift.to_i
          num = st.shift.to_i64
          create_item(pc, target, id, num)
        elsif st.size == 1
          id = st.shift.to_i
          create_item(pc, target, id, 1)
        end
      rescue
        pc.send_message("Usage: //give_item_target <itemId> [amount]")
      end
      AdminHtml.show_admin_html(pc, "itemcreation.htm")
    when /\Aadmin_give_item_to_all.*/
      st = command.from(22).split
      id = 0
      num = 0i64
      if st.size == 2
        id = st.shift.to_i
        num = st.shift.to_i64
      elsif st.size == 1
        id = st.shift.to_i
        num = 1i64
      end

      counter = 0
      unless template = ItemTable[id]?
        pc.send_message("No item with ID #{id} exists.")
        return false
      end

      if num > 10 && !template.stackable?
        pc.send_message("#{template.name} is not stackable. Creation aborted.")
        return false
      end

      L2World.players.each do |player|
        client = player.client
        if pc != player && player.online? && client && !client.detached?
          player.inventory.add_item("Admin", id, num, player, pc)
          player.send_message("Admin gave you #{template.name} x#{num}.")
          counter &+= 1
        end
      end
      pc.send_message("You gave #{template.name} to #{counter} players.")
    end


    true
  end

  private def create_item(pc, target, id, num : Int64)
    unless template = ItemTable[id]?
      pc.send_message("No item with ID #{id} exists.")
      return
    end

    if num > 10 && !template.stackable?
      pc.send_message("#{template.name} is not stackable. Creation aborted.")
      return
    end

    target.inventory.add_item("Admin", id, num, pc, nil)

    if pc != target
      target.send_message("Admin gave you #{template.name} x#{num}.")
    else
      pc.send_message("You have created #{template.name} x#{num}.")
    end
  end

  private def get_coin_id(name)
    case
    when name.casecmp?("adena") then 57
    when name.casecmp?("ancientadena") then 5575
    when name.casecmp?("festivaladena") then 6673
    when name.casecmp?("blueeva") then 4355
    when name.casecmp?("goldeinhasad") then 4356
    when name.casecmp?("silvershilen") then 4357
    when name.casecmp?("bloodypaagrio") then 4358
    when name.casecmp?("fantasyislecoin") then 13067
    else 0
    end
  end

  def commands
    {
      "admin_itemcreate",
      "admin_create_item",
      "admin_create_coin",
      "admin_give_item_target",
      "admin_give_item_to_all"
    }
  end
end
