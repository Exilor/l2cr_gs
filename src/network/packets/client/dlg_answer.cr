require "../../../models/holders/summon_request_holder"
require "../../../models/holders/door_request_holder"

class Packets::Incoming::DlgAnswer < GameClientPacket
  @message_id = 0
  @answer = 0
  @requester_id = 0

  private def read_impl
    @message_id = d
    @answer = d
    @requester_id = d
  end

  private def run_impl
    return unless pc = active_char

    evt = OnPlayerDlgAnswer.new(pc, @message_id, @answer, @requester_id)
    term = EventDispatcher.notify(evt, pc, TerminateReturn)
    return if term && term.terminate

    case @message_id
    when SystemMessageId::S1.id
      if pc.remove_action(PlayerAction::USER_ENGAGE)
        if Config.allow_wedding
          pc.engage_answer(@answer)
        end
      elsif pc.remove_action(PlayerAction::ADMIN_COMMAND)
        cmd = pc.admin_confirm_cmd.not_nil!
        pc.admin_confirm_cmd = nil
        return if @answer == 0
        command = cmd.split[0]
        if AdminData.has_access?(command, pc.access_level)
          handler = AdminCommandHandler[command].not_nil!
          if Config.gmaudit
            target_name = pc.target.try &.name || "no-target"
            GMAudit.log("#{pc.name} [#{pc.l2id}]", cmd, target_name)
          end
          handler.use_admin_command(cmd, pc)
        end
      end
    when SystemMessageId::RESURRECTION_REQUEST_BY_C1_FOR_S2_XP.id, SystemMessageId::RESURRECT_USING_CHARM_OF_COURAGE.id
      pc.revive_answer(@answer)
    when SystemMessageId::C1_WISHES_TO_SUMMON_YOU_FROM_S2_DO_YOU_ACCEPT.id
      holder = pc.remove_script(SummonRequestHolder)
      if @answer == 1 && holder && holder.requester.can_summon_target?(pc)
        if holder.requester.l2id == @requester_id
          if holder.item_id != 0 && holder.item_count != 0
            if pc.inventory.get_inventory_item_count(holder.item_id, 0) < holder.item_count
              sm = SystemMessage.s1_required_for_summoning
              sm.add_item_name(holder.item_id)
              pc.send_packet(sm)
              return
            end
            pc.inventory.destroy_item_by_item_id(
              "Consume", holder.item_id, holder.item_count.to_i64, pc, pc
            )
            sm = SystemMessage.s1_disappeared
            sm.add_item_name(holder.item_id)
          end
          pc.tele_to_location(holder.requester.location, true)
        end
      end
    when SystemMessageId::WOULD_YOU_LIKE_TO_OPEN_THE_GATE.id
      holder = pc.remove_script(DoorRequestHolder)
      if holder && holder.door == pc.target && @answer == 1
        holder.door.open_me
      end
    when SystemMessageId::WOULD_YOU_LIKE_TO_CLOSE_THE_GATE.id
      holder = pc.remove_script(DoorRequestHolder)
      if holder && holder.door == pc.target && @answer == 1
        holder.door.close_me
      end
    else
      # automatically added
    end

  end
end