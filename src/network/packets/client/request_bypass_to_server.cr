require "../../../handlers/admin_command_handler"
require "../../../handlers/community_board_handler"
require "../../../handlers/bypass_handler"
require "../../../enums/player_action"
require "../../../util/gm_audit"

class Packets::Incoming::RequestBypassToServer < GameClientPacket
  POSSIBLE_NON_HTML_COMMANDS = {
    "_bbs",
    "bbs",
    "_mail",
    "_friend",
    "_match",
    "_diary",
    "_olympiad?command",
    "manor_menu_select"
  }

  @command = ""

  private def read_impl
    @command = s
  end

  private def run_impl
    return unless pc = active_char

    if @command.empty?
      warn { "#{pc} send an empty bypass." }
      pc.logout
      return
    end

    debug { "#{pc} sent '#{@command}'." }

    validate = true

    POSSIBLE_NON_HTML_COMMANDS.each do |cmd|
      if @command.starts_with?(cmd)
        validate = false
        break
      end
    end

    origin_id = 0
    if validate
      origin_id = pc.validate_html_action(@command)
      if origin_id == -1
        warn { "#{pc} sent non cached bypass '#{@command}'." }
        return
      end

      if origin_id > 0 && !Util.inside_range_of_l2id?(pc, origin_id, L2Npc::INTERACTION_DISTANCE)
        debug { "#{pc} is too far from the NPC." }
        return
      end
    end

    unless flood_protectors.server_bypass.try_perform_action(@command)
      debug "Flood detected."
      return
    end

    begin
      case
      when @command.starts_with?("admin_")
        command = @command[/\A(\S)+/]
        handler = AdminCommandHandler[command]
        unless handler
          if pc.gm?
            pc.send_message("The command '#{command.from(6)}' does not exist")
          end
          warn { "#{pc} requested an admin command that doesn't exist." }
          return
        end

        unless AdminData.has_access?(command, pc.access_level)
          pc.send_message("You don't have the access rights to use that command")
          return
        end

        if AdminData.require_confirm?(command)
          pc.admin_confirm_cmd = @command
          dlg = ConfirmDlg.s1
          dlg.add_string("Are you sure you want execute command '#{@command.from(6)}'?")
          pc.add_action(PlayerAction::ADMIN_COMMAND)
          pc.send_packet(dlg)
        else
          if Config.gmaudit
            GMAudit.log(pc, @command, pc.target.try &.name)
          end

          handler.use_admin_command(@command, pc)
        end
      when CommunityBoardHandler.community_board_command?(@command)
        CommunityBoardHandler.handle_parse_command(@command, pc)
      when @command == "come_here" && pc.gm?
        come_here(pc)
      when @command.starts_with?("npc_")
        end_of_id = @command.index('_', 5) || -1
        if end_of_id > 0
          id = @command[4...end_of_id]
        else
          id = @command.from(4)
        end

        debug id

        if id.number?
          object = L2World.find_object(id.to_i)
          debug "Target: #{object}"
          if object.is_a?(L2Npc) && end_of_id > 0
            if pc.inside_radius?(object, L2Npc::INTERACTION_DISTANCE, false, false)
              object.on_bypass_feedback(pc, @command.from(end_of_id + 1))
            end
          end
        # else
        #   debug "#{id} is not numeric."
        end

        pc.action_failed
      when @command.starts_with?("item_")
        end_of_id = @command.index('_', 5) || -1
        if end_of_id > 0
          id = @command[5...end_of_id]
        else
          id = @command.from(5)
        end

        begin
          item_id = id.to_i
          if item = pc.inventory.get_item_by_l2id(item_id)
            item.on_bypass_feedback(pc, @command.from(end_of_id + 1))
          end

          pc.action_failed
        rescue e
          error e
        end
      when @command.starts_with?("_match")
        idx = @command.index('?') || -1
        idx &+= 1
        params = @command.from(idx)
        st = params.split('&')
        hero_class = st.shift.split('=')[1].to_i
        hero_page = st.shift.split('=')[1].to_i
        hero_id = Hero.get_hero_by_class(hero_class)
        if hero_id > 0
          Hero.show_hero_fights(pc, hero_class, hero_id, hero_page)
        end
      when @command.starts_with?("_diary")
        idx = @command.index('?') || -1
        idx += 1
        params = @command.from(idx)
        st = params.split('&')
        hero_class = st.shift.split('=')[1].to_i
        hero_page = st.shift.split('=')[1].to_i
        hero_id = Hero.get_hero_by_class(hero_class)
        if hero_id > 0
          Hero.show_hero_diary(pc, hero_class, hero_id, hero_page)
        end
      when @command.starts_with?("_olympiad?command")
        arena_id = @command.split('=')[2].to_i
        if handler = BypassHandler["arenachange"]
          handler.use_bypass("arenachange #{arena_id - 1}", pc, nil)
        end
      when @command.starts_with?("manor_menu_select")
        last_npc = pc.last_folk_npc
        if Config.allow_manor && last_npc && last_npc.can_interact?(pc)
          split = @command.from(@command.index('?').try &.&+(1) || 0).split('&')
          ask = split[0].split('=')[1].to_i
          state = split[1].split('=')[1].to_i
          time = split[2].split('=')[1] == '1'
          evt = OnNpcManorBypass.new(pc, last_npc, ask, state, time)
          evt.async(last_npc)
        end
      else
        if handler = BypassHandler[@command]
          if origin_id > 0
            bypass_origin = pc.known_list.known_objects[origin_id]?
            if bypass_origin.is_a?(L2Character)
              handler.use_bypass(@command, pc, bypass_origin)
            else
              handler.use_bypass(@command, pc, nil)
            end
          else
            debug "#{handler} will handle #{@command}."
            handler.use_bypass(@command, pc, nil)
          end
        else
          warn { "#{pc} sent an unhandled server bypass request: '#{@command}'." }
        end
      end
    rescue e
      msg = NpcHtmlMessage.new
      msg.html = String.build(200) do |io|
        io << "<html><body>Bypass error: "
        io << e
        io << "<br1>Bypass command: "
        @command.inspect(io)
        io << "<br1>Stack trace:<br1>"
        e.backtrace.join(io, "<br1>")
        io << "<br1></body></html>"
      end
      msg.disable_validation
      pc.send_packet(msg)
    end
  end

  private def come_here(pc : L2PcInstance)
    return unless npc = pc.target.as?(L2Npc)
    npc.target = pc
    npc.set_intention(AI::MOVE_TO, pc.location)
  end
end
