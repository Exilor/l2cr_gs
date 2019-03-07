require "../../../models/pc_appearance"

class Packets::Incoming::CharacterCreate < GameClientPacket
  @name = ""
  @race = 0
  @sex = 0i8
  @class_id = 0
  # @int = 0
  # @str = 0
  # @con = 0
  # @men = 0
  # @dex = 0
  # @wit = 0
  @hair_style = 0i8
  @hair_color = 0i8
  @face = 0i8

  def read_impl
    @name = s
    @race = d
    @sex = d.to_i8
    @class_id = d
    int = d
    str = d
    con = d
    men = d
    dex = d
    wit = d
    @hair_style = d.to_i8
    @hair_color = d.to_i8
    @face = d.to_i8
  end

  def run_impl
    debug "Request to create a character named #{@name.inspect}."

    if @name.size < 1 || @name.size > 16
      debug "#{@name.inspect} is either too short or too long."
      send_packet(CharCreateFail::REASON_16_ENG_CHARS)
      return
    end

    Config.forbidden_names.each do |name|
      if @name.downcase.includes?(name)
        debug "#{@name.inspect} is blacklisted."
        send_packet(CharCreateFail::INCORRECT_NAME)
        return
      end
    end

    unless @name.alnum? && Config.player_name_template === @name
      debug "#{@name.inspect} contains non-alnum characters."
      send_packet(CharCreateFail::INCORRECT_NAME)
      return
    end

    if @face > 2 || @face < 0
      debug "Incorrect face #{@face} for #{@name.inspect}."
      send_packet(CharCreateFail::CREATION_FAILED)
      return
    end

    if @hair_style < 0 || @sex == 0 && @hair_style > 4 || @sex != 0 && @hair_style > 6
      debug "Incorrect hair style/sex combination for #{@name.inspect}."
      send_packet(CharCreateFail::CREATION_FAILED)
      return
    end

    if @hair_color > 3 || @hair_color < 0
      debug "Incorrect hair color #{@hair_color} for #{@name.inspect}."
      send_packet(CharCreateFail::CREATION_FAILED)
      return
    end

    CharNameTable.sync do
      if CharNameTable.get_account_character_count(client.account_name) > Config.max_characters_number_per_account && Config.max_characters_number_per_account > 0
        debug "Max number of characters reached for #{client.account_name.inspect}."
        send_packet(CharCreateFail::TOO_MANY_CHARACTERS)
        return
      elsif CharNameTable.name_exists?(@name)
        debug "#{@name.inspect} already exists."
        send_packet(CharCreateFail::NAME_ALREADY_EXISTS)
        return
      end

      if ClassId[@class_id].level > 0
        debug "Invalid class ID #{@class_id}."
        send_packet(CharCreateFail::CREATION_FAILED)
        return
      end
    end

    app = PcAppearance.new(@face, @hair_color, @hair_style, @sex != 0)
    new_char = L2PcInstance.create(@class_id, client.account_name, @name, app)

    unless new_char
      error "L2PcInstance.create failed."
      return
    end

    new_char.max_hp!.max_mp!


    # init_new_char and send_packet are in reverse order in L2J but doing it
    # that way makes the new char appear to have 0 hp/mp and not be the
    # default char selected
    # init_new_char does a bunch of DB stuff so better wrap it in one transac.
    # DB.transaction do
      init_new_char(new_char)
    # end
    send_packet(CharCreateOk::STATIC_PACKET)
  end

  private def init_new_char(pc)
    debug "Character init start: #{pc}."
    L2World.store_object(pc)

    if Config.starting_adena > 0
      pc.add_adena("Init", Config.starting_adena, nil, false)
    end

    template = pc.template
    loc = PlayerCreationPointData.get_creation_point(template.class_id)
    pc.set_xyz_invisible(*loc.xyz)
    pc.title = ""

    if Config.enable_vitality
      vit = Math.min(Config.starting_vitality_points, PcStat::MAX_VITALITY_POINTS)
      pc.set_vitality_points(vit, true)
    end

    if Config.starting_level > 1
      pc.stat.add_level((Config.starting_level - 1).to_i32)
    end

    if Config.starting_sp > 0
      pc.stat.add_sp(Config.starting_sp)
    end

    if equipment = InitialEquipmentData[pc.class_id]?
      equipment.each do |ie|
        item = pc.inventory.add_item("Init", ie.id, ie.count, pc, nil)
        unless item
          warn "Could not create item during character creation (id: #{ie.id}, count: #{ie.count})."
          next
        end

        if item.equippable? && ie.equipped?
          pc.inventory.equip_item(item)
        end
      end
    else
      debug "No initial equipment data for ClassId #{pc.class_id}."
    end

    SkillTreesData.get_available_skills(pc, pc.class_id, false, true).each do |skill|
      pc.add_skill(SkillData[skill.skill_id, skill.skill_level], true)
    end

    InitialShortcutData.register_all_shortcuts(pc)

    evt = OnPlayerCreate.new(pc, pc.l2id, pc.name, client)
    evt.notify(Containers::PLAYERS)

    pc.set_online_status(true, false)
    pc.delete_me

    csi = CharSelectionInfo.new(client.account_name, client.session_id.play_ok_1)
    client.char_selection = csi.char_info

    debug "Character init end." if Config.debug
  end
end
