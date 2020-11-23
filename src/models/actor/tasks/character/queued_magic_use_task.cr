struct QueuedMagicUseTask
  initializer pc : L2PcInstance, skill : Skill, ctrl : Bool, shift : Bool

  def call
    @pc.use_magic(@skill, @ctrl, @shift)
  end
end
