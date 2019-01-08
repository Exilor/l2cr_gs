struct StartMovingTask
  include Runnable

  initializer npc: L2Npc, route_name: String

  def run
    if npc = @npc
      WalkingManager.start_moving(npc, @route_name)
    end
  end
end
