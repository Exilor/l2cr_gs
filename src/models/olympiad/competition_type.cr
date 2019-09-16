# class CompetitionType < EnumClass
#   protected initializer name: String

#   add(CLASSED, "classed")
#   add(NON_CLASSED, "non-classed")
#   add(TEAMS, "teams")
#   add(OTHER, "other")

#   def to_s : String
#     @name
#   end
# end

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
