class Packets::Incoming::CharacterRestore < GameClientPacket
  @slot = 0

  def read_impl
    @slot = d
  end

  def run_impl
    unless flood_protectors.character_select.try_perform_action("CharacterRestore")
      debug "Flood detected."
      return
    end

    client.mark_restored_char(@slot)
    csi = CharSelectionInfo.new(client.account_name, client.session_id.play_ok_1, 0)
    send_packet(csi)
    client.char_selection = csi.char_info
    unless cip = client.get_char_selection(@slot)
      error "Got a nil from GameClient.get_char_selection."
      return
    end
    ops = OnPlayerRestore.new(cip.l2id, cip.name, client)
    EventDispatcher.notify(ops)
  end
end
