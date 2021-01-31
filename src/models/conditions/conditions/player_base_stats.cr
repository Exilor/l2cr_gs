class Condition
  class PlayerBaseStats < self
    enum BaseStat : UInt8
      Int
      Str
      Con
      Dex
      Men
      Wit
    end

    initializer stat : BaseStat, value : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player

      case
      when @stat.str?
        return pc.str >= @value
      when @stat.dex?
        return pc.dex >= @value
      when @stat.con?
        return pc.con >= @value
      when @stat.int?
        return pc.int >= @value
      when @stat.wit?
        return pc.wit >= @value
      when @stat.men?
        return pc.men >= @value
      end

      false
    end
  end
end
