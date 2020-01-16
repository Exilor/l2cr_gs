class Packets::Outgoing::TutorialShowQuestionMark < GameServerPacket
  initializer mark : Int32

  private def write_impl
    c 0xa7
    d @mark
  end
end
