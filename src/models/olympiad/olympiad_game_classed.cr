require "./olympiad_game_normal"

class OlympiadGameClassed < OlympiadGameNormal
  def type : CompetitionType
    CompetitionType::CLASSED
  end

  private def divider : Int32
    Config.alt_oly_divider_classed
  end

  private def reward : Slice(Slice(Int32))
    Config.alt_oly_classed_reward
  end

  private def weekly_match_type : String
    COMP_DONE_WEEK_CLASSED
  end

  def self.create_game(id : Int32, class_list : Interfaces::Array(Interfaces::Array(Int32))) : self?
    until class_list.empty?
      list = class_list.sample(random: Rnd)
      if list.size < 2
        class_list.delete_first(list)
        next
      end

      unless opponents = OlympiadGameNormal.create_list_of_participants(list)
        class_list.delete_first(list)
        next
      end

      return new(id, opponents)
    end
  end
end
