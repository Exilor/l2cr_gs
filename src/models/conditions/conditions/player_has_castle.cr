class Condition
  class PlayerHasCastle < Condition
    initializer castle : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player
      return false unless clan = pc.clan
      @castle == -1 ? clan.castle_id > 0 : clan.castle_id == @castle
    end
  end
end
