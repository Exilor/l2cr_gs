class Packets::Incoming::RequestGiveNickName < GameClientPacket
  @target = ""
  @title = ""

  def read_impl
    @target = s
    @title = s
  end

  def run_impl
    return unless pc = active_char

    if pc.noble? && @target.casecmp?(pc.name)
      pc.title = @title
      pc.send_packet(SystemMessageId::TITLE_CHANGED)
      pc.broadcast_title_info
    else
      unless pc.has_clan_privilege?(ClanPrivilege::CL_GIVE_TITLE)
        pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
        return
      end

      if pc.clan.level < 3
        pc.send_packet(SystemMessageId::CLAN_LVL_3_NEEDED_TO_ENDOWE_TITLE)
        return
      end

      if member1 = pc.clan.get_clan_member(@target)
        if member = member1.player_instance?
          member.title = @title
          member.send_packet(SystemMessageId::TITLE_CHANGED)
          member.broadcast_title_info
        else
          pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
        end
      else
        pc.send_packet(SystemMessageId::TARGET_MUST_BE_IN_CLAN)
      end
    end
  end
end
