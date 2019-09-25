class Condition
  class PlayerBaseStats < Condition
    enum BaseStat : UInt8
      Int, Str, Con, Dex, Men, Wit
    end

    initializer stat : BaseStat, value : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player?

      return pc.str >= @value if @stat.str?
      return pc.dex >= @value if @stat.dex?
      return pc.con >= @value if @stat.con?
      return pc.int >= @value if @stat.int?
      return pc.wit >= @value if @stat.wit?
      return pc.men >= @value if @stat.men?

      false
    end
  end
end
