class Packets::Incoming::Say2 < GameClientPacket
  no_action_request

  ALL = 0
  SHOUT = 1 # !
  TELL = 2 # "
  PARTY = 3 # #
  CLAN = 4 # @
  GM = 5
  PETITION_PLAYER = 6 # used for petition
  PETITION_GM = 7 # * used for petition
  TRADE = 8 # +
  ALLIANCE = 9 # $
  ANNOUNCEMENT = 10
  BOAT = 11
  L2FRIEND = 12
  MSNCHAT = 13
  PARTYMATCH_ROOM = 14
  PARTYROOM_COMMANDER = 15 # (Yellow)
  PARTYROOM_ALL = 16 # (Red)
  HERO_VOICE = 17
  CRITICAL_ANNOUNCE = 18
  SCREEN_ANNOUNCE = 19
  BATTLEFIELD = 20
  MPCC_ROOM = 21
  NPC_ALL = 22
  NPC_SHOUT = 23

  CHAT_NAMES = {
    "ALL",
    "SHOUT",
    "TELL",
    "PARTY",
    "CLAN",
    "GM",
    "PETITION_PLAYER",
    "PETITION_GM",
    "TRADE",
    "ALLIANCE",
    "ANNOUNCEMENT", # 10
    "BOAT",
    "L2FRIEND",
    "MSNCHAT",
    "PARTYMATCH_ROOM",
    "PARTYROOM_COMMANDER",
    "PARTYROOM_ALL",
    "HERO_VOICE",
    "CRITICAL_ANNOUNCE",
    "SCREEN_ANNOUNCE",
    "BATTLEFIELD",
    "MPCC_ROOM"
  }

  WALKER_COMMAND_LIST = {
    "USESKILL",
    "USEITEM",
    "BUYITEM",
    "SELLITEM",
    "SAVEITEM",
    "LOADITEM",
    "MSG",
    "DELAY",
    "LABEL",
    "JMP",
    "CALL",
    "RETURN",
    "MOVETO",
    "NPCSEL",
    "NPCDLG",
    "DLGSEL",
    "CHARSTATUS",
    "POSOUTRANGE",
    "POSINRANGE",
    "GOHOME",
    "SAY",
    "EXIT",
    "PAUSE",
    "STRINDLG",
    "STRNOTINDLG",
    "CHANGEWAITTYPE",
    "FORCEATTACK",
    "ISMEMBER",
    "REQUESTJOINPARTY",
    "REQUESTOUTPARTY",
    "QUITPARTY",
    "MEMBERSTATUS",
    "CHARBUFFS",
    "ITEMCOUNT",
    "FOLLOWTELEPORT"
  }

  @text = ""
  @type = 0
  @target : String?

  private def read_impl
    @text = s
    @type = d
    @target = s if @type == TELL
  end

  private def run_impl
    return unless pc = active_char

    debug { "[#{CHAT_NAMES[@type]}] #{pc}: #{@text}" }

    if @type < 0 || @type >= CHAT_NAMES.size
      warn { "Invalid pc type #{@type} from #{pc}." }
      pc.action_failed
      pc.logout
      return
    end

    if @text.empty?
      warn { "#{pc} sent an empty chat message." }
      pc.action_failed
      pc.logout
      return
    end


    unless pc.gm?
      if @text.includes?("\b") && @text.size > 500 || !@text.includes?("\b") && @text.size > 105
        pc.send_packet(SystemMessageId::DONT_SPAM)
        return
      end
    end

    if Config.l2walker_protection && @type == TELL && check_bot(@text)
      Util.punish(pc, "using L2Walker")
      return
    end

    if pc.cursed_weapon_equipped? && (@type == TRADE || @type == SHOUT)
      pc.send_packet(SystemMessageId::SHOUT_AND_TRADE_CHAT_CANNOT_BE_USED_WHILE_POSSESSING_CURSED_WEAPON)
      return
    end

    if pc.chat_banned? && @text[0] != '.'
      if pc.effect_list.get_first_effect(EffectType::CHAT_BLOCK)
        pc.send_packet(SystemMessageId::YOU_HAVE_BEEN_REPORTED_SO_CHATTING_NOT_ALLOWED)
      else
        Config.ban_chat_channels.each do |chat_id|
          if @type == chat_id
            pc.send_packet(SystemMessageId::CHATTING_IS_CURRENTLY_PROHIBITED)
            break
          end
        end
      end

      return
    end

    if pc.jailed? && Config.jail_disable_chat
      if @type.in?(TELL, SHOUT, TRADE, HERO_VOICE)
        pc.send_message("You can not chat with players outside of the jail.")
        return
      end
    end

    if @type == PETITION_PLAYER && pc.gm?
      @type = PETITION_GM
    end

    # chat logging

    if @text.includes?("\b")
      unless parse_and_publish_item(pc)
        debug "#parse_and_publish_item returned false."
        return
      end
    end

    if target = L2World.get_player(@target)
      evt = OnPlayerChat.new(pc, target, @text, @type)
      if filter = EventDispatcher.notify(evt, ChatFilterReturn)
        @text = filter.filtered_text
      end
    end

    if Config.use_say_filter
      check_text
    end

    if handler = ChatHandler[@type]
      handler.handle_chat(@type, pc, @target, @text)
    else
      warn { "No handler registered for chat type #{@type} (player: #{pc})." }
    end
  end

  private def check_bot(text)
    WALKER_COMMAND_LIST.any? { |cmd| text.starts_with?(cmd) }
  end

  private def check_text
    Config.filter_list.each do |word|
      @text = @text.gsub(word, Config.chat_filter_chars)
    end
  end

  private def parse_and_publish_item(pc)
    pos1 = nil

    while pos1 = @text.index("\b", pos1 || 0)
      unless pos = @text.index("ID=", pos1)
        return false
      end
      pos &+= 3
      result = String.build(9) do |io|
        while (temp = @text[pos]).number?
          io << temp
          pos &+= 1
        end
      end
      id = result.to_i
      item = L2World.find_object(id)

      if item.is_a?(L2ItemInstance)
        unless pc.inventory.get_item_by_l2id(id)
          warn { "#{pc} tried to publish an item he doesn't own (ID: #{id})." }
          return false
        end

        item.publish
      else
        warn { "#{pc} tried to publish an object that is not an item: #{item}:#{item.class}." }
        return false
      end

      unless pos1 = @text.index("\b", pos)
        warn { "#{pc} sent an invalid publish item message (ID: #{id})." }
        return false
      end
      pos1 &+= 1
    end

    true
  end
end
