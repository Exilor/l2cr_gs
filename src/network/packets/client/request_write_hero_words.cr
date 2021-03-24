class Packets::Incoming::RequestWriteHeroWords < GameClientPacket
  @msg = ""

  private def read_impl
    @msg = s
  end

  private def run_impl
    return unless pc = active_char

    unless pc.hero?
      return
    end

    if @msg.size > 300
      return
    end

    Hero.set_hero_message(pc, @msg)
  end
end
