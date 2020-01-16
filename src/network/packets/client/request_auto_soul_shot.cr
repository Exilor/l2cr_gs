class Packets::Incoming::RequestAutoSoulShot < GameClientPacket
  no_action_request

  @item_id = 0
  @type = 0

  private def read_impl
    @item_id = d
    @type = d
  end

  private def run_impl
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
        if @item_id.between?(6645, 6647) || @item_id.between?(20332, 20334)
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
          wep = pc.active_weapon_item
          if wep != pc.fists_weapon_item && item.template.crystal_type == wep.not_nil!.item_grade_s_plus
            pc.add_auto_shot(@item_id)
            pc.send_packet(ExAutoSoulShot.new(@item_id, @type))
          else
            if @item_id.between?(2509, 2514) || @item_id.between?(3947, 3952) || @item_id == 5790 || @item_id.between?(22072, 22081)
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
