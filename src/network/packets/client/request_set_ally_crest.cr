class Packets::Incoming::RequestSetAllyCrest < GameClientPacket
  @length = 0
  @data = Bytes.empty

  private def read_impl
    @length = d

    if @length > 192
      debug { "Length is too large (#{@length})." }
      return
    end

    @data = b(@length)
  end

  private def run_impl
    return unless pc = active_char

    if @length < 0
      pc.send_packet(SystemMessageId::WRONG_SIZE_UPLOADED_CREST)
      return
    end

    if @length > 192
      pc.send_packet(SystemMessageId::ADJUST_IMAGE_8_12)
      return
    end

    if pc.ally_id == 0
      pc.send_packet(SystemMessageId::FEATURE_ONLY_FOR_ALLIANCE_LEADER)
      return
    end

    leader_clan = ClanTable.get_clan(pc.ally_id).not_nil!

    if pc.clan_id != leader_clan.id || !pc.clan_leader?
      pc.send_packet(SystemMessageId::FEATURE_ONLY_FOR_ALLIANCE_LEADER)
      return
    end

    if @length == 0
      if leader_clan.ally_crest_id != 0
        leader_clan.change_ally_crest(0, false)
        pc.send_packet(SystemMessageId::CLAN_CREST_HAS_BEEN_DELETED)
      end
    else
      if crest = CrestTable.create_crest(@data, L2Crest::ALLY)
        leader_clan.change_ally_crest(crest.id, false)
        pc.send_packet(SystemMessageId::CLAN_CREST_WAS_SUCCESSFULLY_REGISTRED)
      end
    end
  end
end
