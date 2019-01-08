struct StartMovingTask
  include Runnable
  include Loggable

  initializer npc: L2Npc, route_name: String

  def run
    WalkingManager.start_moving(@npc, @route_name)
  end
end
