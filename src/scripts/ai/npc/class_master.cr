class NpcAI::ClassMaster < AbstractNpcAI
  # NPCs
  private MR_CAT = 31756
  private MISS_QUEEN = 31757
  # Vars
  private CUSTOM_EVENT_ID = 1001

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(MR_CAT, MISS_QUEEN)
    add_first_talk_id(MR_CAT, MISS_QUEEN)
    add_talk_id(MR_CAT, MISS_QUEEN)
    if Config.alternate_class_master
      self.on_enter_world = true
      register_tutorial_event
      register_tutorial_question_mark
    end

    if Config.allow_class_masters
      add_spawn(MR_CAT, Location.new(147728, 27408, -2198, 16500))
      add_spawn(MISS_QUEEN, Location.new(147761, 27408, -2198, 16500))
      add_spawn(MR_CAT, Location.new(148560, -57952, -2974, 53000))
      add_spawn(MISS_QUEEN, Location.new(148514, -57972, -2974, 53000))
      add_spawn(MR_CAT, Location.new(110592, 220400, -3667, 0))
      add_spawn(MISS_QUEEN, Location.new(110592, 220443, -3667, 0))
      add_spawn(MR_CAT, Location.new(117200, 75824, -2725, 25000))
      add_spawn(MISS_QUEEN, Location.new(117160, 75784, -2725, 25000))
      add_spawn(MR_CAT, Location.new(116224, -181728, -1373, 0))
      add_spawn(MISS_QUEEN, Location.new(116218, -181793, -1379, 0))
      add_spawn(MR_CAT, Location.new(114880, -178144, -827, 0))
      add_spawn(MISS_QUEEN, Location.new(114880, -178196, -827, 0))
      add_spawn(MR_CAT, Location.new(83076, 147912, -3467, 32000))
      add_spawn(MISS_QUEEN, Location.new(83082, 147845, -3467, 32000))
      add_spawn(MR_CAT, Location.new(81136, 54576, -1517, 32000))
      add_spawn(MISS_QUEEN, Location.new(81126, 54519, -1517, 32000))
      add_spawn(MR_CAT, Location.new(45472, 49312, -3067, 53000))
      add_spawn(MISS_QUEEN, Location.new(45414, 49296, -3067, 53000))
      add_spawn(MR_CAT, Location.new(47648, 51296, -2989, 38500))
      add_spawn(MISS_QUEEN, Location.new(47680, 51255, -2989, 38500))
      add_spawn(MR_CAT, Location.new(17956, 170536, -3499, 48000))
      add_spawn(MISS_QUEEN, Location.new(17913, 170536, -3499, 48000))
      add_spawn(MR_CAT, Location.new(15584, 142784, -2699, 16500))
      add_spawn(MISS_QUEEN, Location.new(15631, 142778, -2699, 16500))
      add_spawn(MR_CAT, Location.new(11340, 15972, -4577, 14000))
      add_spawn(MISS_QUEEN, Location.new(11353, 16022, -4577, 14000))
      add_spawn(MR_CAT, Location.new(10968, 17540, -4567, 55000))
      add_spawn(MISS_QUEEN, Location.new(10918, 17511, -4567, 55000))
      add_spawn(MR_CAT, Location.new(-14048, 123184, -3115, 32000))
      add_spawn(MISS_QUEEN, Location.new(-14050, 123229, -3115, 32000))
      add_spawn(MR_CAT, Location.new(-44979, -113508, -194, 32000))
      add_spawn(MISS_QUEEN, Location.new(-44983, -113554, -194, 32000))
      add_spawn(MR_CAT, Location.new(-84119, 243254, -3725, 8000))
      add_spawn(MISS_QUEEN, Location.new(-84047, 243193, -3725, 8000))
      add_spawn(MR_CAT, Location.new(-84336, 242156, -3725, 24500))
      add_spawn(MISS_QUEEN, Location.new(-84294, 242204, -3725, 24500))
      add_spawn(MR_CAT, Location.new(-82032, 150160, -3122, 16500))
      add_spawn(MISS_QUEEN, Location.new(-81967, 150160, -3122, 16500))
      add_spawn(MR_CAT, Location.new(147865, -58047, -2979, 48999))
      add_spawn(MISS_QUEEN, Location.new(147906, -58047, -2979, 48999))
      add_spawn(MR_CAT, Location.new(147300, -56466, -2779, 11500))
      add_spawn(MISS_QUEEN, Location.new(147333, -56483, -2784, 11500))
      add_spawn(MR_CAT, Location.new(44176, -48732, -800, 33000))
      add_spawn(MISS_QUEEN, Location.new(44176, -48688, -800, 33000))
      add_spawn(MR_CAT, Location.new(44333, -47639, -800, 49999))
      add_spawn(MISS_QUEEN, Location.new(44371, -47638, -800, 49999))
      add_spawn(MR_CAT, Location.new(87596, -140674, -1542, 16500))
      add_spawn(MISS_QUEEN, Location.new(87644, -140674, -1542, 16500))
      add_spawn(MR_CAT, Location.new(87824, -142256, -1343, 44000))
      add_spawn(MISS_QUEEN, Location.new(87856, -142272, -1344, 44000))
      add_spawn(MR_CAT, Location.new(-116948, 46841, 367, 49151))
      add_spawn(MISS_QUEEN, Location.new(-116902, 46841, 367, 49151))
    end
  end

  def on_tutorial_event(player, command)
    if command.starts_with?("CO")
      on_tutorial_link(player, command)
    end

    super
  end

  def on_enter_world(player)
    show_question_mark(player)
    # Containers.Players.addListener(new ConsumerEventListener(Containers.Players, ON_PLAYER_LEVEL_CHANGED, (OnPlayerLevelChanged event) ->
    #   show_question_mark(event.getActiveChar)
    # }, this))

    lst = ConsumerEventListener.new(Containers::PLAYERS, EventType::ON_PLAYER_LEVEL_CHANGED, self) do |evt|
      show_question_mark(evt.as(OnPlayerLevelChanged).active_char)
    end
    Containers::PLAYERS.add_listener(lst)

    super
  end

  def on_adv_event(event, npc, player)
    return unless player && npc
    if event.ends_with?(".htm")
      return event
    end

    if event.starts_with?("1stClass")
      show_html_menu(player, npc.l2id, 1)
    elsif event.starts_with?("2ndClass")
      show_html_menu(player, npc.l2id, 2)
    elsif event.starts_with?("3rdClass")
      show_html_menu(player, npc.l2id, 3)
    elsif event.starts_with?("change_class")
      val = event.from(13).to_i
      if check_and_change_class(player, val)
        msg = get_htm(player, "ok.htm").sub("%name%", ClassListData.get_class!(val).client_code)
        show_result(player, msg)
        return ""
      end
    elsif event.starts_with?("become_noble")
      unless player.noble?
        player.noble = true
        player.send_packet(UserInfo.new(player))
        player.send_packet(ExBrExtraUserInfo.new(player))
        return "nobleok.htm"
      end
    elsif event.starts_with?("learn_skills")
      player.give_available_skills(Config.auto_learn_fs_skills, true)
    elsif event.starts_with?("increase_clan_level")
      unless player.clan_leader?
        return "noclanleader.htm"
      end
      if player.clan.level >= 5
        return "noclanlevel.htm"
      end
      player.clan.change_level(5)
    else
      warn { "Player #{player} send invalid request [#{event}]" }
    end

    ""
  end

  def on_first_talk(npc, player)
    "#{npc.id}.htm"
  end

  private def on_tutorial_link(player, request)
    if !Config.alternate_class_master || request.nil? || !request.starts_with?("CO")
      return
    end

    unless player.flood_protectors.server_bypass.try_perform_action("changeclass")
      debug "Flood detected"
      return
    end

    begin
      val = request.from(2).to_i
      check_and_change_class(player, val)
    rescue e
      warn { "Player #{player} send invalid class change request [#{request}]." }
    end
    player.send_packet(TutorialCloseHtml::STATIC_PACKET)
  end

  def on_tutorial_question_mark(player, number)
    if !Config.alternate_class_master || number != CUSTOM_EVENT_ID
      return ""
    end

    show_tutorial_html(player)
    ""
  end

  private def show_question_mark(player)
    unless Config.alternate_class_master
      return
    end

    class_id = player.class_id
    if get_min_lvl(class_id.level) > player.level
      return
    end

    unless Config.class_master_settings.allowed?(class_id.level + 1)
      return
    end

    player.send_packet(TutorialShowQuestionMark.new(CUSTOM_EVENT_ID))
  end

  private def show_html_menu(player, l2id, level)
    unless Config.allow_class_masters
      msg = get_htm(player, "disabled.htm")
      show_result(player, msg)
      return
    end

    unless Config.class_master_settings.allowed?(level)
      html = NpcHtmlMessage.new(l2id)
      job_lvl = player.class_id.level
      sb = String.build(100) do |io|
        io << "<html><body>"
        case job_lvl
        when 0
          if Config.class_master_settings.allowed?(1)
            io << "Come back here when you reached level 20 to change your class.<br>"
          elsif Config.class_master_settings.allowed?(2)
            io << "Come back after your first occupation change.<br>"
          elsif Config.class_master_settings.allowed?(3)
            io << "Come back after your second occupation change.<br>"
          else
            io << "I can't change your occupation.<br>"
          end
        when 1
          if Config.class_master_settings.allowed?(2)
            io << "Come back here when you reached level 40 to change your class.<br>"
          elsif Config.class_master_settings.allowed?(3)
            io << "Come back after your second occupation change.<br>"
          else
            io << "I can't change your occupation.<br>"
          end
        when 2
          if Config.class_master_settings.allowed?(3)
            io << "Come back here when you reached level 76 to change your class.<br>"
          else
            io << "I can't change your occupation.<br>"
          end
        when 3
          io << "There is no class change available for you anymore.<br>"
        end
        io << "</body></html>"
      end
      html.html = sb
      html["%req_items%"] = get_required_items(level)
      player.send_packet(html)
      return
    end

    current_class_id = player.class_id
    if current_class_id.level >= level
      msg = get_htm(player, "nomore.htm")
      show_result(player, msg)
      return
    end

    min_lvl = get_min_lvl(current_class_id.level)
    if player.level >= min_lvl || Config.allow_entire_tree
      menu = String.build(100) do |io|
        ClassId.each do |cid|
          if cid.inspector? && player.total_subclasses < 2
            next
          end
          if validate_class_id(current_class_id, cid) && cid.level == level
            io << "<a action=\"bypass -h Quest ClassMaster change_class "
            io << cid.to_i
            io << "\">"
            io << ClassListData.get_class!(cid).client_code
            io << "</a><br>"
          end
        end
      end

      if menu.size > 0
        msg = get_htm(player, "template.htm")
        msg = msg.sub("%name%", ClassListData.get_class!(current_class_id).client_code)
        msg = msg.sub("%menu%", menu)
        show_result(player, msg)
        return

      end
      msg = get_htm(player, "comebacklater.htm")
      msg = msg.sub("%level%", get_min_lvl(level - 1).to_s)
      show_result(player, msg)
      return
    end

    if min_lvl < Int32::MAX
      msg = get_htm(player, "comebacklater.htm")
      msg = msg.sub("%level%", min_lvl.to_s)
      show_result(player, msg)
      return
    end

    show_result(player, get_htm(player, "nomore.htm"))
  end

  private def show_tutorial_html(player)
    current_class_id = player.class_id
    if get_min_lvl(current_class_id.level) > player.level && !Config.allow_entire_tree
      return
    end

    msg = get_htm(player, "tutorialtemplate.htm")
    msg = msg.gsub("%name%", ClassListData.get_class!(current_class_id).escaped_client_code)

    menu = String.build(100) do |io|
      ClassId.each do |cid|
        if cid.inspector? && player.total_subclasses < 2
          next
        end
        if validate_class_id(current_class_id, cid)
          io << "<a action=\"link CO" << cid.to_i << "\">"
          io << ClassListData.get_class!(cid).escaped_client_code
          io << "</a><br>"
        end
      end
    end

    msg = msg.gsub("%menu%", menu)
    msg = msg.sub("%req_items%", get_required_items(current_class_id.level + 1))
    player.send_packet(TutorialShowHtml.new(msg))
  end

  private def check_and_change_class(player, val)
    current_class_id = player.class_id
    if get_min_lvl(current_class_id.level) > player.level && !Config.allow_entire_tree
      return false
    end

    unless validate_class_id(current_class_id, val)
      return false
    end

    new_job_lvl = current_class_id.level + 1

    # Weight/Inventory check
    if !Config.class_master_settings.get_reward_items(new_job_lvl).empty? && !player.inventory_under_90?(false)
      player.send_packet(SystemMessageId::INVENTORY_LESS_THAN_80_PERCENT)
      return false
    end

    # check if player have all required items for class transfer
    Config.class_master_settings.get_require_items(new_job_lvl).each do |holder|
      if player.inventory.get_inventory_item_count(holder.id, -1) < holder.count
        player.send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
        return false
      end
    end

    # get all required items for class transfer
    Config.class_master_settings.get_require_items(new_job_lvl).each do |holder|
      unless player.destroy_item_by_item_id("ClassMaster", holder.id, holder.count, player, true)
        return false
      end
    end

    # reward player with items
    Config.class_master_settings.get_reward_items(new_job_lvl).each do |holder|
      player.add_item("ClassMaster", holder.id, holder.count, player, true)
    end

    player.class_id = val

    if player.subclass_active?
      player.subclasses[player.class_index].class_id = player.active_class
    else
      player.base_class = player.active_class
    end

    player.broadcast_user_info

    if Config.class_master_settings.allowed?(player.class_id.level + 1) && Config.alternate_class_master && ((player.class_id.level == 1 && player.level >= 40) || (player.class_id.level == 2 && player.level >= 76))
      show_question_mark(player)
    end

    true
  end

  def get_min_lvl(level)
    case level
    when 0
      20
    when 1
      40
    when 2
      76
    else
      Int32::MAX
    end
  end

  private def validate_class_id(old_cid, val)
    validate_class_id(old_cid, ClassId[val]?)
  end

  private def validate_class_id(old_cid : ClassId, new_cid : ClassId?)
    !!new_cid && !new_cid.race.none? &&
    (old_cid == new_cid.parent? || (Config.allow_entire_tree && new_cid.child_of?(old_cid)))
  end

  private def get_required_items(level)
    if Config.class_master_settings.get_require_items(level).nil? || Config.class_master_settings.get_require_items(level).empty?
      return "<tr><td>none</td></tr>"
    end

    String.build do |io|
      Config.class_master_settings.get_require_items(level).each do |holder|
        io << "<tr><td><font color=\"LEVEL\">"
        io << holder.count
        io << "</font></td><td>"
        io << ItemTable[holder.id].name
        io << "</td></tr>"
      end
    end
  end
end
