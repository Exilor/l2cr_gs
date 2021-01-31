require "../../entity/tvt_event"

class Condition
  class PlayerCanEscape < self
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      can = true

      pc = effector.acting_player

      case
      when pc.nil?
        can = false
      when !TvTEvent.on_escape_use(pc.l2id)
        can = false
      when pc.in_duel?
        can = false
      when pc.afraid?
        can = false
      when pc.combat_flag_equipped?
        can = false
      when pc.flying? || pc.flying_mounted?
        can = false
      when pc.in_olympiad_mode?
        can = false
      when GrandBossManager.get_zone(pc) && !pc.override_skill_conditions?
        can = false
      end

      @val == can
    end
  end
end
