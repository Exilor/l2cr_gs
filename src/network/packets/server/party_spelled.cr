class Packets::Outgoing::PartySpelled < GameServerPacket
  @effects = [] of BuffInfo

  initializer char: L2Character

  def add_skill(info : BuffInfo)
    @effects << info
  end

  def write_impl
    c 0xf4

    d @char.servitor? ? 2 : @char.pet? ? 1 : 0
    d @char.l2id
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
