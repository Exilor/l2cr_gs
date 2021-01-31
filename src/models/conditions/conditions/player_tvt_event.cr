class Condition
  class PlayerTvTEvent < self
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return !@val unless pc = effector.acting_player
      return !@val if TvTEvent.started?
      TvTEvent.participant?(pc.l2id) == @val
    end
  end
end
