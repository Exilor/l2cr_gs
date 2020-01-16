class Packets::Outgoing::SocialAction < GameServerPacket
  LEVEL_UP = 2122

  initializer l2id : Int32, action_id : Int32

  private def write_impl
    c 0x27

    d @l2id
    d @action_id
  end

  def self.level_up(l2id : Int32) : self
    new(l2id, 2122)
  end
end
