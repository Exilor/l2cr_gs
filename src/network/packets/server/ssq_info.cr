class Packets::Outgoing::SSQInfo < GameServerPacket
  @state = 0

  initializer state : Int32

  def initialize
    if SevenSigns.seal_validation_period?
      winner = SevenSigns.cabal_highest_score

      if winner == SevenSigns::CABAL_DAWN
        @state = 2
      elsif winner == SevenSigns::CABAL_DUSK
        @state = 1
      end
    end
  end

  def write_impl
    c 0x73
    h 256 + @state
  end
end
