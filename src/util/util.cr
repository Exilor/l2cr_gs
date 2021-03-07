require "../models/actor/tasks/player/illegal_player_action_task"

module Util
  extend self
  extend Loggable
  include Packets::Outgoing

  def in_range?(range : Int32, obj1 : L2Object?, obj2 : L2Object?, z_axis : Bool) : Bool
    return false unless obj1 && obj2
    return false unless obj1.instance_id == obj2.instance_id
    return true if range == -1

    rad = 0
    if obj1.is_a?(L2Character)
      rad &+= obj1.template.collision_radius
    end
    if obj2.is_a?(L2Character)
      rad &+= obj2.template.collision_radius
    end

    d = Math.hypot(obj1.x - obj2.x, obj1.y - obj2.y)
    if z_axis
      d = Math.hypot(d, obj1.z - obj2.z)
    end

    d - (rad / 2) <= range
  end

  def in_short_radius?(radius : Int32, obj1 : L2Object?, obj2 : L2Object?, z_axis : Bool) : Bool
    return false unless obj1 && obj2
    return true if radius == -1

    d = Math.hypot(obj1.x - obj2.x, obj1.y - obj2.y)
    if z_axis
      return Math.hypot(d, obj1.z - obj2.z) <= radius
    end

    d <= radius
  end

  def calculate_distance(loc1 : Locatable, loc2 : Locatable, z_axis : Bool, squared : Bool) : Float64
    calculate_distance(
      loc1.x.to_f, loc1.y.to_f, loc1.z.to_f,
      loc2.x.to_f, loc2.y.to_f, loc2.z.to_f,
      z_axis, squared
    )
  end

  def calculate_distance(x1 : Float64, y1 : Float64, z1 : Float64, x2 : Float64, y2 : Float64, z2 : Float64, z_axis : Bool, squared : Bool) : Float64
    dist = Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2)
    if z_axis
      dist += Math.pow(z1 - z2, 2)
    end
    squared ? dist : Math.sqrt(dist)
  end

  def calculate_heading_from(from : Locatable, to : Locatable) : Int32
    calculate_heading_from(from.x, from.y, to.x, to.y)
  end

  def calculate_heading_from(from_x : Int32, from_y : Int32, to_x : Int32, to_y : Int32) : Int32
    angle_target = Math.to_degrees(Math.atan2(to_y - from_y, to_x - from_x))
    if angle_target < 0
      angle_target = 360.0 + angle_target
    end
    (angle_target * 182.044444444).to_i
  end

  def calculate_heading_from(dx : Float64, dy : Float64) : Int32
    angle_target = Math.to_degrees(Math.atan2(dy, dx))
    if angle_target < 0
      angle_target = 360.0 + angle_target
    end
    (angle_target * 182.044444444).to_i
  end

  def calculate_angle_from(from : Locatable, to : Locatable) : Float64
    calculate_angle_from(from.x, from.y, to.x, to.y)
  end

  def calculate_angle_from(from_x : Int32, from_y : Int32, to_x : Int32, to_y : Int32) : Float64
    angle_target = Math.to_degrees(Math.atan2(to_y - from_y, to_x - from_x))

    if angle_target < 0
      angle_target = 360.0 + angle_target
    end

    angle_target
  end

  def convert_heading_to_degree(heading : Int32) : Float64
    heading / 182.044444444
  end

  def inside_range_of_l2id?(obj, target_obj_id, radius)
    return false unless target = obj.known_list.known_objects[target_obj_id]?
    return false if obj.calculate_distance(target, false, false) > radius
    true
  end

  private def build_html_bypass_cache(pc : L2PcInstance, scope : HtmlActionScope, html : String)
    html_lower = html.downcase
    bypass_end = 0

    while bypass_start = html_lower.index("=\"bypass ", bypass_end)
      bypass_start_end = bypass_start &+ 9
      break unless bypass_end = html_lower.index("\"", bypass_start_end)
      h_param_pos = html_lower.index("-h ", bypass_start_end)
      if h_param_pos && h_param_pos < bypass_end
        bypass = html[h_param_pos &+ 3...bypass_end].strip
      else
        bypass = html[bypass_start_end...bypass_end].strip
      end

      first_param_start = bypass.index(AbstractHtmlPacket::VAR_PARAM_START_CHAR)
      if first_param_start
        bypass = bypass[0..first_param_start]
      end

      pc.add_html_action(scope, bypass)
    end
  end

  private def build_html_link_cache(pc : L2PcInstance, scope : HtmlActionScope, html : String)
    html_lower = html.downcase
    link_end = 0

    while link_start = html_lower.index("=\"link ", link_end)
      link_start_end = link_start &+ 7
      break unless link_end = html_lower.index("\"", link_start_end)
      html_link = html[link_start_end...link_end].strip
      if html_link.empty?
        next
      end
      if html_link.includes?("..")
        next
      end

      pc.add_html_action(scope, "link " + html_link)
    end
  end

  def build_html_action_cache(pc : L2PcInstance, scope : HtmlActionScope, npc_l2id : Int32, html : String?)
    raise ArgumentError.new("npc_l2id can't be negative") if npc_l2id < 0
    raise ArgumentError.new("html can't be nil") if html.nil?
    pc.set_html_action_origin_l2id(scope, npc_l2id)
    build_html_bypass_cache(pc, scope, html)
    build_html_link_cache(pc, scope, html)
  end

  def map(input, input_min, input_max, output_min, output_max)
    input = input.clamp(input_min, input_max)
    (((input - input_min) * (output_max - output_min)) / (input_max - input_min)) + output_min
  end

  def send_cb_html(pc : L2PcInstance, html : String)
    send_cb_html(pc, html, 0)
  end

  def send_cb_html(pc : L2PcInstance, html : String, npc_l2id : Int32)
    send_cb_html(pc, html, nil, npc_l2id)
  end

  def send_cb_html(pc : L2PcInstance, html : String, fill_multi_edit : String?)
    send_cb_html(pc, html, fill_multi_edit, 0)
  end

  def send_cb_html(pc : L2PcInstance, html : String, fill_multi_edit : String?, npc_l2id : Int32)
    return unless pc && html

    pc.clear_html_actions(HtmlActionScope::COMM_BOARD_HTML)

    if npc_l2id > -1
      build_html_action_cache(pc, HtmlActionScope::COMM_BOARD_HTML, npc_l2id, html)
    end

    if fill_multi_edit
      pc.send_packet(ShowBoard.new(html, "1001"))
      fill_multi_edit_content(pc, fill_multi_edit)
    else
      size = html.size
      if size < 16_250
        pc.send_packet(ShowBoard.new(html, "101"))
        pc.send_packet(ShowBoard.new(nil, "102"))
        pc.send_packet(ShowBoard.new(nil, "103"))
      elsif size < 16_250 &* 2
        pc.send_packet(ShowBoard.new(html[0...16_250], "101"))
        pc.send_packet(ShowBoard.new(html.from(16_250), "102"))
        pc.send_packet(ShowBoard.new(nil, "103"))
      elsif size < 16_250 &* 3
        pc.send_packet(ShowBoard.new(html[0...16_250], "101"))
        pc.send_packet(ShowBoard.new(html[16_250...16_250 &* 2], "102"))
        pc.send_packet(ShowBoard.new(html.from(16_250 &* 2), "103"))
      else
        pc.send_packet(ShowBoard.new("<html><body><br><center>Error: HTML was too long!</center></body></html>", "101"))
        pc.send_packet(ShowBoard.new(nil, "102"))
        pc.send_packet(ShowBoard.new(nil, "103"))
      end
    end
  end

  def fill_multi_edit_content(pc : L2PcInstance, text : String)
    pc.send_packet(
      ShowBoard.new(
        {
          "0", "0", "0", "0", "0", "0",
          pc.name, pc.l2id, pc.account_name,
          "9", " " , " ",
          text.gsub("<br>", Config::EOL),
          "0", "0", "0", "0"
        }
      )
    )
  end

  def get_players_count_in_radius(range : Int32, npc : L2Object, playable : Bool, invisible : Bool) : Int32
    count = 0

    npc.known_list.each_object do |obj|
      if playable && (obj.playable? || obj.pet?)
        if !invisible && obj.invisible?
          next
        end

        c = obj.as(L2Character)

        if c.z < npc.z - 100 && c.z > npc.z + 100
          next
        end

        unless GeoData.can_see_target?(*c.xyz, *npc.xyz)
          next
        end

        if Util.in_range?(range, npc, obj, true) && c.alive?
          count &+= 1
        end
      end
    end

    count
  end

  def punish(pc : L2PcInstance, reason : String)
    punish(pc, reason, Config.default_punish)
  end

  def punish(pc : L2PcInstance, reason : String, type : IllegalActionPunishmentType)
    msg = "Player #{pc} of account #{pc.account_name} #{reason}"
    handle_illegal_player_action(pc, msg, type)
  end

  def handle_illegal_player_action(pc : L2PcInstance, msg : String)
    handle_illegal_player_action(pc, msg, Config.default_punish)
  end

  def handle_illegal_player_action(pc : L2PcInstance, msg : String, type : IllegalActionPunishmentType)
    task = IllegalPlayerActionTask.new(pc, msg, type)
    ThreadPoolManager.schedule_general(task, 5000)
  end

  def format_adena(amount : Int) : String
    amount.to_s.gsub(/\B(?=(...)*\b)/, ',')
  end

  def min(*args : Object)
    args.min
  end

  def max(*args : Object)
    args.max
  end

  def get_index_of_min_value(*args : Int32) : Int32
    index = 0

    1.upto(args.size &- 1) do |i|
      if args[i] < args[index]
        index = i
      end
    end

    index
  end

  def get_index_of_max_value(*args : Int32) : Int32
    index = 0

    1.upto(args.size &- 1) do |i|
      if args[i] > args[index]
        index = i
      end
    end

    index
  end
end
