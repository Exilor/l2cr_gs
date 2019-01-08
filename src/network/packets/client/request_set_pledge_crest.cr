class Packets::Incoming::RequestSetPledgeCrest < GameClientPacket
  @length = 0
  @data : Bytes?

  def read_impl
    @length = d

    if @length > 256
      debug "Length is too large (#{@length})."
      @data = nil
      return
    end

    @data = b(@length)
  end

  def run_impl
    return unless _data = @data
    return unless pc = active_char

    if @length < 0
      pc.send_packet(SystemMessageId::WRONG_SIZE_UPLOADED_CREST)
      return
    end

    if @length > 256
      pc.send_packet(SystemMessageId::THE_SIZE_OF_THE_IMAGE_FILE_IS_INAPPROPRIATE)
      return
    end

    return unless clan = pc.clan

    if clan.dissolving_expiry_time > Time.ms
      pc.send_packet(SystemMessageId::CANNOT_SET_CREST_WHILE_DISSOLUTION_IN_PROGRESS)
      return
    end

    unless pc.has_clan_privilege?(ClanPrivilege::CL_REGISTER_CREST)
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return
    end

    if @length == 0
      if clan.crest_id != 0
        clan.change_clan_crest(0)
        pc.send_packet(SystemMessageId::CLAN_CREST_HAS_BEEN_DELETED)
      end
    else
      if clan.level < 3
        pc.send_packet(SystemMessageId::CLAN_LVL_3_NEEDED_TO_SET_CREST)
        return
      end

      if crest = CrestTable.create_crest(_data, L2Crest::CrestType::PLEDGE)
        clan.change_clan_crest(crest.id)
        pc.send_packet(SystemMessageId::CLAN_CREST_WAS_SUCCESSFULLY_REGISTRED)
      end
    end
  end
end
