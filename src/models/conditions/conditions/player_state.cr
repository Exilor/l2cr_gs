class Condition
  class PlayerState < Condition
    initializer state : ::PlayerState, required : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      char = effector
      pc = effector.acting_player

      case @state
      when .resting?
        return pc.sitting? == @required if pc
        return !@required
      when .moving?
        return char.moving? == @required
      when .running?
        return char.running? == @required
      when .standing?
        if pc
          return @required != (pc.sitting? || pc.moving?)
        end
        return @required != char.moving?
      when .flying?
        return char.flying? == @required
      when .behind?
        return char.behind_target? == @required
      when .front?
        return char.in_front_of_target? == @required
      when .chaotic?
        if pc
          return (pc.karma > 0) == @required
        end
        return !@required
      when .olympiad?
        if pc
          return pc.in_olympiad_mode? == @required
        end
        return !@required
      end

      !@required
    end
  end
end
