class Condition
  class PlayerInsideZoneId < Condition
    initializer zones : Array(Int32)

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless effector.acting_player?

      ZoneManager.get_zones(effector) do |zone|
        if @zones.includes?(zone.id)
          return true
        end
      end

      false
    end
  end
end
