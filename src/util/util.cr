require "../models/actor/tasks/player/illegal_player_action_task"

module Util
  extend self
  extend Loggable
  include Packets::Outgoing

  def in_range?(range : Int32, obj1 : L2Object?, obj2 : L2Object?, include_z_axis : Bool) : Bool
    return false unless obj1 && obj2
    return false unless obj1.instance_id == obj2.instance_id
    return true if range == -1

    rad = 0
    if obj1.is_a?(L2Character)
      rad += obj1.template.collision_radius
    end
    if obj2.is_a?(L2Character)
      rad += obj2.template.collision_radius
    end

    d = Math.hypot(obj1.x - obj2.x, obj1.y - obj2.y)
    if include_z_axis
      d = Math.hypot(d, obj1.z - obj2.z)
    end

    d - (rad / 2) <= range
  end

  def in_short_radius?(radius : Int32, obj1 : L2Object?, obj2 : L2Object?, include_z_axis : Bool) : Bool
    return false unless obj1 && obj2
    return true if radius == -1

    dx = obj1.x - obj2.x
    dy = obj1.y - obj2.y

    if include_z_axis
      dz = obj1.z - obj2.z
      dx.abs2 + dy.abs2 + (dz * dz) <= radius.abs2
    else
      dx.abs2 + dy.abs2 <= radius.abs2
    end
  end

  def calculate_distance(loc1 : Locatable, loc2 : Locatable, z_axis : Bool, squared : Bool) : Float64
    calculate_distance(
      loc1.x.to_f, loc1.y.to_f, loc1.z.to_f,
      loc2.x.to_f, loc2.y.to_f, loc2.z.to_f,
      z_axis,
      squared
    )
  end

  def calculate_distance(x1 : Float64, y1 : Float64, z1 : Float64, x2 : Float64, y2 : Float64, z2 : Float64, z_axis : Bool, squared : Bool) : Float64
    dist = (x1 - x2).abs2 + (y1 - y2).abs2
    if z_axis
      dist += (z1 - z2).abs2
    end
    squared ? dist : Math.sqrt(dist)
  end

  def calculate_heading_from(from : Locatable, to : Locatable) : Int32
    calculate_heading_from(from.x, from.y, to.x, to.y)
  end

  def calculate_heading_from(from_x : Int32, from_y : Int32, to_x : Int32, to_y : Int32) : Int32
    angle_target = Math.to_degrees(Math.atan2(to_y - from_y, to_x - from_x))
    if angle_target < 0
      angle_target = 360 + angle_target
    end
    (angle_target * 182.044444444).to_i
  end

  def calculate_heading_from(dx : Float64, dy : Float64) : Int32
    angle_target : Float64
    angle_target = Math.to_degrees(Math.atan2(dy, dx))
    if angle_target < 0
      angle_target = 360 + angle_target
    end
    (angle_target * 182.044444444).to_i
  end

  def calculate_angle_from(from : Locatable, to : Locatable) : Float64
    calculate_angle_from(from.x, from.y, to.x, to.y)
  end

  def calculate_angle_from(from_x : Int32, from_y : Int32, to_x : Int32, to_y : Int32) : Float64
    angle_target = Math.to_degrees(Math.atan2(to_y - from_y, to_x - from_x))

    if angle_target < 0
      angle_target = 360 + angle_target
    end

    angle_target
  end

  def convert_heading_to_degree(heading : Int32) : Float64
    heading / 182.044444444
  end

  # # unused
  # def convert_degree_to_client_heading(degree)
  #   if degree < 0
  #     degree = 360 + degree
  #   end
  #
  #   (degree * 182.044444444).to_i
  # end

  def inside_range_of_l2id?(obj, target_obj_id, radius)
    return false unless target = obj.known_list.known_objects[target_obj_id]?
    return false if obj.calculate_distance(target, false, false) > radius
    true
  end

  def build_html_bypass_cache(pc, scope, html)
    html_lower = html.downcase
    bypass_end = 0
    bypass_start = html_lower.index("=\"bypass ", bypass_end) || -1
    # debug "build_html_bypass_cache"
    while bypass_start != -1
      bypass_start_end = bypass_start + 9
      bypass_end = html_lower.index("\"", bypass_start_end) || -1
      break if bypass_end == -1
      h_param_pos = html_lower.index("-h ", bypass_start_end) || -1
      if h_param_pos != -1 && h_param_pos < bypass_end
        bypass = html[h_param_pos + 3...bypass_end].strip
      else
        bypass = html[bypass_start_end...bypass_end].strip
      end

      first_parameter_start = bypass.index(AbstractHtmlPacket::VAR_PARAM_START_CHAR) || -1
      if first_parameter_start != -1
        bypass = bypass[0...first_parameter_start + 1]
      end

      pc.add_html_action(scope, bypass)
      bypass_start = html_lower.index("=\"bypass ", bypass_end) || -1
    end
  end

  def build_html_link_cache(pc, scope, html)
    html_lower = html.downcase
    link_end = 0
    link_start = html_lower.index("=\"link ", link_end) || -1
    # debug "build_html_link_cache"
    while link_start != -1
      link_start_end = link_start + 7
      link_end = html_lower.index("\"", link_start_end) || -1
      break if link_end == -1
      html_link = html[link_start_end...link_end].strip
      if html_link.empty?
        next
      end
      if html_link.includes?("..")
        next
      end

      pc.add_html_action(scope, "link #{html_link}")
      link_start = html_lower.index("=\"link ", link_end) || -1
    end
  end


  def build_html_action_cache(pc, scope, npc_l2id, html)
    html = html.to_s
    raise ArgumentError.new("npc_l2id can't be negative") if npc_l2id < 0
    pc.set_html_action_origin_l2id scope, npc_l2id
    build_html_bypass_cache(pc, scope, html)
    build_html_link_cache(pc, scope, html)
    # debug pc.@html_action_caches
  end

  def map(input, input_min, input_max, output_min, output_max)
    input = input.clamp(input_min, input_max)
    (((input - input_min) * (output_max - output_min)) / (input_max - input_min)) + output_min
  end

  # def send_html(pc, html)
  #   npc_html = NpcHtmlMessage.new
  #   npc_html.html = html
  #   pc.send_packet(npc_html)
  # end

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
      if size < 16250
        pc.send_packet(ShowBoard.new(html, "101"))
        pc.send_packet(ShowBoard.new(nil, "102"))
        pc.send_packet(ShowBoard.new(nil, "103"))
      elsif size < 16250 * 2
        pc.send_packet(ShowBoard.new(html[0...16250], "101"))
        pc.send_packet(ShowBoard.new(html.from(16250), "102"))
        pc.send_packet(ShowBoard.new(nil, "103"))
      elsif size < 16250 * 3
        pc.send_packet(ShowBoard.new(html[0...16250], "101"))
        pc.send_packet(ShowBoard.new(html[16250...16250 * 2], "102"))
        pc.send_packet(ShowBoard.new(html.from(16250 * 2), "103"))
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

  def count_params(str : String) : Int32
    count = 0

    0.upto(str.size - 2) do |i|
      c1 = str[i]
      if c1 == 'C' || c1 == 'S'
        c2 = str[i + 1]
        if c2.number?
          count = Math.max(count, c2.to_i)
        end
      end
    end

    count
  end

  def punish(pc : L2PcInstance, reason : String)
    punish(pc, reason, Config.default_punish)
  end

  def punish(pc : L2PcInstance, reason : String, type : IllegalActionPunishmentType)
    msg = "Player #{pc.name} of account #{pc.account_name} #{reason}"
    handle_illegal_player_action(pc, msg, type)
  end

  def handle_illegal_player_action(pc : L2PcInstance, msg : String)
    handle_illegal_player_action(pc, msg, Config.default_punish)
  end

  def handle_illegal_player_action(pc : L2PcInstance, msg : String, type : IllegalActionPunishmentType)
    task = IllegalPlayerActionTask.new(pc, msg, type)
    ThreadPoolManager.schedule_general(task, 5000)
  end

  def format_adena(amount : Number) : String
    sprintf("%.2f", amount)
  end
end
