class L2NpcBufferInstance < L2Npc
  PAGE_VAL = {} of Int32 => Int32

  def instance_type : InstanceType
    InstanceType::L2NpcBufferInstance
  end

  def show_chat_window(pc : L2PcInstance, val : Int32)
    if val > 0
      htm_content = HtmCache.get_htm(pc, "data/html/mods/NpcBuffer-#{val}.htm")
    else
      htm_content = HtmCache.get_htm(pc, "data/html/mods/NpcBuffer.htm")
    end

    if htm_content
      html = NpcHtmlMessage.new(l2id)
      html.html = htm_content
      html["%objectId%"] = l2id
      pc.send_packet(html)
    end

    pc.action_failed
  end

  def on_bypass_feedback(pc : L2PcInstance, cmd : String)
    last_folk_npc = pc.last_folk_npc
    if last_folk_npc.nil? || last_folk_npc.l2id != l2id
      return
    end

    target = pc
    if cmd.starts_with?("Pet")
      unless target = pc.summon # TODO: Should be hasPet ?
        pc.send_packet(SystemMessageId::DONT_HAVE_PET)
        show_chat_window(pc, 0) # 0 = main window
        return
      end
    end

    npc_id = id
    if cmd.starts_with?("Chat")
      val = cmd.from(5).to_i

      PAGE_VAL[pc.l2id] = val

      show_chat_window(pc, val)
    elsif cmd.starts_with?("Buff") || cmd.starts_with?("PetBuff")
      buff_group_ary = cmd.from(cmd.index("Buff").not_nil! + 5).split

      buff_group_ary.each do |buff_group_list|
        buff_group = buff_group_list.to_i

        unless info = NpcBufferTable.get_skill_info(npc_id, buff_group)
          warn { "NPC Buffer Warning: npc_id = #{npc_id} Location: #{x}, #{y}, #{y} player: #{pc.name} has tried to use skill group (#{buff_group}) not assigned to the NPC Buffer." }
          return
        end

        if info.fee.id != 0
          item_instance = pc.inventory.get_item_by_item_id(info.fee.id)
          if item_instance.nil? || (!item_instance.stackable? && pc.inventory.get_inventory_item_count(info.fee.id, -1) < info.fee.count)
            sm = SystemMessageId::THERE_ARE_NOT_ENOUGH_NECESSARY_ITEMS_TO_USE_THE_SKILL
            pc.send_packet(sm)
            next
          end

          if item_instance.stackable?
            unless pc.destroy_item_by_item_id("Npc Buffer", info.fee.id, info.fee.count, pc.target, true)
              sm = SystemMessageId::THERE_ARE_NOT_ENOUGH_NECESSARY_ITEMS_TO_USE_THE_SKILL
              pc.send_packet(sm)
              next
            end
          else
            info.fee.count.times do |i|
              pc.destroy_item_by_item_id("Npc Buffer", info.fee.id, 1, pc.target, true)
            end
          end
        end

        if skill = SkillData[info.skill.skill_id, info.skill.skill_lvl]?
          skill.apply_effects(pc, target)
        end
      end

      show_chat_window(pc, PAGE_VAL[pc.l2id])
    elsif cmd.starts_with?("Heal") || cmd.starts_with?("PetHeal")
      if !target.in_combat? && !AttackStances.includes?(target)
        heal_ary = cmd.from(cmd.index("Heal").not_nil! + 5).split

        heal_ary.each do |heal_type|
          if heal_type.casecmp?("HP")
            target.max_hp!
          elsif heal_type.casecmp?("MP")
            target.max_mp!
          elsif heal_type.casecmp?("CP")
            target.max_cp!
          end
        end
      end
      show_chat_window(pc, PAGE_VAL[pc.l2id])
    elsif cmd.starts_with?("RemoveBuffs") || cmd.starts_with?("PetRemoveBuffs")
      target.stop_all_effects_except_those_that_last_through_death
      show_chat_window(pc, PAGE_VAL[pc.l2id])
    else
      super
    end
  end
end
