module HitConditionBonusData
  extend self
  extend XMLReader

  @@FRONT_BONUS = 0
  @@SIDE_BONUS  = 0
  @@BACK_BONUS  = 0
  @@HIGH_BONUS  = 0
  @@LOW_BONUS   = 0
  @@DARK_BONUS  = 0
  @@RAIN_BONUS  = 0

  def load
    parse_datapack_file("stats/hitConditionBonus.xml")
    info "Loaded hit condition bonuses."
  end

  private def parse_document(doc, file)
    doc.each_element do |d|
      d.each_element do |d|
        case d.name.casecmp
        when "front"
          @@FRONT_BONUS = d["val"].to_i
        when "side"
          @@SIDE_BONUS  = d["val"].to_i
        when "back"
          @@BACK_BONUS  = d["val"].to_i
        when "high"
          @@HIGH_BONUS  = d["val"].to_i
        when "low"
          @@LOW_BONUS   = d["val"].to_i
        when "dark"
          @@DARK_BONUS  = d["val"].to_i
        when "rain"
          @@RAIN_BONUS  = d["val"].to_i
        end
      end
    end
  end

  def get_condition_bonus(attacker : L2Character, target : L2Character) : Float64
    mod = 100.0

    if attacker.z - target.z > 50
      mod += @@HIGH_BONUS
    elsif attacker.z - target.z < -50
      mod += @@LOW_BONUS
    end

    if GameTimer.night?
      mod += @@DARK_BONUS
    end

    # not done by L2J: rain bonus

    if attacker.behind_target?
      mod += @@BACK_BONUS
    elsif attacker.in_front_of_target?
      mod += @@FRONT_BONUS
    else
      mod += @@SIDE_BONUS
    end

    Math.max(mod / 100, 0.0)
  end
end
