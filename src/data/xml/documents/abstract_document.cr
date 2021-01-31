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

  initializer file : File

  abstract def parse_document(doc, file)

  def parse
    begin
      XMLReader.parse_file(@file) do |doc|
        parse_document(doc, @file)
      end
    rescue e
      error e
    end
    @file.rewind
    self
  end

  private def parse_table(n)
    name = parse_string(n, "name")

    unless name.starts_with?('#')
      raise "Table name must start with '#' (it's '#{name}')"
    end

    ary = get_content(get_first_child(n)).to_s.strip.split(/\s|\t|\n|\r|\f/)
    ary.reject! &.empty?
    @tables[name] = ary
  end

  private def parse_set(n, set, level)
    name = parse_string(n, "name").strip
    value = parse_string(n, "val").strip
    ch = value.empty? ? ' ' : value[0]
    if ch == '#' || ch == '-' || ch.number?
      set[name] = get_value(value, level)
    else
      set[name] = value
    end
  end

  private def get_value(value : String, template = nil)
    if value.starts_with?('#')
      case template
      when Skill
        get_table_value(value)
      when Int
        get_table_value(value, template.to_i)
      else
        raise "Template error with #get_value (#{template.class})"
      end
    else
      value
    end
  end

  def reset_table
    @tables.clear
  end

  private def parse_condition(n, template) : Condition?
    while n && !n.type.element_node?
      n = n.next_sibling
    end

    return unless n

    case get_node_name(n).casecmp
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

    each_element(n) do |n|
      new_cond = parse_condition(n, template)
      cond.add(new_cond) if new_cond
    end

    if cond.conditions.empty?
      error "Empty <and> condition."
    end

    cond
  end

  private def parse_logic_or(n, template)
    cond = Condition::LogicOr.new

    each_element(n) do |n|
      new_cond = parse_condition(n, template)
      cond.add(new_cond) if new_cond
    end

    if cond.conditions.empty?
      error "Empty <or> condition."
    end

    cond
  end

  private def parse_logic_not(n, template)
    each_element(n) do |n|
      if c = parse_condition(n, template)
        return Condition::LogicNot.new(c)
      end
    end

    error "Empty <not> condition."
    nil
  end

  private def parse_player_condition(n, template)
    cond = nil

    each_attribute(n) do |name, text|
      case name.casecmp
      when "races"
        races = text.split(',').slice_map { |r| Race.parse(r) }
        cond = join_and(cond, Condition::PlayerRace.new(races))
      when "level"
        lvl = get_value(text, template).to_i
        cond = join_and(cond, Condition::PlayerLevel.new(lvl))
      when "levelrange"
        if text.count(',') == 2
          range = text.split(',').slice_map &.to_i
          cond = join_and(cond, Condition::PlayerLevelRange.new(range[0]..range[1]))
        end
      when "resting"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::RESTING, text.to_b))
      when "flying"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::FLYING, text.to_b))
      when "moving"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::MOVING, text.to_b))
      when "running"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::RUNNING, text.to_b))
      when "standing"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::STANDING, text.to_b))
      when "behind"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::BEHIND, text.to_b))
      when "front"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::FRONT, text.to_b))
      when "chaotic"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::CHAOTIC, text.to_b))
      when "olympiad"
        cond = join_and(cond, Condition::PlayerState.new(PlayerState::OLYMPIAD, text.to_b))
      when "ishero"
        cond = join_and(cond, Condition::PlayerIsHero.new(text.to_b))
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
        cond = join_and(cond, Condition::PlayerIsClanLeader.new(text.to_b))
      when "ontvtevent"
        cond = join_and(cond, Condition::PlayerTvTEvent.new(text.to_b))
      when "pledgeclass"
        pledge = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerPledgeClass.new(pledge))
      when "clanhall"
        array = text.split(',').slice_map &.strip.to_i
        cond = join_and(cond, Condition::PlayerHasClanHall.new(array))
      when "fort"
        fort = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerHasFort.new(fort))
      when "castle"
        castle = get_value(text).to_i
        cond = join_and(cond, Condition::PlayerHasCastle.new(castle))
      when "sex"
        sex = get_value(text) == "1" # 0: male, 1: female
        cond = join_and(cond, Condition::PlayerSex.new(sex))
      when "flymounted"
        cond = join_and(cond, Condition::PlayerFlyMounted.new(text.to_b))
      when "vehiclemounted"
        cond = join_and(cond, Condition::PlayerVehicleMounted.new(text.to_b))
      when "landingzone"
        cond = join_and(cond, Condition::PlayerLandingZone.new(text.to_b))
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
        array = text.split(',').slice_map { |s| get_value(s.strip).to_i }
        cond = join_and(cond, Condition::PlayerClassIdRestriction.new(array))
      when "subclass"
        cond = join_and(cond, Condition::PlayerSubclass.new(text.to_b))
      when "instanceid"
        array = text.split(',').slice_map { |s| get_value(s.strip).to_i }
        cond = join_and(cond, Condition::PlayerInstanceId.new(array))
      when "agathionid"
        cond = join_and(cond, Condition::PlayerAgathionId.new(text.to_i))
      when "cloakstatus"
        cond = join_and(cond, Condition::PlayerCloakStatus.new(text.to_b))
      when "haspet"
        array = text.split(',').slice_map { |s| get_value(s.strip).to_i }
        cond = join_and(cond, Condition::PlayerHasPet.new(array))
      when "hasservitor"
        cond = join_and(cond, Condition::PlayerHasServitor.new)
      when "npcidradius"
        if text.count(',') == 3
          v1, v2, v3 = text.split(',')
          ids = v1.split(';').slice_map { |s| get_value(s, template).to_i }
          radius = v2.to_i
          val = v3.to_b
          cond = join_and(cond, Condition::PlayerRangeFromNpc.new(ids, radius, val))
        end
      when "callpc"
        cond = join_and(cond, Condition::PlayerCallPc.new(text.to_b))
      when "cancreatebase"
        cond = join_and(cond, Condition::PlayerCanCreateBase.new(text.to_b))
      when "cancreateoutpost"
        cond = join_and(cond, Condition::PlayerCanCreateOutpost.new(text.to_b))
      when "canescape"
        cond = join_and(cond, Condition::PlayerCanEscape.new(text.to_b))
      when "canrefuelairship"
        cond = join_and(cond, Condition::PlayerCanRefuelAirship.new(text.to_i))
      when "canresurrect"
        cond = join_and(cond, Condition::PlayerCanResurrect.new(text.to_b))
      when "cansummon"
        cond = join_and(cond, Condition::PlayerCanSummon.new(text.to_b))
      when "cansummonsiegegolem"
        cond = join_and(cond, Condition::PlayerCanSummonSiegeGolem.new(text.to_b))
      when "cansweep"
        cond = join_and(cond, Condition::PlayerCanSweep.new(text.to_b))
      when "cantakecastle"
        cond = join_and(cond, Condition::PlayerCanTakeCastle.new)
      when "cantakefort"
        cond = join_and(cond, Condition::PlayerCanTakeFort.new(text.to_b))
      when "cantransform"
        cond = join_and(cond, Condition::PlayerCanTransform.new(text.to_b))
      when "canuntransform"
        cond = join_and(cond, Condition::PlayerCanUntransform.new(text.to_b))
      when "insidezoneid"
        array = text.split(',').slice_map { |s| get_value(s.strip).to_i }
        cond = join_and(cond, Condition::PlayerInsideZoneId.new(array))
      when "checkabnormal"
        if text.includes?(';')
          v0, v1, v2 = text.split(';')
          v0 = AbnormalType.parse(v0)
          v1 = get_value(v1, template).to_i
          v2 = v2.to_b
          cond = join_and(cond, Condition::CheckAbnormal.new(v0, v1, v2))
        else
          type = AbnormalType.parse(text)
          cond = join_and(cond, Condition::CheckAbnormal.new(type, -1, true))
        end
      when "categorytype"
        ary = text.split(',').map { |s| CategoryType.parse(get_value(s)) }
        cond = join_and(cond, Condition::CategoryType.new(ary))
      when "hasagathion"
        cond = join_and(cond, Condition::PlayerHasAgathion.new(text.to_b))
      when "agathionenergy"
        cond = join_and(cond, Condition::PlayerAgathionEnergy.new(text.to_i))
      end
    end

    cond
  end

  private def parse_target_condition(n, template)
    cond = nil

    each_attribute(n) do |name, text|
      case name.casecmp
      when "aggro"
        cond = join_and(cond, Condition::TargetAggro.new(text.to_b))
      when "siegezone"
        value = get_value(text).to_i
        cond = join_and(cond, Condition::SiegeZone.new(value, false))
      when "level"
        value = get_value(text, template).to_i
        cond = join_and(cond, Condition::TargetLevel.new(value))
      when "levelrange"
        range = get_value(text, template).split(';')
        if range.size == 2
          range = range[0].to_i..range[1].to_i
          cond = join_and(cond, Condition::TargetLevelRange.new(range))
        end
      when "myparty"
        cond = join_and(cond, Condition::TargetMyParty.new(text == "EXCEPT_ME"))
      when "playable"
        cond = join_and(cond, Condition::TargetPlayable.new)
      when "class_id_restriction"
        ary = text.split(',').slice_map { |s| get_value(s.strip).to_i }
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
        text.split(',') do |item|
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
        array = text.split(',').slice_map { |s| get_value(s.strip).to_i }
        cond = join_and(cond, Condition::TargetNpcId.new(array))
      when "npctype"
        types = get_value(text, template).strip.split(';').slice_map do |s|
          InstanceType.parse(s)
        end
        cond = join_and(cond, Condition::TargetNpcType.new(types))
      when "weight"
        weight = get_value(text).to_i
        cond = join_and(cond, Condition::TargetWeight.new(weight))
      when "invsize"
        size = get_value(text).to_i
        cond = join_and(cond, Condition::TargetInvSize.new(size))
      when "checkabnormal"
        if text.includes?(';')
          v0, v1, v2 = text.split(';')
          v0 = AbnormalType.parse(v0)
          v1 = get_value(v1, template).to_i
          v2 = v2.to_b
          cond = join_and(cond, Condition::CheckAbnormal.new(v0, v1, v2))
        else
          type = AbnormalType.parse(text)
          cond = join_and(cond, Condition::CheckAbnormal.new(type, -1, true))
        end
      end
    end

    unless cond
      error "Unrecognized <target> condition."
    end

    cond
  end

  private def parse_using_condition(n)
    cond = nil

    each_attribute(n) do |name, text|
      case name.casecmp
      when "kind"
        mask = 0
        text.split(',') do |item|
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
        text.split(',') do |item|
          item = item.strip
          old = mask

          if slot = ItemTable::SLOTS[item]?
            mask |= slot
          end

          if old == mask
            warn { "parse_using_condition: Unknown item slot name " + item }
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
        cond = join_and(cond, Condition::ChangeWeapon.new(text.to_b))
      end
    end

    unless cond
      error "Unrecognized <using> condition."
    end

    cond
  end

  private def parse_game_condition(n)
    cond = nil

    each_attribute(n) do |name, text|
      case name.casecmp
      when "skill"
        cond = join_and(cond, Condition::WithSkill.new(text.to_b))
      when "night"
        val = text.to_b
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

    return unless n = get_first_element_child(n)

    if get_node_name(n).casecmp?("cond")
      condition = parse_condition(get_first_element_child(n), template)

      msg, msg_id = parse_string(n, "msg", nil), parse_string(n, "msgId", nil)

      if condition && msg
        condition.message = msg
      elsif condition && msg_id
        condition.message_id = get_value(msg_id).to_i
        add_name = parse_string(n, "addName", nil)
        if add_name && get_value(msg_id).to_i > 0
          condition.add_name
        end
      end

      n = get_next_element(n)
    end

    while n
      case (name = get_node_name(n)).casecmp
      when "effect"
        if template.is_a?(AbstractEffect)
          raise "Nested effects"
        end
        attach_effect(n, template, condition, scope)
      when "add", "sub", "mul", "div", "set", "share", "enchant", "enchanthp"
        attach_func(n, template, name, condition)
      end

      n = get_next_element(n)
    end
  end

  private def attach_func(n, template, func_name, attach_cond)
    stat = Stats.from_value(parse_string(n, "stat"))
    order = parse_int(n, "order", -1)

    unless value_string = parse_string(n, "val", nil)
      raise "Missing 'val' on item func"
    end

    if value_string.starts_with?('#')
      value = get_table_value(value_string).to_f
    else
      value = value_string.to_f
    end

    apply_cond = parse_condition(get_first_element_child(n), template)
    ft = FuncTemplate.new(attach_cond, apply_cond, func_name, order, stat, value)

    if template.is_a?(L2Item) || template.is_a?(AbstractEffect)
      template.attach(ft)
    else
      raise "Can't attach stat to #{template}:#{template.class}"
    end
  end

  private def attach_effect(n, template, attach_cond, scope = nil)
    set = StatsSet.new
    each_attribute(n) do |name, text|
      set[name] = get_value(text, template)
    end

    first_child = get_first_element_child(n)
    parameters = parse_parameters(first_child, template)
    apply_cond = parse_condition(first_child, template)

    if template.responds_to?(:id)
      set["id"] = template.id
    end

    effect = AbstractEffect.create_effect(attach_cond, apply_cond, set, parameters)
    parse_template(n, effect)

    if template.is_a?(L2Item)
      error { "Item #{template} with effects." }
    elsif template.is_a?(Skill)
      if effect
        if scope
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
      if get_node_name(n).casecmp?("param")
        parameters ||= StatsSet.new
        each_attribute(n) do |name, text|
          parameters[name] = get_value(text, template)
        end
      end

      n = get_next_element(n)
    end

    parameters || StatsSet::EMPTY
  end

  private def set_extractable_skill_data(set, value)
    set["capsuled_items_skill"] = value
  end
end
