module HitConditionBonusData
  extend self
  extend XMLReader

  @@front_bonus = 0
  @@side_bonus  = 0
  @@back_bonus  = 0
  @@high_bonus  = 0
  @@low_bonus   = 0
  @@dark_bonus  = 0
  @@rain_bonus  = 0

  def load
    parse_datapack_file("stats/hitConditionBonus.xml")
    info "Loaded hit condition bonuses."
  end

  private def parse_document(doc, file)
    doc.each_element do |d|
      d.each_element do |d|
        case d.name.casecmp
        when "front"
          @@front_bonus = d["val"].to_i
        when "side"
          @@side_bonus  = d["val"].to_i
        when "back"
          @@back_bonus  = d["val"].to_i
        when "high"
          @@high_bonus  = d["val"].to_i
        when "low"
          @@low_bonus   = d["val"].to_i
        when "dark"
          @@dark_bonus  = d["val"].to_i
        when "rain"
          @@rain_bonus  = d["val"].to_i
        else
          # automatically added
        end

      end
    end
  end

  def get_condition_bonus(attacker : L2Character, target : L2Character) : Float64
    mod = 100.0

    if attacker.z - target.z > 50
      mod += @@high_bonus
    elsif attacker.z - target.z < -50
      mod += @@low_bonus
    end

    if GameTimer.night?
      mod += @@dark_bonus
    end

    # not done by L2J: rain bonus

    if attacker.behind_target?
      mod += @@back_bonus
    elsif attacker.in_front_of_target?
      mod += @@front_bonus
    else
      mod += @@side_bonus
    end

    Math.max(mod / 100, 0.0)
  end
end