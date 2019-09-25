class Condition
  class PlayerHasFort < Condition
    initializer fort : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      unless pc = effector.acting_player?
        return false
      end

      unless clan = pc.clan?
        return @fort == 0
      end

      if @fort == -1
        return clan.fort_id > 0
      end

      clan.fort_id == @fort
    end
  end
end
