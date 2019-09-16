require "../../../data_tables/item_table"
require "../../../models/skills/skill"
require "../../../enums/player_state"
require "../../../enums/armor_type"
require "../../../enums/weapon_type"
require "../../../enums/stats"
require "../../../enums/effect_scope"
require "../../../models/effects/abstract_effect"

abstract class AbstractDocument
  include XMLReader
  include Loggable

  @tables = {} of String => Array(String)

  def initialize(@file : File)
  end

  abstract def parse_document(doc, file)

  def parse
    begin
      text = @file.gets_to_end
      doc = XML.parse(text)
      parse_document(doc, "")
    rescue e
      error e
    end
    @file.rewind
    self
  end

  def parse_table(n)
    name = n["name"]

    unless name.starts_with?('#')
      raise "Table name must start with '#' (#{name.inspect})"
    end

    ary = n.children.first.text.to_s.strip.split(/\s|\t|\n|\r|\f/)
    ary.reject! &.empty?
    @tables[name] = ary
  end

  def parse_set(n, set, level)
    name = n["name"].strip
    value = n["val"].strip
    ch = value.empty? ? ' ' : value[0]
    if ch == '#' || ch == '-' || ch.number?
      set[name] = get_value(value, level)
    else
      set[name] = value
    end
  end

  def get_value(value : String, template = nil)
    if value.starts_with?('#')
      if template.is_a?(Skill)
        get_table_value(value)
      elsif template.is_a?(Int)
        get_table_value(value, template.to_i)
      else
        raise "template error with #get_value (#{template.class})"
      end
    else
      value
    end
  end

  def reset_table
    @tables.clear
  end

  private def parse_condition(n : XML::Node?, template) : Condition?
    while n && !n.type.element_node?
      n = n.next_sibling
    end

    return unless n

    case n.name.casecmp
    when "and"
      parse_logic_and(n, template)
    when "or"
      parse_logic_or(n, template)
    when "not"
      parse_logic_not(n, template)
    when "player"
      parse_player_condition(n, template)
    when "target"
      parse_target_condition(n, template)
    when "using"
      parse_using_condition(n)
    when "game"
      parse_game_condition(n)
    end
  end

  private def parse_logic_and(n, template)
    cond = Condition::LogicAnd.new

    n.each_element do |n|
      if n.type.element_node?
        new_cond = parse_condition(n, template)
        cond.add(new_cond) if new_cond
      end
    end

    if cond.conditions.empty?
      error "Empty <and> condition."
    end

    cond
  end

  private def parse_logic_or(n, template)
    cond = Condition::LogicOr.new

    n.each_element do |n|
      if n.type.element_node?
        new_cond = parse_condition(n, template)
        cond.add(new_cond) if new_cond
      end
    end

    if cond.conditions.empty?
      error "Empty <or> condition."
    end

    cond
  end

  private def parse_logic_not(n, template)
    n.each_element do |n|
      if n.type.element_node?
        if c = parse_condition(n, template)
          return Condition::LogicNot.new(c)
        end
      end
    end

    error "Empty <not> condition."
    nil
  end

  private def parse_player_condition(n, template)
    cond = nil

    n.attributes.each_pair do |name, text|
      case name.casecmp
      when "races"
        races = text.split(',').map { |r| Race.parse(r) }
        cond = join_and(cond, Condition::PlayerRace.new(races))
      when "level"
        lvl = get_value(text, template).to_i
        cond = join_and(cond, Condition::PlayerLevel.new(lvl))
      when "levelrange"
        if text.count(',') == 2
          range = text.split(',').map &.to_i
          cond = join_and(cond, Condition::PlayerLevelRange.new(range[0]..range[1]))
        end
      when "resting"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::RESTING, Bool.new(text)))
      when "flying"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::FLYING, Bool.new(text)))
      when "moving"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::MOVING, Bool.new(text)))
      when "running"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::RUNNING, Bool.new(text)))
      when "standing"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::STANDING, Bool.new(text)))
      when "behind"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::BEHIND, Bool.new(text)))
      when "front"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::FRONT, Bool.new(text)))
      when "chaotic"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::CHAOTIC, Bool.new(text)))
      when "olympiad"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::OLYMPIAD, Bool.new(text)))
      when "ishero"
        cond = join_and(cond, Condition::PlayerIsHero.new(Bool.new(text)))
      when "transformationid"
        cond = join_and(cond, Condition::PlayerTransformationId.new(text.to_i))
      when "hp"
        hp = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerHp.new(hp))
      when "mp"
        mp = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerMp.new(mp))
      when "cp"
        cp = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerCp.new(cp))
      when "grade"
        exp = get_value(text, template).to_i
        cond = join_and(cond, Condition::PlayerGrade.new(exp))
      when "pkcount"
        exp = get_value(text, template).to_i
        cond = join_and(cond, Condition::PlayerPkCount.new(exp))
      when "siegezone"
        value = get_value(text).to_i
        cond = join_and(cond, Condition::SiegeZone.new(value, true))
      when "siegeside"
        value = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerSiegeSide.new(value))
      when "charges"
        value = get_value(text, template).to_i
        cond = join_and(cond, Condition::PlayerCharges.new(value))
      when "souls"
        value = get_value(text, template).to_i
        cond = join_and(cond, Condition::PlayerSouls.new(value))
      when "weight"
        value = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerWeight.new(value))
      when "invsize"
        value = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerInvSize.new(value))
      when "isclanleader"
        cond = join_and(cond, Condition::PlayerIsClanLeader.new(Bool.new(text)))
      when "ontvtevent"
        cond = join_and(cond, Condition::PlayerTvTEvent.new(Bool.new(text)))
      when "pledgeclass"
        pledge = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerPledgeClass.new(pledge))
      when "clanhall"
        array = text.split(',').map &.strip.to_i
        cond = join_and(cond, Condition::PlayerHasClanHall.new(array))
      when "fort"
        fort = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerHasFort.new(fort))
      when "castle"
        castle = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerHasCastle.new(castle))
      when "sex"
        sex = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerSex.new(sex))
      when "flymounted"
        cond = join_and(cond, Condition::PlayerFlyMounted.new(Bool.new(text)))
      when "vehiclemounted"
        cond = join_and(cond, Condition::PlayerVehicleMounted.new(Bool.new(text)))
      when "landingzone"
        cond = join_and(cond, Condition::PlayerLandingZone.new(Bool.new(text)))
      when "active_effect_id"
        effect_id = get_value(text, template).to_i
        cond = join_and(cond, Condition::PlayerActiveEffectId.new(effect_id))
      when "active_effect_id_lvl"
        v1, v2 = get_value(text, template).split(',')
        effect_id = get_value(v1, template).to_i
        effect_lvl = get_value(v2, template).to_i
        cond = join_and(cond, Condition::PlayerActiveEffectId.new(effect_id, effect_lvl))
      when "active_skill_id"
        skill_id = get_value(text, template).to_i
        cond = join_and(cond, Condition::PlayerActiveSkillId.new(skill_id))
      when "active_skill_id_lvl"
        v1, v2 = get_value(text, template).split(',')
        skill_id = get_value(v1, template).to_i
        skill_lvl = get_value(v2, template).to_i
        cond = join_and(cond, Condition::PlayerActiveSkillId.new(skill_id, skill_lvl))
      when "class_id_restriction"
        array = text.split(',').map { |s| get_value(s.strip).to_i }
        cond = join_and(cond, Condition::PlayerClassIdRestriction.new(array))
      when "subclass"
        cond = join_and(cond, Condition::PlayerSubclass.new(Bool.new(text)))
      when "instanceid"
        array = text.split(',').map { |s| get_value(s.strip).to_i }
        cond = join_and(cond, Condition::PlayerInstanceId.new(array))
      when "agathionid"
        cond = join_and(cond, Condition::PlayerAgathionId.new(text.to_i))
      when "cloakstatus"
        cond = join_and(cond, Condition::PlayerCloakStatus.new(Bool.new(text)))
      when "haspet"
        array = text.split(',').map { |s| get_value(s.strip).to_i }
        cond = join_and(cond, Condition::PlayerHasPet.new(array))
      when "hasservitor"
        cond = join_and(cond, Condition::PlayerHasServitor.new)
      when "npcidradius"
        if text.count(',') == 3
          v1, v2, v3 = text.split(',')
          ids = v1.split(';').map { |s| get_value(s, template).to_i }
          radius = v2.to_i
          val = Bool.new(v3)
          cond = join_and(cond, Condition::PlayerRangeFromNpc.new(ids, radius, val))
        end
      when "callpc"
        cond = join_and(cond, Condition::PlayerCallPc.new(Bool.new(text)))
      when "cancreatebase"
        cond = join_and(cond, Condition::PlayerCanCreateBase.new(Bool.new(text)))
      when "cancreateoutpost"
        cond = join_and(cond, Condition::PlayerCanCreateOutpost.new(Bool.new(text)))
      when "canescape"
        cond = join_and(cond, Condition::PlayerCanEscape.new(Bool.new(text)))
      when "canrefuelairship"
        cond = join_and(cond, Condition::PlayerCanRefuelAirship.new(text.to_i))
      when "canresurrect"
        cond = join_and(cond, Condition::PlayerCanResurrect.new(Bool.new(text)))
      when "cansummon"
        cond = join_and(cond, Condition::PlayerCanSummon.new(Bool.new(text)))
      when "cansummonsiegegolem"
        cond = join_and(cond, Condition::PlayerCanSummonSiegeGolem.new(Bool.new(text)))
      when "cansweep"
        cond = join_and(cond, Condition::PlayerCanSweep.new(Bool.new(text)))
      when "cantakecastle"
        cond = join_and(cond, Condition::PlayerCanTakeCastle.new)
      when "cantakefort"
        cond = join_and(cond, Condition::PlayerCanTakeFort.new(Bool.new(text)))
      when "cantransform"
        cond = join_and(cond, Condition::PlayerCanTransform.new(Bool.new(text)))
      when "canuntransform"
        cond = join_and(cond, Condition::PlayerCanUntransform.new(Bool.new(text)))
      when "insidezoneid"
        array = text.split(',').map { |s| get_value(s.strip).to_i }
        cond = join_and(cond, Condition::PlayerInsideZoneId.new(array))
      when "checkabnormal"
        if text.includes?(',')
          v1, v2 = text.split(',')
          v1 = AbnormalType.parse(v1)
          v2 = get_value(v2, template).to_i
          cond = join_and(cond, Condition::PlayerCheckAbnormal.new(v1, v2))
        else
          cond = join_and(cond, Condition::PlayerCheckAbnormal.new(AbnormalType.parse(text)))
        end
      when "categorytype"
        ary = text.split(',').map { |s| CategoryType.parse(get_value(s)) }
        cond = join_and(cond, Condition::CategoryType.new(ary))
      end
    end

    cond
  end

  private def parse_target_condition(n, template)
    cond = nil

    n.attributes.each_pair do |name, text|
      case name.casecmp
      when "aggro"
        cond = join_and(cond, Condition::TargetAggro.new(Bool.new(text)))
      when "siegezone"
        value = get_value(text).to_i
        cond = join_and(cond, Condition::SiegeZone.new(value, false))
      when "level"
        value = get_value(text, template).to_i
        cond = join_and(cond, Condition::TargetLevel.new(value))
      when "levelrange"
        range = get_value(text, template).split(';')
        if range.size == 2
          range = range.map &.to_i
          cond = join_and(cond, Condition::TargetLevelRange.new(range[0]..range[1]))
        end
      when "mypartyexceptme"
        cond = join_and(cond, Condition::TargetMyPartyExceptMe.new(Bool.new(text)))
      when "playable"
        cond = join_and(cond, Condition::TargetPlayable.new)
      when "class_id_restriction"
        ary = text.split(',').map { |s| get_value(s.strip).to_i }
        cond = join_and(cond, Condition::TargetClassIdRestriction.new(ary))
      when "active_effect_id"
        effect_id = get_value(text, template).to_i
        cond = join_and(cond, Condition::TargetActiveEffectId.new(effect_id))
      when "active_effect_id_lvl"
        v1, v2 = get_value(text, template).split(',')
        effect_id = get_value(v1, template).to_i
        effect_lvl = get_value(v2, template).to_i
        cond = join_and(cond, Condition::TargetActiveEffectId.new(effect_id, effect_lvl))
      when "active_skill_id"
        skill_id = get_value(text, template).to_i
        cond = join_and(cond, Condition::TargetActiveSkillId.new(skill_id))
      when "active_skill_id_lvl"
        v1, v2 = get_value(text, template).split(',')
        skill_id = get_value(v1, template).to_i
        skill_lvl = get_value(v2, template).to_i
        cond = join_and(cond, Condition::TargetActiveSkillId.new(skill_id, skill_lvl))
      when "abnormal"
        abn = get_value(text, template).to_i
        cond = join_and(cond, Condition::TargetAbnormal.new(abn))
      when "mindistance"
        dst = get_value(text).to_i * 2
        cond = join_and(cond, Condition::MinDistance.new(dst))
      when "race"
        cond = join_and(cond, Condition::TargetRace.new(Race.parse(text)))
      when "using"
        mask = 0
        text.split(',').each do |item|
          item = item.strip

          if wt = WeaponType.parse?(item)
            mask |= wt.mask
          end

          if at = ArmorType.parse?(item)
            mask |= at.mask
          end
        end
        cond = join_and(cond, Condition::TargetUsesWeaponKind.new(mask))
      when "npcid"
        array = text.split(',').map { |s| get_value(s.strip).to_i }
        cond = join_and(cond, Condition::TargetNpcId.new(array))
      when "npctype"
        types = get_value(text, template).strip.split(';').map do |s|
          InstanceType.parse(s)
        end
        cond = join_and(cond, Condition::TargetNpcType.new(types))
      when "weight"
        weight = get_value(text).to_i
        cond = join_and(cond, Condition::TargetWeight.new(weight))
      when "invsize"
        size = get_value(text).to_i
        cond = join_and(cond, Condition::TargetInvSize.new(size))
      end
    end

    unless cond
      error "Unrecognized <target> condition."
    end

    cond
  end

  private def parse_using_condition(n)
    cond = nil

    n.attributes.each_pair do |name, text|
      case name.casecmp
      when "kind"
        mask = 0
        text.split(',').each do |item|
          item = item.strip

          if wt = WeaponType.parse?(item)
            mask |= wt.mask
          end

          if at = ArmorType.parse?(item)
            mask |= at.mask
          end
        end

        cond = join_and(cond, Condition::UsingItemType.new(mask))
      when "slot"
        mask = 0
        text.split(',').each do |item|
          item = item.strip
          old = mask

          if slot = ItemTable::SLOTS[item]?
            mask |= slot
          end

          if old == mask
            warn { "parse_using_condition=\"slot\"] Unknown item slot name: #{item}" }
          end
        end

        cond = join_and(cond, Condition::UsingSlotType.new(mask))
      when "skill"
        cond = join_and(cond, Condition::UsingSkill.new(text.to_i))
      when "slotitem"
        st = text.split(';')
        id = st[0].strip.to_i
        slot = st[1].strip.to_i
        enchant = st[3].strip.to_i

        cond = join_and(cond, Condition::SlotItemId.new(slot, id, enchant))
      when "weaponchange"
        cond = join_and(cond, Condition::ChangeWeapon.new(Bool.new(text)))
      end
    end

    unless cond
      error "Unrecognized <using> condition."
    end

    cond
  end

  private def parse_game_condition(n)
    cond = nil

    n.attributes.each_pair do |name, text|
      case name.casecmp
      when "skill"
        cond = join_and(cond, Condition::WithSkill.new(Bool.new(text)))
      when "night"
        val = Bool.new(text)
        night = Condition::GameTime::CheckGameTime::NIGHT
        cond = join_and(cond, Condition::GameTime.new(night, val))
      when "chance"
        val = get_value(text).to_i
        cond = join_and(cond, Condition::GameChance.new(val))
      end
    end

    unless cond
      error "Unrecognized <game> condition."
    end

    cond
  end

  private def parse_template(n, template, scope : EffectScope? = nil)
    condition = nil
    # debug "#{template.name}: #{n.children.inspect}"
    return unless n = n.first_element_child

    if n.name.casecmp?("cond")
      condition = parse_condition(n.first_element_child, template)

      msg, msg_id = n["msg"]?, n["msgId"]?

      if condition && msg
        condition.message = msg
      elsif condition && msg_id
        condition.message_id = get_value(msg_id).to_i
        add_name = n["addName"]?
        if add_name && get_value(msg_id).to_i > 0
          condition.add_name
        end
      end

      n = n.next_element
    end

    while n
      case name = n.name.downcase
      when "effect"
        if template.is_a?(AbstractEffect)
          raise "Nested effects"
        end
        attach_effect(n, template, condition, scope)
      when /^(?:add|sub|mul|div|set|share|enchant|enchanthp)$/
        attach_func(n, template, name, condition)
      end

      n = n.next_element
    end
  end

  private def attach_func(n, template, func_name, attach_cond)
    stat = Stats.from_value(n["stat"].to_s)
    order = -1

    order_node = n["order"]?
    order = order_node ? order_node.to_i : -1

    unless value_string = n["val"]?
      raise "Missing 'val' on item func"
    end

    if value_string.starts_with?("#")
      value = get_table_value(value_string).to_f
    else
      value = value_string.to_f
    end

    apply_cond = parse_condition(n.first_element_child, template)
    ft = FuncTemplate.new(attach_cond, apply_cond, func_name, order, stat, value)

    if template.is_a?(L2Item) || template.is_a?(AbstractEffect)
      template.attach(ft)
    end
  end

  private def attach_effect(n, template, attach_cond, scope = nil)
    set = StatsSet.new
    n.attributes.each_pair do |name, text|
      set[name] = get_value(text, template)
    end

    first_child = n.first_element_child
    parameters = parse_parameters(first_child, template)
    apply_cond = parse_condition(first_child, template)

    if template.responds_to?(:id) # L2J: instanceof IIdentifiable
      set["id"] = template.id
    end

    effect = AbstractEffect.create_effect(attach_cond, apply_cond, set, parameters)
    parse_template(n, effect)

    if template.is_a?(L2Item)
      error "Item #{template} with effects."
    elsif template.is_a?(Skill)
      if effect
        if scope
          # debug "#{template.name} (#{template.id}) => #{scope}"
          template.add_effect(scope, effect)
        elsif template.passive?
          template.add_effect(EffectScope::PASSIVE, effect)
        else
          template.add_effect(EffectScope::GENERAL, effect)
        end
      end
    end
  end

  private def join_and(cond, c)
    return c unless cond

    if cond.is_a?(Condition::LogicAnd)
      cond.add(c)
      return cond
    end

    logic_and = Condition::LogicAnd.new
    logic_and.add(cond)
    logic_and.add(c)
    logic_and
  end

  private def parse_parameters(n, template)
    parameters = nil

    while n
      if n.type.element_node? && n.name.casecmp?("param")
        parameters ||= StatsSet.new
        n.attributes.each_pair do |name, text|
          parameters[name] = get_value(text, template)
        end
      end

      n = n.next_element
    end

    parameters || StatsSet::EMPTY
  end

  private def set_extractable_skill_data(set, value)
    set["capsuled_items_skill"] = value
  end
end
