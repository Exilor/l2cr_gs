class Condition
  class PlayerHasClanHall < Condition
    initializer halls : Array(Int32)

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      unless pc = effector.acting_player?
        return false
      end

      unless clan = pc.clan?
        return @halls.size == 1 && @halls[0] == -1
      end

      if @halls.size == 1 && @halls[0] == -1
        return clan.hideout_id > 0
      end

      @halls.includes?(clan.hideout_id)
    end
  end
end
