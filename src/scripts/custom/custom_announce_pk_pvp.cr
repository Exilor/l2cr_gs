class Scripts::CustomAnnouncePkPvP
  include Loggable
  include AbstractEventListener::Owner

  def initialize
    if Config.announce_pk_pvp
      evt_type = EventType::ON_PLAYER_PVP_KILL
      cel = ConsumerEventListener.new(Containers::PLAYERS, evt_type, self) do |event|
        on_player_pvp_kill(event.as(OnPlayerPvPKill))
      end
      Containers::PLAYERS.add_listener(cel)
    end
  end

  private def on_player_pvp_kill(event : OnPlayerPvPKill)
    pk = event.active_char
    if pk.gm?
      debug { "#{pk.name} is a gm." }
      return
    end

    pc = event.target
    msg = Config.announce_pvp_msg

    if pc.pvp_flag == 0
      msg = Config.announce_pk_msg
    end

    msg = msg.sub("$killer", pk.name).sub("$target", pc.name)

    if Config.announce_pk_pvp_normal_message
      sm = Packets::Outgoing::SystemMessage.from_string(msg)
      Broadcast.to_all_online_players(sm)
    else
      Broadcast.to_all_online_players(msg, false)
    end

    nil
  end
end
