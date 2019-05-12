class CompetitionType < EnumClass
  protected initializer name: String

  def to_s : String
    @name
  end

  add(CLASSED, "classed")
  add(NON_CLASSED, "non-classed")
  add(TEAMS, "teams")
  add(OTHER, "other")
end
