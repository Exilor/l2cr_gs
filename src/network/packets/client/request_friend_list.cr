class Packets::Incoming::RequestFriendList < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char

    pc.send_packet(SystemMessageId::FRIEND_LIST_HEADER)

    if pc.has_friends?
      pc.friends.each do |id|
        unless name = CharNameTable.get_name_by_id(id)
          next
        end
        friend = L2World.get_player(name)
        if friend && friend.online?
          sm = SystemMessage.s1_online
        else
          sm = SystemMessage.s1_offline
        end
        sm.add_string(name)
        pc.send_packet(sm)
      end
    end

    pc.send_packet(SystemMessageId::FRIEND_LIST_FOOTER)
  end
end
