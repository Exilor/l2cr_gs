struct QueuedMagicUseTask
  initializer pc : L2PcInstance, sk : Skill, ctrl : Bool, shift : Bool

  def call
    @pc.use_magic(@sk, @ctrl, @shift)
  end
end
