struct ArrivedTask
  include Runnable
  include Loggable

  initializer npc: L2Npc, walk: WalkInfo

  def run
    @walk.blocked = false
    WalkingManager.start_moving(@npc, @walk.route.name)
  end
end
