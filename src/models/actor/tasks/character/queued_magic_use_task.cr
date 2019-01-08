struct QueuedMagicUseTask
  include Runnable

  initializer pc: L2PcInstance, sk: Skill, ctrl: Bool, shift: Bool

  def run
    @pc.use_magic(@sk, @ctrl, @shift)
  end
end
