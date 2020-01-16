class Packets::Outgoing::ExStartScenePlayer < GameServerPacket
  initializer movie_id : Int32

  private def write_impl
    c 0xfe
    h 0x99

    d @movie_id
  end
end
