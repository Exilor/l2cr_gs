struct StartMovingTask
  initializer npc: L2Npc, route_name: String

  def call
    if npc = @npc
      WalkingManager.start_moving(npc, @route_name)
    end
  end
end
