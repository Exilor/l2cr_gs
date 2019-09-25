struct ArrivedTask
  initializer npc : L2Npc, walk : WalkInfo

  def call
    @walk.blocked = false
    WalkingManager.start_moving(@npc, @walk.route.name)
  end
end
