struct StartMovingTask
  initializer npc: L2Npc, route_name: String

  def call
    WalkingManager.start_moving(@npc, @route_name)
  end
end
