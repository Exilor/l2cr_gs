require "../models/dimensional_rift_room"

module DimensionalRiftManager
  extend self
  extend XMLReader
  extend Synchronizable

  private alias NpcHtmlMessage = Packets::Outgoing::NpcHtmlMessage
  private DIMENSIONAL_FRAGMENT_ITEM_ID = 7079

  private ROOMS = Hash(Int8, Hash(Int8, DimensionalRiftRoom)).new(initial_capacity: 7)

  def load
    load_rooms
    load_spawns
  end

  def get_room(type : Int8, room : Int8) : DimensionalRiftRoom
    ROOMS.dig?(type, room) ||
    raise("Room with type #{type} and room #{room} not found")
  end

  private def load_rooms
    GameDB.each("SELECT * FROM dimensional_rift") do |rs|
      type = rs.get_i8(:"type")
      room_id = rs.get_i8(:"room_id")

      x_min = rs.get_i32(:"xMin")
      x_max = rs.get_i32(:"xMax")
      y_min = rs.get_i32(:"yMin")
      y_max = rs.get_i32(:"yMax")
      z1 = rs.get_i32(:"zMin")
      z2 = rs.get_i32(:"zMax")
      xt = rs.get_i32(:"xT")
      yt = rs.get_i32(:"yT")
      zt = rs.get_i32(:"zT")
      boss_room = rs.get_i8(:"boss") > 0

      ROOMS[type] ||= Hash(Int8, DimensionalRiftRoom).new(initial_capacity: 9)

      room = DimensionalRiftRoom.new(
        type, room_id, x_min, x_max, y_min, y_max, z1, z2, xt, yt, zt, boss_room
      )
      ROOMS[type][room_id] = room
    end

    type_size = ROOMS.size
    room_size = ROOMS.each_key.reduce(0) { |m, k| m + ROOMS[k].size }

    info { "Loaded #{type_size} room types with #{room_size} rooms." }
  rescue e
    error e
  end

  def load_spawns
    parse_datapack_file("dimensionalRift.xml")
  end

  private def parse_document(doc, file)
    count_good = count_bad = 0

    find_element(doc, "rift") do |rift|
      find_element(rift, "area") do |area|
        # 0 waiting room, 1 recruit, 2 soldier, 3 officer, 4 captain, 5 commander, 6 hero
        type = parse_byte(area, "type")

        find_element(area, "room") do |room|
          room_id = parse_byte(room, "id")

          find_element(room, "spawn") do |sp|
            mob_id = parse_int(sp, "mobId")
            delay = parse_int(sp, "delay")
            count = parse_int(sp, "count")

            count.times do |i|
              unless rift_room = ROOMS.dig?(type, room_id)
                count_bad += 1
                next
              end
              x = rift_room.random_x
              y = rift_room.random_y
              z = rift_room.teleport_coordinates.z

              sp = L2Spawn.new(mob_id)
              sp.amount = 1
              sp.x = x
              sp.y = y
              sp.z = z
              sp.heading = -1
              sp.respawn_delay = delay
              SpawnTable.add_new_spawn(sp, false)
              rift_room.spawns << sp
              count_good += 1
            end
          end
        end
      end
    end

    info { "Loaded #{count_good} dimensional rift spawns (#{count_bad} errors)." }
  rescue e
    error e
  end

  def reload
    ROOMS.each_value &.each_value &.spawns.clear
    ROOMS.clear
    load
  end

  def in_rift_zone?(x : Int32, y : Int32, z : Int32, ignore_peace_zone : Bool) : Bool
    if ignore_peace_zone
      return ROOMS[0][1].in_zone?(x, y, z)
    end

    ROOMS[0][1].in_zone?(x, y, z) && !ROOMS[0][0].in_zone?(x, y, z)
  end

  def in_peace_zone?(x : Int32, y : Int32, z : Int32) : Bool
    ROOMS[0][0].in_zone?(x, y, z)
  end

  def teleport_to_waiting_room(pc : L2PcInstance)
    room = get_room(0, 0)
    pc.tele_to_location(room.teleport_coordinates)
  end

  def start(pc : L2PcInstance, type : Int8, npc : L2Npc) : Nil
    sync do
      unless party = pc.party
        show_html_file(pc, "data/html/seven_signs/rift/NoParty.htm", npc)
        return
      end

      if party.leader_l2id != pc.l2id
        show_html_file(pc, "data/html/seven_signs/rift/NotPartyLeader.htm", npc)
        return
      end

      if party.in_dimensional_rift?
        handle_cheat(pc, npc)
        return
      end

      if party.size < Config.rift_min_party_size
        html = NpcHtmlMessage.new(npc.l2id)
        html.set_file(pc, "data/html/seven_signs/rift/SmallParty.htm")
        html["%npc_name%"] = npc.name
        html["%count%"] = Config.rift_min_party_size.to_s
        pc.send_packet(html)
        return
      end

      unless allowed_enter?(type)
        pc.send_message("Rift is full. Try later.")
        return
      end

      can_pass = party.members.all? { |m| in_peace_zone?(*m.xyz) }

      unless can_pass
        show_html_file(pc, "data/html/seven_signs/rift/NotInWaitingRoom.htm", npc)
        return
      end

      count = get_needed_items(type).to_i64

      party.members.each do |m|
        item = m.inventory.get_item_by_item_id(DIMENSIONAL_FRAGMENT_ITEM_ID)
        unless item
          can_pass = false
          break
        end

        if item.count > 0
          if item.count < count
            can_pass = false
            break
          end
        else
          can_pass = false
          break
        end
      end

      can_pass = true if pc.gm? # custom

      unless can_pass
        html = NpcHtmlMessage.new(npc.l2id)
        html.set_file(pc, "data/html/seven_signs/rift/NoFragments.htm")
        html["%npc_name%"] = npc.name
        html["%count%"] = Config.rift_min_party_size.to_s
        pc.send_packet(html)
        return
      end

      party.members.each do |m|
        next if pc.gm? # custom
        i = m.inventory.get_item_by_item_id(DIMENSIONAL_FRAGMENT_ITEM_ID)
        unless m.destroy_item("RiftEntrance", i.not_nil!, count, nil, false)
          html = NpcHtmlMessage.new(npc.l2id)
          html.set_file(pc, "data/html/seven_signs/rift/NoFragments.htm")
          html["%npc_name%"] = npc.name
          html["%count%"] = Config.rift_min_party_size.to_s
          pc.send_packet(html)
          return
        end
      end

      empty_rooms = get_free_rooms(type)
      room = empty_rooms.sample(random: Rnd)

      DimensionalRift.new(party, type, room)
    end
  end

  def kill_rift(d : DimensionalRift)
    if temp = d.teleport_timer_task
      temp.cancel
      d.teleport_timer_task = nil
    end

    if temp = d.teleport_timer
      temp.cancel
      d.teleport_timer = nil
    end

    if temp = d.spawn_timer_task
      temp.cancel
      d.spawn_timer_task = nil
    end

    if temp = d.spawn_timer
      temp.cancel
      d.spawn_timer = nil
    end
  end

  private def get_needed_items(type : Int8) : Int32
    case type
    when 1
      Config.rift_enter_cost_recruit
    when 2
      Config.rift_enter_cost_soldier
    when 3
      Config.rift_enter_cost_officer
    when 4
      Config.rift_enter_cost_captain
    when 5
      Config.rift_enter_cost_commander
    when 6
      Config.rift_enter_cost_hero
    else
      raise "No needed items found for type #{type} (valid: 1..6)"
    end
  end

  def show_html_file(pc : L2PcInstance, file : String, npc : L2Npc)
    html = NpcHtmlMessage.new(npc.l2id)
    html.set_file(pc, file)
    html["%npc_name%"] = npc.name
    pc.send_packet(html)
  end

  def handle_cheat(pc : L2PcInstance, npc : L2Npc)
    show_html_file(pc, "data/html/seven_signs/rift/Cheater.htm", npc)
    unless pc.gm?
      warn { "Player #{pc.name} (#{pc.l2id}) was cheating in dimensional rift area." }
      Util.punish(pc, "tried to cheat in dimensional rift.")
    end
  end

  def allowed_enter?(type : Int8)
    room = ROOMS[type]
    count = room.each_value.count &.party_inside?
    count < room.size - 1
  end

  def get_free_rooms(type : Int8) : Array(Int8)
    ret = [] of Int8

    ROOMS[type].each_value do |room|
      unless room.party_inside?
        ret << room.room
      end
    end

    ret
  end
end
