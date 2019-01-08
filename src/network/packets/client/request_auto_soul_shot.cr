class Packets::Incoming::RequestAutoSoulShot < GameClientPacket
  no_action_request

  @item_id = 0
  @type = 0

  def read_impl
    @item_id = d
    @type = d
  end

  def run_impl
    return unless pc = active_char

    return unless pc.private_store_type.none? && !pc.active_requester
    return unless pc.alive?
    return unless item = pc.inventory.get_item_by_item_id(@item_id)

    unless pc.inventory.can_manipulate_with_item_id?(@item_id)
      pc.send_message("Cannot use this item.")
      return
    end

    if @type == 1
      if @item_id < 6535 || @item_id > 6540 # fishing shots are not auto on retail
        if 6645 <= @item_id <= 6647 || 20332 <= @item_id <= 20334
          if summon = pc.summon
            if item.etc_item!.handler_name == "BeastSoulShot"
              if summon.soulshots_per_hit > item.count
                pc.send_packet(SystemMessageId::NOT_ENOUGH_SOULSHOTS_FOR_PET)
                return
              end
            else
              if summon.spiritshots_per_hit > item.count
                pc.send_packet(SystemMessageId::NOT_ENOUGH_SOULSHOTS_FOR_PET)
                return
              end
            end

            pc.add_auto_shot(@item_id)
            pc.send_packet(ExAutoSoulShot.new(@item_id, @type))

            sm = SystemMessage.use_of_s1_will_be_auto
            sm.add_item_name(item)
            pc.send_packet(sm)

            pc.recharge_shots(true, true)
            summon.recharge_shots(true, true)
          else
            pc.send_packet(SystemMessageId::NO_SERVITOR_CANNOT_AUTOMATE_USE)
          end
        else
          if pc.active_weapon_item? != pc.fists_weapon_item? && item.template.crystal_type == pc.active_weapon_item.item_grade_s_plus
            pc.add_auto_shot(@item_id)
            pc.send_packet(ExAutoSoulShot.new(@item_id, @type))
          else
            if ((@item_id >= 2509) && (@item_id <= 2514)) || ((@item_id >= 3947) && (@item_id <= 3952)) || (@item_id == 5790) || ((@item_id >= 22072) && (@item_id <= 22081))
              pc.send_packet(SystemMessageId::SPIRITSHOTS_GRADE_MISMATCH)
              return action_failed # custom
            else
              pc.send_packet(SystemMessageId::SOULSHOTS_GRADE_MISMATCH)
              return action_failed # custom
            end
          end
          sm = SystemMessage.use_of_s1_will_be_auto
          sm.add_item_name(item)
          pc.send_packet(sm)
          pc.recharge_shots(true, true)
        end
      end
    elsif @type == 0
      pc.remove_auto_shot(@item_id)
      pc.send_packet(ExAutoSoulShot.new(@item_id, @type))

      sm = SystemMessage.auto_use_of_s1_cancelled
      sm.add_item_name(item)
      pc.send_packet(sm)
    end
  end
end
