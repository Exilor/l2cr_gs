require "../models/l2_walk_route"
require "../models/walk_info"
require "../models/holders/npc_routes_holder"
require "./tasks/start_moving_task"

module WalkingManager
  extend self
  extend XMLReader
  extend Synchronizable

  NO_REPEAT = -1
  REPEAT_GO_BACK = 0
  REPEAT_GO_FIRST = 1
  REPEAT_TELE_FIRST = 2
  REPEAT_RANDOM = 3

  private ROUTES = {} of String => L2WalkRoute
  private ACTIVE_ROUTES = {} of Int32 => WalkInfo
  private ROUTES_TO_ATTACH = {} of Int32 => NpcRoutesHolder

  private NPC_ALL = Packets::Incoming::Say2::NPC_ALL
  private alias NpcSay = Packets::Outgoing::NpcSay

  def load
    parse_datapack_file("Routes.xml")
    info { "Loaded #{ROUTES.size} walking NPC routes." }
  end

  def on_walk?(npc : L2Npc)
    if npc.monster?
      monster = npc.leader? || npc
    end

    if (monster && !registered?(monster)) || !registered?(npc)
      return false
    end

    walk = ACTIVE_ROUTES[monster.try &.l2id || npc.l2id]
    !(walk.stopped_by_attack? || walk.suspended?)
  end

  def get_route(route)
    ROUTES[route]?
  end

  def registered?(npc)
    ACTIVE_ROUTES.has_key?(npc.l2id)
  end

  def get_route_name(npc)
    ACTIVE_ROUTES[npc.l2id]?.try &.route.name || ""
  end

  def start_moving(npc, route_name)
    unless ROUTES.has_key?(route_name)
    end

    return unless npc && npc.alive? && ROUTES.has_key?(route_name)

    if !ACTIVE_ROUTES.has_key?(npc.l2id)
      if npc.intention.active? || npc.intention.idle?
        walk = WalkInfo.new(route_name)
        # if npc.debug?
        #   npc.last_action = Time.ms
        # end
        node = walk.current_node
        if npc.x == node.x && npc.y == node.y
          walk.calculate_next_node(npc)
          node = walk.current_node
          # debug msg
        end
        unless npc.inside_radius?(node, 3000, true, false)
          # debug msg
          return
        end
        npc.running = node.run_to_location?
        npc.set_intention(AI::MOVE_TO, node)
        task = StartMovingTask.new(npc, route_name)
        task = ThreadPoolManager.schedule_ai_at_fixed_rate(task, 60000, 60000)
        walk.walk_check_task = task
        npc.known_list.start_tracking_task
        ACTIVE_ROUTES[npc.l2id] = walk
      else
        task = StartMovingTask.new(npc, route_name)
        ThreadPoolManager.schedule_general(task, 60000)
      end
    else # walk was stopped for some reason
      if ACTIVE_ROUTES.has_key?(npc.l2id) && (npc.intention.active? || npc.intention.idle?)
        return unless walk = ACTIVE_ROUTES[npc.l2id]?
        if walk.blocked? || walk.suspended?
          return
        end

        walk.blocked = true
        node = walk.current_node
        npc.running = node.run_to_location?
        npc.set_intention(AI::MOVE_TO, node)
        walk.blocked = false
        walk.stopped_by_attack = false
      end
    end
  end

  def cancel_moving(npc)
    sync do
      if walk = ACTIVE_ROUTES[npc.l2id]?
        walk.suspended = false
        walk.stopped_by_attack = false
        start_moving(npc, walk.route.name)
      else
      end
    end
  end

  def stop_moving(npc, suspend, stopped_by_attack)
    if npc.monster?
      monster = npc.leader? || npc
    end

    if (monster && !registered?(monster)) || !registered?(npc)
      return
    end

    walk = ACTIVE_ROUTES[monster.try &.l2id || npc.l2id]
    walk.suspended = suspend
    walk.stopped_by_attack = stopped_by_attack

    if monster
      monster.stop_move(nil)
      monster.intention = AI::ACTIVE
    else
      npc.stop_move(nil)
      npc.intention = AI::ACTIVE
    end
  end

  def on_arrived(npc)
    return unless walk = ACTIVE_ROUTES[npc.l2id]?

    OnNpcMoveNodeArrived.new(npc).async(npc)

    if walk.current_node_id >= 0 && walk.current_node_id < walk.route.nodes_count
      node = walk.route.node_list[walk.current_node_id]
      if npc.inside_radius?(node, 10, false, false)
        walk.calculate_next_node(npc)
        walk.blocked = true

        if say = node.npc_string
          Broadcast.to_known_players(npc, NpcSay.new(npc, NPC_ALL, say))
        elsif !node.chat_text.empty?
          say = node.chat_text
          Broadcast.to_known_players(npc, NpcSay.new(npc, NPC_ALL, say))
        end

        # if npc.debug?
        #   walk.last_action = Time.ms
        # end

        task = ArrivedTask.new(npc, walk)
        ThreadPoolManager.schedule_general(task, 100 + (node.delay * 1000))
      end
    end
  end

  def on_death(npc)
    cancel_moving(npc)
  end

  def on_spawn(npc)
    if route_name = ROUTES_TO_ATTACH[npc.id]?.try &.get_route_name(npc)
      unless route_name.empty?
        start_moving(npc, route_name)
      end
    end
  end

  private def parse_document(doc, file)
    each_element(doc) do |n|
      find_element(n, "route") do |d|
        route_name = parse_string(d, "name")
        repeat = parse_bool(d, "repeat")
        repeat_style = parse_string(d, "repeatStyle")
        repeat_type =
        case repeat_style.casecmp
        when "back"
          REPEAT_GO_BACK
        when "cycle"
          REPEAT_GO_FIRST
        when "conveyor"
          REPEAT_TELE_FIRST
        when "random"
          REPEAT_RANDOM
        else
          NO_REPEAT
        end

        list = [] of L2NpcWalkerNode
        each_element(d) do |r, r_name|
          if r_name == "point"
            x = parse_int(r, "X")
            y = parse_int(r, "Y")
            z = parse_int(r, "Z")
            delay = parse_int(r, "delay")
            run = parse_bool(r, "run")
            if node = parse_string(r, "string", nil)
              chat_string = node
            else
              if node = parse_string(r, "npcString", nil)
                unless npc_string = NpcString.parse?(node)
                  warn { "Unknown NpcString #{node} for route #{route_name}." }
                  next
                end
              else
                if node = parse_string(r, "npcStringId", nil)
                  unless npc_string = NpcString.get?(node.to_i)
                    warn { "Unknown NpcString #{node} for route #{route_name}." }
                    next
                  end
                end
              end
            end
            list << L2NpcWalkerNode.new(x, y, z, delay, run, npc_string, chat_string)
          elsif r_name == "target"
            npc_id = parse_int(r, "id")
            x = parse_int(r, "spawnX")
            y = parse_int(r, "spawnY")
            z = parse_int(r, "spawnZ")
            holder = ROUTES_TO_ATTACH[npc_id] ||= NpcRoutesHolder.new
            holder.add_route(route_name, Location.new(x, y, z))
          end
        end

        ROUTES[route_name] = L2WalkRoute.new(route_name, list, repeat, repeat_type.to_i8)
      end
    end
  end
end
