class Packets::Incoming::RequestExSetPledgeCrestLarge < GameClientPacket
  @size = 0
  @data : Bytes?

  private def read_impl
    @size = d
    if @size > 2176
      return
    end
    @data = b(@size)
  end

  private def run_impl
    return unless pc = active_char
    return unless clan = pc.clan?
    return unless data = @data

    if @size < 0 || @size > 2176
      pc.send_packet(SystemMessageId::WRONG_SIZE_UPLOADED_CREST)
      return
    end

    if clan.dissolving_expiry_time > Time.ms
      pc.send_packet(SystemMessageId::CANNOT_SET_CREST_WHILE_DISSOLUTION_IN_PROGRESS)
      return
    end

    unless pc.has_clan_privilege?(ClanPrivilege::CL_REGISTER_CREST)
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return
    end

    if @size == 0
      if clan.crest_large_id != 0
        clan.change_large_crest(0)
        pc.send_packet(SystemMessageId::CLAN_CREST_HAS_BEEN_DELETED)
      end
    else
      if clan.level < 3
        pc.send_packet(SystemMessageId::CLAN_LVL_3_NEEDED_TO_SET_CREST)
        return
      end

      if crest = CrestTable.create_crest(data, L2Crest::CrestType::PLEDGE_LARGE)
        clan.change_large_crest(crest.id)
        pc.send_packet(SystemMessageId::CLAN_EMBLEM_WAS_SUCCESSFULLY_REGISTERED)
      else
        debug "Failed to create large crest."
      end
    end
  end
end
