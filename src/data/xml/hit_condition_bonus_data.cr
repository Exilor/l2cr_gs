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
  end

  private def parse_document(doc, file)
    each_element(doc) do |n|
      each_element(n) do |d, d_name|
        case d_name.casecmp
        when "front"
          @@front_bonus = parse_int(d, "val")
        when "side"
          @@side_bonus  = parse_int(d, "val")
        when "back"
          @@back_bonus  = parse_int(d, "val")
        when "high"
          @@high_bonus  = parse_int(d, "val")
        when "low"
          @@low_bonus   = parse_int(d, "val")
        when "dark"
          @@dark_bonus  = parse_int(d, "val")
        when "rain"
          @@rain_bonus  = parse_int(d, "val")
        else
          # [automatically added else]
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
