require "./condition_listener"

abstract class Condition
  include ConditionListener
  include Loggable

  private alias SystemMessage = Packets::Outgoing::SystemMessage

  property message : String?
  property message_id = 0

  getter? add_name = false

  @result = false

  getter listener : ConditionListener?

  def add_name
    @add_name = true
  end

  def listener=(@listener : ConditionListener?)
    notify_changed
  end

  def test(caster : L2Character, target : L2Character?, skill : Skill?) : Bool
    test(caster, target, skill, nil)
  end

  def test(caster : L2Character, target : L2Character?, item : L2Item?) : Bool
    test(caster, target, nil, nil)
  end

  def test(caster : L2Character, target : L2Character?, skill : Skill?, item : L2Item?) : Bool
    res = test_impl(caster, target, skill, item)

    if @listener && res != @result
      @result = res
      notify_changed
    end

    res
  end

  abstract def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool

  def notify_changed
    @listener.try &.notify_changed
  end
end

require "./conditions/*"
