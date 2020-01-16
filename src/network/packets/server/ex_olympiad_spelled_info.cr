class Packets::Outgoing::ExOlympiadSpelledInfo < GameServerPacket
  @player_id : Int32
  @effects = [] of BuffInfo

  def initialize(pc : L2PcInstance)
    @player_id = pc.l2id
  end

  def add_skill(info : BuffInfo)
    @effects << info
  end

  private def write_impl
    c 0xfe
    h 0x7b

    d @player_id
    d @effects.size
    @effects.each do |info|
      if info.in_use?
        d info.skill.display_id
        h info.skill.display_level
        d info.time
      end
    end
  end
end
