abstract class Condition
  include Packets::Outgoing

  private module Listener
    abstract def notify_changed
  end

  include Listener

  private alias SystemMessage = Packets::Outgoing::SystemMessage

  @result = false

  getter listener : Listener?
  getter? add_name = false
  property message : String?
  property message_id : Int32 = 0

  def add_name
    @add_name = true
  end

  def listener=(listener : Listener?)
    @listener = listener
    notify_changed
  end

  def test(caster : L2Character, target : L2Character?, skill : Skill?, item : L2Item? = nil) : Bool
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
