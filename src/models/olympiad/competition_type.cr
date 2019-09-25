enum CompetitionType : UInt8
  CLASSED, NON_CLASSED, TEAMS, OTHER

  def to_s : String
    case self
    when CLASSED
      "classed"
    when NON_CLASSED
      "non-classed"
    when TEAMS
      "teams"
    else
      "other"
    end
  end
end
