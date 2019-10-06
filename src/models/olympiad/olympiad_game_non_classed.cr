require "./olympiad_game_normal"

class OlympiadGameNonClassed < OlympiadGameNormal
  def type : CompetitionType
    CompetitionType::NON_CLASSED
  end

  private def divider : Int32
    Config.alt_oly_divider_non_classed
  end

  private def reward : Slice(Slice(Int32))
    Config.alt_oly_nonclassed_reward
  end

  private def weekly_match_type : String
    COMP_DONE_WEEK_NON_CLASSED
  end

  def self.create_game(id : Int32, class_list : IArray(Int32)) : self?
    if opponents = OlympiadGameNormal.create_list_of_participants(class_list)
      new(id, opponents)
    end
  end
end
