require "../l2_npc"

class L2TeleporterInstance < L2Npc
  private COND_ALL_FALSE = 0
  private COND_BUSY_BECAUSE_OF_SIEGE = 1
  private COND_OWNER = 2
  private COND_REGULAR = 3

  def instance_type : InstanceType
    InstanceType::L2TeleporterInstance
  end

  def get_html_path(npc_id : Int32, val : Int32)
    if val == 0
      "data/html/teleporter/#{npc_id}.htm"
    else
      "data/html/teleporter/#{npc_id}-#{val}.htm"
    end
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    pc.action_failed

    npc_id = id
    condition = validate_condition(pc)
    tokens = command.split
    actual_command = tokens.shift
    if pc.affected_by_skill?(6201) || pc.affected_by_skill?(6202) || pc.affected_by_skill?(6203)
      html = NpcHtmlMessage.new(l2id)
      file_name = "data/html/teleporter/epictransformed.htm"
      html.set_file(pc, file_name)
      html["%objectId%"] = l2id
      html["%npcname%"] = name
      pc.send_packet(html)
      return
    elsif actual_command.casecmp?("goto")
      case npc_id
      when 32534, 32539
        if pc.flying_mounted?
          pc.send_packet(SystemMessageId::YOU_CANNOT_ENTER_SEED_IN_FLYING_TRANSFORM)
          return
        end
      end
      return if tokens.empty?

      where_to = tokens.shift.to_i
      if condition == COND_REGULAR
        do_teleport(pc, where_to)
        return
      elsif condition == COND_OWNER
        min_privilege_level = 0
        unless tokens.empty?
          min_privilege_level = tokens.shift.to_i
        end

        if min_privilege_level <= 10
          do_teleport(pc, where_to)
        else
          pc.send_message("You don't have the sufficient access level to teleport there.")
        end

        return
      end
    elsif command.starts_with?("Chat")
      time = Time.now
      val = command.from(5).to_i(strict: false)
      if val == 1 && pc.level < 41
        show_newbie_html(pc)
        return
      elsif val == 1 && time.hour.between?(20, 23)
        if time.saturday? || time.sunday?
          show_half_price_html(pc)
          return
        end
      end
      show_chat_window(pc, val)
    end

    super
  end

  private def show_newbie_html(pc : L2PcInstance)
    html = NpcHtmlMessage.new(l2id)
    file_name = "data/html/teleporter/free/#{id}.htm"
    unless HtmCache.loadable?(file_name)
      file_name = "data/html/teleporter/#{id}-1.htm"
    end

    html.set_file(pc, file_name)
    html["%objectId%"] = l2id
    html["%npcname%"] = name
    pc.send_packet(html)
  end

  private def show_half_price_html(pc : L2PcInstance)
    html = NpcHtmlMessage.new(l2id)
    file_name = "data/html/teleporter/half/#{id}.htm"
    unless HtmCache.loadable?(file_name)
      file_name = "data/html/teleporter/#{id}-1.htm"
    end

    html.set_file(pc, file_name)
    html["%objectId%"] = l2id
    html["%npcname%"] = name
    pc.send_packet(html)
  end

  def show_chat_window(pc : L2PcInstance)
    file_name = "data/html/teleporter/castleteleporter-no.htm"
    condition = validate_condition(pc)
    if condition == COND_REGULAR
      return super
    elsif condition > COND_ALL_FALSE
      if condition == COND_BUSY_BECAUSE_OF_SIEGE
        file_name = "data/html/teleporter/castleteleporter-busy.htm"
      elsif condition == COND_OWNER
        file_name = get_html_path(id, 0)
      end
    end

    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, file_name)
    html["%objectId%"] = l2id
    html["%npcname%"] = name
    pc.send_packet(html)
  end

  def do_teleport(pc : L2PcInstance, val : Int)
    unless list = TeleportLocationTable[val]?
      warn { "No teleport destination with ID #{val.inspect}." }
      return
    end

    if SiegeManager.get_siege(list.x, list.y, list.z)
      pc.send_packet(SystemMessageId::NO_PORT_THAT_IS_IN_SIGE)
      return
    elsif TownManager.town_has_castle_in_siege?(list.x, list.y) && inside_town_zone?
      pc.send_packet(SystemMessageId::NO_PORT_THAT_IS_IN_SIGE)
      return
    elsif !Config.alt_game_karma_player_can_use_gk && pc.karma > 0
      pc.send_message("Go away, you're not welcome here.")
      return
    elsif pc.combat_flag_equipped?
      pc.send_packet(SystemMessageId::YOU_CANNOT_TELEPORT_WHILE_IN_POSSESSION_OF_A_WARD)
      return
    elsif list.for_noble? && !pc.noble?
      file_name = "data/html/teleporter/nobleteleporter-no.htm"
      html = NpcHtmlMessage.new(l2id)
      html.set_file(pc, file_name)
      html["%objectId%"] = l2id
      html["%npcname%"] = name
      pc.send_packet(html)
      return
    elsif pc.looks_dead?
      return
    end

    price = list.price.to_i64
    if pc.level < 41
      price = 0i64
    elsif !list.for_noble?
      time = Time.now
      if time.hour.between?(20, 23)
        if time.saturday? || time.sunday?
          price //= 2
        end
      end
    end

    if Config.alt_game_free_teleport
      pc.tele_to_location(list.x, list.y, list.z, pc.heading, -1)
    else
      process = list.for_noble? ? "Teleport nobless" : "Teleport"
      if pc.destroy_item_by_item_id(process, list.item_id, price, self, true)
        pc.tele_to_location(list.x, list.y, list.z, pc.heading, -1)
      end
    end

    pc.action_failed
  end

  private def validate_condition(pc)
    case
    when CastleManager.get_castle_index(self) < 0
      return COND_REGULAR
    when castle.siege.in_progress?
      return COND_BUSY_BECAUSE_OF_SIEGE
    when pc.clan && castle.owner_id == pc.clan_id
      return COND_OWNER
    end

    COND_ALL_FALSE
  end
end
