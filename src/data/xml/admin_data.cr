require "../../models/access_level"
require "../../models/admin_command_access_right"

module AdminData
  extend self
  extend XMLReader

  private ACCESS_LEVELS = {} of Int32 => AccessLevel
  private ADMIN_COMMAND_ACCESS_RIGHTS = {} of String => AdminCommandAccessRight
  private GM_LIST = Concurrent::Map(L2PcInstance, Bool).new

  @@highest_level = 0

  def load
    ACCESS_LEVELS.clear
    ADMIN_COMMAND_ACCESS_RIGHTS.clear
    parse_datapack_file("../config/accessLevels.xml")
    info { "Loaded #{ACCESS_LEVELS.size} access levels." }
    parse_datapack_file("../config/adminCommands.xml")
    info { "Loaded #{ADMIN_COMMAND_ACCESS_RIGHTS.size} access commands." }
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      each_element(n) do |d, d_name|
        if d_name.casecmp?("access")
          set = get_attributes(d)
          level = AccessLevel.new(set)
          if level.level > @@highest_level
            @@highest_level = level.level
          end
          ACCESS_LEVELS[level.level] = level
        elsif d_name.casecmp?("admin")
          set = get_attributes(d)
          command = AdminCommandAccessRight.new(set)
          ADMIN_COMMAND_ACCESS_RIGHTS[command.admin_command] = command
        end
      end
    end
  end

  def get_access_level(level : Int) : AccessLevel
    return ACCESS_LEVELS[-1] if level < 0
    ACCESS_LEVELS[level] ||= AccessLevel.new
  end

  def max : AccessLevel
    ACCESS_LEVELS[@@highest_level]
  end

  def includes?(level : Int) : Bool
    ACCESS_LEVELS.has_key?(level)
  end

  def has_access?(command : String, level : AccessLevel) : Bool
    unless tmp = ADMIN_COMMAND_ACCESS_RIGHTS[command]?
      if level.level > 0 && level.level == @@highest_level
        tmp = AdminCommandAccessRight.new(command, true, level.level)
        ADMIN_COMMAND_ACCESS_RIGHTS[command] = tmp
        info { "No rights defined for admin command '#{command}'. Auto setting access level #{level.level}." }
      else
        info { "No rights defined for admin command '#{command}'." }
        return false
      end
    end

    tmp.has_access?(level)
  end

  def require_confirm?(command : String) : Bool
    unless tmp = ADMIN_COMMAND_ACCESS_RIGHTS[command]
      info { "No rights defined for admin command '#{command}'." }
      return false
    end

    tmp.require_confirm?
  end

  def get_all_gms(include_hidden : Bool) : Array(L2PcInstance)
    list = [] of L2PcInstance
    GM_LIST.each { |k, v| list << k if include_hidden || !v }
    list
  end

  def get_all_gm_names(include_hidden : Bool) : Array(String)
    GM_LIST.map { |k, v| v ? k.name + " (Invis)" : k.name }
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
      pc.send_packet(SystemMessageId::GM_LIST)
      get_all_gm_names(pc.gm?).each do |name|
        sm = Packets::Outgoing::SystemMessage.gm_c1
        sm.add_string(name)
        pc.send_packet(sm)
      end
    else
      pc.send_packet(SystemMessageId::NO_GM_PROVIDING_SERVICE_NOW)
    end
  end

  def broadcast_to_gms(gsp : GameServerPacket)
    GM_LIST.each_key &.send_packet(gsp)
  end

  def broadcast_message_to_gms(msg : String)
    GM_LIST.each_key &.send_message(msg)
  end
end
