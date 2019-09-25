class Packets::Outgoing::ExEnchantSkillResult < GameServerPacket
  private initializer success : Bool

  def write_impl
    c 0xfe
    h 0xa7

    d @success ? 1 : 0
  end

  TRUE  = new(true)
  FALSE = new(false)
end
