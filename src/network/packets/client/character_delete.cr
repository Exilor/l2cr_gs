class Packets::Incoming::CharacterDelete < GameClientPacket
  @slot = -1

  private def read_impl
    @slot = d
  end

  private def run_impl
    flood_protection = flood_protectors.character_select
    unless flood_protection.try_perform_action("CharacterDelete")
      send_packet(CharDeleteFail::DELETION_FAILED)
      return
    end

    case client.mark_to_delete_char(@slot)
    when -1 # error
      # do nothing
    when 0 # success
      send_packet(CharDeleteSuccess::STATIC_PACKET)
      cip = client.get_char_selection(@slot).not_nil!
      evt = OnPlayerDelete.new(cip.l2id, cip.name, client)
      evt.notify(Containers::PLAYERS)
    when 1
      send_packet(CharDeleteFail::YOU_MAY_NOT_DELETE_CLAN_MEMBER)
    when 2
      send_packet(CharDeleteFail::CLAN_LEADERS_MAY_NOT_BE_DELETED)
    end


    csi = CharSelectionInfo.new(client.account_name, client.session_id.play_ok_1, 0)
    send_packet(csi)
    client.char_selection = csi.char_info
  end
end
