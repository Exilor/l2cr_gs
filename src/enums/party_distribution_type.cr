enum PartyDistributionType : UInt8
  FINDERS_KEEPERS
  RANDOM
  RANDOM_INCLUDING_SPOIL
  BY_TURN
  BY_TURN_INCLUDING_SPOIL

  def sys_string_id : Int32
    case self
    when FINDERS_KEEPERS
      487
    when RANDOM
      488
    when RANDOM_INCLUDING_SPOIL
      798
    when BY_TURN
      799
    else
      800
    end
  end
end
