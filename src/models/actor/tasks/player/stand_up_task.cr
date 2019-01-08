struct StandUpTask
  include Runnable

  initializer pc: L2PcInstance

  def run
    @pc.sitting = false
    @pc.intention = AI::IDLE
  end
end
