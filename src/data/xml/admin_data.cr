require "../../models/access_level"
require "../../models/admin_command_access_right"

module AdminData
  extend self
  extend XMLReader

  private ACCESS_LEVELS = {} of Int32 => AccessLevel
  private ADMIN_COMMAND_ACCESS_RIGHTS = {} of String => AdminCommandAccessRight
  private GM_LIST = {} of L2PcInstance => Bool # concurrent
  @@highest_level = 0

  def load
    ACCESS_LEVELS.clear
    ADMIN_COMMAND_ACCESS_RIGHTS.clear
    parse_datapack_file("../config/accessLevels.xml")
    info "Loaded #{ACCESS_LEVELS.size} access levels."
    parse_datapack_file("../config/adminCommands.xml")
    info "Loaded #{ADMIN_COMMAND_ACCESS_RIGHTS.size} access commands."
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.each_element do |d|
        if d.name.casecmp?("access")
          set = StatsSet.new(d.attributes)
          level = AccessLevel.new(set)
          if level.level > @@highest_level
            @@highest_level = level.level
          end
          ACCESS_LEVELS[level.level] = level
        elsif d.name.casecmp?("admin")
          set = StatsSet.new(d.attributes)
          command = AdminCommandAccessRight.new(set)
          ADMIN_COMMAND_ACCESS_RIGHTS[command.admin_command] = command
        end
      end
    end
  end

  def get_access_level(level : Int)
    return ACCESS_LEVELS[-1] if level < 0

    ACCESS_LEVELS[level] ||= AccessLevel.new
  end

  def max
    ACCESS_LEVELS[@@highest_level]
  end

  def includes?(level : Int)
    ACCESS_LEVELS.has_key?(level)
  end

  def has_access?(command : String, level : AccessLevel) : Bool
    unless acar = ADMIN_COMMAND_ACCESS_RIGHTS[command]
      if level.level > 0 && level.level == @@highest_level
        acar = AdminCommandAccessRight.new(command, true, level.level)
        ADMIN_COMMAND_ACCESS_RIGHTS[command] = acar
        info "No rights defined for admin command #{command.inspect}. Auto setting access level #{level.level}."
      else
        info "No rights defined for admin command #{command.inspect}."
        return false
      end
    end

    acar.has_access?(level)
  end

  def require_confirm?(command : String)
    unless acar = ADMIN_COMMAND_ACCESS_RIGHTS[command]
      info "No rights defined for admin command #{command.inspect}."
      return false
    end

    acar.require_confirm?
  end

  def get_all_gms(include_hidden : Bool)
    list = [] of L2PcInstance
    GM_LIST.each { |k, v| list << k if include_hidden || !v }
    list
  end

  def get_all_gm_names(include_hidden : Bool)
    list = [] of String
    GM_LIST.each do |k, v|
      list << (v ? "#{k.name} (invis)" : k.name)
    end
    list
  end

  def show_gm(pc : L2PcInstance)
    if GM_LIST.has_key?(pc)
      GM_LIST[pc] = false
    end
  end

  def add_gm(pc : L2PcInstance, invisible : Bool)
    GM_LIST[pc] = invisible
  end

  def delete_gm(pc : L2PcInstance)
    GM_LIST.delete(pc)
  end

  def hide_gm(pc : L2PcInstance)
    if GM_LIST.has_key?(pc)
      GM_LIST[pc] = true
    end
  end

  def gm_online?(include_hidden : Bool) : Bool
    GM_LIST.any? { |_, hidden| include_hidden || !hidden }
  end

  def send_list_to_player(pc : L2PcInstance)
    if gm_online?(pc.gm?)
      pc.send_packet(Packets::Outgoing::SystemMessage.gm_list)
      get_all_gm_names(pc.gm?).each do |name|
        sm = Packets::Outgoing::SystemMessage.gm_c1
        sm.add_string(name)
        pc.send_packet(sm)
      end
    else
      pc.send_packet(Packets::Outgoing::SystemMessage.no_gm_providing_service_now)
    end
  end

  def broadcast_to_gms(gsp : GameServerPacket)
    GM_LIST.each_key &.send_packet(gsp)
  end

  def broadcast_message_to_gms(msg : String)
    GM_LIST.each_key &.send_message(msg)
  end
end
