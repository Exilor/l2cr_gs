abstract class Condition
  include Packets::Outgoing

  private alias SystemMessage = Packets::Outgoing::SystemMessage

  property message : String?
  property message_id : Int32 = 0
  property? add_name : Bool = false

  def test(caster : L2Character, target : L2Character?, skill : Skill?, item : L2Item? = nil) : Bool
    test_impl(caster, target, skill, item)
  end

  abstract def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
end

require "./conditions/*"
