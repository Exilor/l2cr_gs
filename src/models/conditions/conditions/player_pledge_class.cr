class Condition
  class PlayerPledgeClass < Condition
    initializer pledge_class: Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player?
      return false unless pc.clan?
      @pledge_class == -1 ? pc.clan_leader? : pc.pledge_class >= @pledge_class
    end
  end
end
