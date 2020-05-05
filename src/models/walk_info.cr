require "../models/actor/tasks/npc/start_moving_task"
require "../models/actor/tasks/npc/arrived_task"

class WalkInfo
  include Synchronizable

  @forward = true

  getter current_node_id = 0
  property last_action : Int64 = 0i64
  property walk_check_task : TaskExecutor::Scheduler::PeriodicTask?
  property? blocked : Bool = false
  property? suspended : Bool = false
  property? stopped_by_attack : Bool = false

  initializer route_name : String

  def route : L2WalkRoute
    unless route = WalkingManager.get_route(@route_name)
      raise "Route '#{@route_name}' not found"
    end

    route
  end

  def current_node : L2NpcWalkerNode
    route.node_list[@current_node_id]
  end

  def calculate_next_node(npc : L2Npc)
    sync do
      route = route()
      if route.repeat_type == WalkingManager::REPEAT_RANDOM
        new_node = @current_node_id
        while new_node == @current_node_id
          new_node = Rnd.rand(route.nodes_count)
        end
        @current_node_id = new_node
      else
        if @forward
          @current_node_id += 1
        else
          @current_node_id -= 1
        end

        if @current_node_id == route.nodes_count
          OnNpcMoveRouteFinished.new(npc).async(npc)

          unless route.repeat_walk?
            WalkingManager.cancel_moving(npc)
            return
          end

          case route.repeat_type
          when WalkingManager::REPEAT_GO_BACK
            @forward = false
            @current_node_id -= 2
          when WalkingManager::REPEAT_GO_FIRST
            @current_node_id = 0
          when WalkingManager::REPEAT_TELE_FIRST
            npc.tele_to_location(npc.spawn.location)
            @current_node_id = 0
          else
            # [automatically added else]
          end

        elsif @current_node_id == WalkingManager::NO_REPEAT
          @current_node_id = 1
          @forward = true
        end
      end
    end
  end
end
