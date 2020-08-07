class Packets::Outgoing::SSQInfo < GameServerPacket
  @state = 0

  initializer state : Int32

  def initialize
    if SevenSigns.instance.seal_validation_period?
      winner = SevenSigns.instance.cabal_highest_score

      if winner == SevenSigns::CABAL_DAWN
        @state = 2
      elsif winner == SevenSigns::CABAL_DUSK
        @state = 1
      end
    end
  end

  private def write_impl
    c 0x73
    h 256 &+ @state
  end

  private NULL = new(SevenSigns::CABAL_NULL)
  private DUSK = new(SevenSigns::CABAL_DUSK)
  private DAWN = new(SevenSigns::CABAL_DAWN)

  def self.new(state = nil)
    case state
    when SevenSigns::CABAL_DAWN
      DAWN
    when SevenSigns::CABAL_DUSK
      DUSK
    when SevenSigns::CABAL_NULL
      NULL
    else
      if SevenSigns.instance.seal_validation_period?
        case SevenSigns.instance.cabal_highest_score
        when SevenSigns::CABAL_DAWN
          DAWN
        when SevenSigns::CABAL_DUSK
          DUSK
        else
          NULL
        end
      else
        NULL
      end
    end
  end
end
