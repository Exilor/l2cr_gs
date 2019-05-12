class Packets::Incoming::RequestExAskJoinMPCC < GameClientPacket
  @name = ""

  private def read_impl
    @name = s
  end

  private def run_impl
    return unless pc = active_char
    unless player = L2World.get_player(@name)
      debug "#{@name.inspect} not found."
      return
    end

    if pc.in_party? && player.in_party? && pc.party == player.party
      return
    end

    if pc.in_party?
      active_party = pc.party
      if active_party.leader == pc
        if active_party.in_command_channel? && active_party.command_channel.leader == pc
          if player.in_party?
            if player.party.in_command_channel?
              sm = SystemMessage.c1_already_member_of_command_channel
              sm.add_string(player.name)
              pc.send_packet(sm)
            else
              ask_join_mpcc(pc, player)
            end
          else
            msg ="#{player.name} doesn't have party and cannot be invited to Command Channel."
            pc.send_message(msg)
          end
        elsif active_party.in_command_channel? && active_party.command_channel.leader != pc
          pc.send_packet(SystemMessageId::CANNOT_INVITE_TO_COMMAND_CHANNEL)
        else
          if player.in_party?
            if player.party.in_command_channel?
              sm = SystemMessage.c1_already_member_of_command_channel
              sm.add_string(player.name)
              pc.send_packet(sm)
            else
              ask_join_mpcc(pc, player)
            end
          else
            msg = "#{player.name} doesn't have party and cannot be invited to Command Channel."
            pc.send_message(msg)
          end
        end
      else
        pc.send_packet(SystemMessageId::CANNOT_INVITE_TO_COMMAND_CHANNEL)
      end
    end
  end

  private def ask_join_mpcc(requestor, target)
    if requestor.clan_leader? && requestor.clan.level >= 5
      can = true
    elsif requestor.inventory.get_item_by_item_id(8871) # Strategy Guide
      can = true
      # L2J wonders if the item should be deleted.
    elsif requestor.pledge_class >= 5 && requestor.get_known_skill(391)
      # Baron or higher, skill "Clan Imperium".
      can = true
    end

    unless can
      requestor.send_packet(SystemMessageId::COMMAND_CHANNEL_ONLY_BY_LEVEL_5_CLAN_LEADER_PARTY_LEADER)
      return
    end

    target_leader = target.party.leader

    if target_leader.processing_request?
      sm = SystemMessage.c1_is_busy_try_later
      sm.add_string(target_leader.name)
      requestor.send_packet(sm)
    else
      requestor.on_transaction_request(target_leader)
      sm = SystemMessage.command_channel_confirm_from_c1
      sm.add_string(requestor.name)
      target_leader.send_packet(sm)
      target_leader.send_packet(ExAskJoinMPCC.new(requestor.name))
      msg = "You invited #{target_leader.name} to your Command Channel."
      requestor.send_message(msg)
    end
  end
end
