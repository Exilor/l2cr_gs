require "../../models/l2_skill_learn"
require "../../models/holders/player_skill_holder"
require "../../enums/class_id"

module SkillTreesData
  extend self
  extend XMLReader

  private CLASS_SKILL_TREES    = EnumMap(ClassId, Hash(Int32, L2SkillLearn)).new
  private TRANSFER_SKILL_TREES = EnumMap(ClassId, Hash(Int32, L2SkillLearn)).new

  private COLLECT_SKILL_TREE   = {} of Int32 => L2SkillLearn
  private FISHING_SKILL_TREE   = {} of Int32 => L2SkillLearn
  private PLEDGE_SKILL_TREE    = {} of Int32 => L2SkillLearn
  private SUBCLASS_SKILL_TREE  = {} of Int32 => L2SkillLearn
  private SUBPLEDGE_SKILL_TREE = {} of Int32 => L2SkillLearn
  private TRANSFORM_SKILL_TREE = {} of Int32 => L2SkillLearn
  private COMMON_SKILL_TREE    = {} of Int32 => L2SkillLearn

  private NOBLE_SKILL_TREE   = {} of Int32 => L2SkillLearn
  private HERO_SKILL_TREE    = {} of Int32 => L2SkillLearn
  private GM_SKILL_TREE      = {} of Int32 => L2SkillLearn
  private GM_AURA_SKILL_TREE = {} of Int32 => L2SkillLearn

  private SKILLS_BY_CLASS_ID_HASH_CODES = {} of Int32 => Slice(Int32)
  private SKILLS_BY_RACE_HASH_CODES     = {} of Int32 => Slice(Int32)
  private ALL_SKILLS_HASH_CODES         = [] of Int32

  private PARENT_CLASS_MAP = EnumMap(ClassId, ClassId).new

  class_getter? loading = false

  def load
    timer = Timer.new
    @@loading = true

    CLASS_SKILL_TREES.clear
    TRANSFER_SKILL_TREES.clear

    COLLECT_SKILL_TREE.clear
    FISHING_SKILL_TREE.clear
    PLEDGE_SKILL_TREE.clear
    SUBCLASS_SKILL_TREE.clear
    SUBPLEDGE_SKILL_TREE.clear
    TRANSFORM_SKILL_TREE.clear
    COMMON_SKILL_TREE.clear

    NOBLE_SKILL_TREE.clear
    HERO_SKILL_TREE.clear
    GM_SKILL_TREE.clear
    GM_AURA_SKILL_TREE.clear

    SKILLS_BY_CLASS_ID_HASH_CODES.clear
    SKILLS_BY_RACE_HASH_CODES.clear
    ALL_SKILLS_HASH_CODES.clear

    parse_datapack_directory("skillTrees")
    generate_check_arrays
    report

    @@loading = false
    info { "Skill trees loaded in #{timer.result} s." }
  end

  private def parse_document(doc, file)
    c_id = -1
    class_id = nil
    doc.find_element("list") do |n|
      n.find_element("skillTree") do |d|
        class_skill_tree = {} of Int32 => L2SkillLearn
        transfer_skill_tree = {} of Int32 => L2SkillLearn

        type = d["type"]

        if id = d["classId"]?.try &.to_i
          c_id = id
          class_id = ClassId[id]
        else
          c_id = -1
        end

        if id = d["parentClassId"]?.try &.to_i
          PARENT_CLASS_MAP[class_id.not_nil!] = ClassId[id]
        end

        d.each_element do |c|
          learn_skill_set = StatsSet.new(c.attributes)
          skill_learn = L2SkillLearn.new(learn_skill_set)

          c.each_element do |b|
            case b.name
            when "item"
              id, count = b["id"].to_i, b["count"].to_i
              skill_learn.add_required_item(ItemHolder.new(id, count.to_i64))
            when "preRequisiteSkill"
              id, lvl = b["id"].to_i, b["lvl"].to_i
              skill_learn.add_required_skill(SkillHolder.new(id, lvl))
            when "race"
              skill_learn.add_race(Race.parse(b.content))
            when "residenceId"
              skill_learn.add_residence_id(b.content.to_i)
            when "socialClass"
              skill_learn.social_class = SocialClass.parse(b.content)
            when "subClassConditions"
              slot, lvl = b["slot"].to_i, b["lvl"].to_i
              skill_learn.add_subclass_conditions(slot, lvl)
            end
          end

          hash = SkillData.get_skill_hash(skill_learn.skill_id, skill_learn.skill_level)

          case type
          when "classSkillTree"
            if c_id != -1
              class_skill_tree[hash] = skill_learn
            else
              COMMON_SKILL_TREE[hash] = skill_learn
            end
          when "transferSkillTree"
            transfer_skill_tree[hash] = skill_learn
          when "collectSkillTree"
            COLLECT_SKILL_TREE[hash] = skill_learn
          when "fishingSkillTree"
            FISHING_SKILL_TREE[hash] = skill_learn
          when "pledgeSkillTree"
            PLEDGE_SKILL_TREE[hash] = skill_learn
          when "subClassSkillTree"
            SUBCLASS_SKILL_TREE[hash] = skill_learn
          when "subPledgeSkillTree"
            SUBPLEDGE_SKILL_TREE[hash] = skill_learn
          when "transformSkillTree"
            TRANSFORM_SKILL_TREE[hash] = skill_learn
          when "nobleSkillTree"
            NOBLE_SKILL_TREE[hash] = skill_learn
          when "heroSkillTree"
            HERO_SKILL_TREE[hash] = skill_learn
          when "gameMasterSkillTree"
            GM_SKILL_TREE[hash] = skill_learn
          when "gameMasterAuraSkillTree"
            GM_AURA_SKILL_TREE[hash] = skill_learn
          else
            warn { "Unknown Skill Tree type #{type}." }
          end
        end

        if class_id
          if type == "transferSkillTree"
            TRANSFER_SKILL_TREES[class_id] = transfer_skill_tree
          elsif type == "classSkillTree" && c_id > -1
            if tmp = CLASS_SKILL_TREES[class_id]?
              tmp.merge!(class_skill_tree)
            else
              CLASS_SKILL_TREES[class_id] = class_skill_tree
            end
          end
        end
      end
    end
  end

  private def generate_check_arrays
    key_set = CLASS_SKILL_TREES.keys
    key_set.each_with_index do |cls, i|
      temp_map = get_complete_class_skill_tree(cls)
      array = temp_map.keys_slice
      array.sort!
      SKILLS_BY_CLASS_ID_HASH_CODES[cls.to_i] = array
    end

    list = [] of Int32
    Race.each do |r|
      FISHING_SKILL_TREE.each_value do |s|
        if s.races.includes?(r)
          list << SkillData.get_skill_hash(s.skill_id, s.skill_level)
        end
      end

      TRANSFORM_SKILL_TREE.each_value do |s|
        if s.races.includes?(r)
          list << SkillData.get_skill_hash(s.skill_id, s.skill_level)
        end
      end

      array = list.to_slice
      array.sort!
      SKILLS_BY_RACE_HASH_CODES[r.to_i] = array
      list.clear
    end

    COMMON_SKILL_TREE.each_value do |s|
      if s.races.empty?
        list << SkillData.get_skill_hash(s.skill_id, s.skill_level)
      end
    end

    FISHING_SKILL_TREE.each_value do |s|
      if s.races.empty?
        list << SkillData.get_skill_hash(s.skill_id, s.skill_level)
      end
    end

    TRANSFORM_SKILL_TREE.each_value do |s|
      if s.races.empty?
        list << SkillData.get_skill_hash(s.skill_id, s.skill_level)
      end
    end

    COLLECT_SKILL_TREE.each_value do |s|
      list << SkillData.get_skill_hash(s.skill_id, s.skill_level)
    end

    ALL_SKILLS_HASH_CODES.concat(list)
    ALL_SKILLS_HASH_CODES.sort!
  end

  def get_complete_class_skill_tree(class_id : ClassId) : Hash(Int32, L2SkillLearn)
    skill_tree = {} of Int32 => L2SkillLearn

    skill_tree.merge!(COMMON_SKILL_TREE)

    while class_id
      if temp = CLASS_SKILL_TREES[class_id]?
        skill_tree.merge!(temp)
      end

      class_id = PARENT_CLASS_MAP[class_id]?
    end

    skill_tree
    # skill_tree = {} of Int32 => L2SkillLearn
    # skill_tree.merge! COMMON_SKILL_TREE
    # class_sequence = [] of ClassID
    # while class_id
    #   class_sequence.unshift class_id
    #   class_id = PARENT_CLASS_MAP[class_id]
    # end

    # class_sequence.each do |cid|
    #   class_skill_tree = CLASS_SKILL_TREES[cid]
    #   if class_skill_tree
    #     skill_tree.merge! class_skill_tree
    #   end
    # end

    # skill_tree
  end

  def get_transfer_skill_tree(class_id : ClassId) : Hash(Int32, L2SkillLearn)
    if class_id.level >= 3
      get_transfer_skill_tree(class_id.parent)
    else
      TRANSFER_SKILL_TREES[class_id]
    end
  end

  def common_skill_tree
    COMMON_SKILL_TREE
  end

  def collect_skill_tree
    COLLECT_SKILL_TREE
  end

  def fishing_skill_tree
    FISHING_SKILL_TREE
  end

  def pledge_skill_tree
    PLEDGE_SKILL_TREE
  end

  def subclass_skill_tree
    SUBCLASS_SKILL_TREE
  end

  def subpledge_skill_tree
    SUBPLEDGE_SKILL_TREE
  end

  def transform_skill_tree
    TRANSFORM_SKILL_TREE
  end

  def noble_skill_tree : Hash(Int32, Skill)
    tree = {} of Int32 => Skill

    NOBLE_SKILL_TREE.each do |key, val|
      tree[key] = SkillData[val.skill_id, val.skill_level]
    end

    tree
  end

  def hero_skill_tree : Hash(Int32, Skill)
    tree = {} of Int32 => Skill

    HERO_SKILL_TREE.each do |key, val|
      tree[key] = SkillData[val.skill_id, val.skill_level]
    end

    tree
  end

  def gm_skill_tree : Hash(Int32, Skill)
    tree = {} of Int32 => Skill

    GM_SKILL_TREE.each do |key, val|
      tree[key] = SkillData[val.skill_id, val.skill_level]
    end

    tree
  end

  def gm_aura_skill_tree : Hash(Int32, Skill)
    tree = {} of Int32 => Skill

    GM_AURA_SKILL_TREE.each do |key, val|
      tree[key] = SkillData[val.skill_id, val.skill_level]
    end

    tree
  end

  private def get_skill_tree(from)
    # from = {} # of Int32 => Skill
    from.each do |key, value|
      from[key] = SkillData[value.skill_id, value.skill_level]
    end

    from
  end

  def get_available_skills(pc : L2PcInstance, id : ClassId, fs : Bool, auto : Bool)
    get_available_skills(pc, id, fs, auto, pc)
  end

  def get_available_skills(pc : L2PcInstance, id : ClassId, fs : Bool, auto : Bool, holder : SkillsHolder)
    result = [] of L2SkillLearn
    skills = get_complete_class_skill_tree(id)

    if skills.empty?
      warn { "Skill tree for class #{id} is not defined." }
      return result
    end

    skills.each_value do |skill|
      # config skip divine inspiration

      if pc.level >= skill.get_level#((auto && skill.auto_get?) || skill.learned_by_npc? || (fs && skill.learned_by_fs?)) && (pc.level >= skill.get_level)
        if old_skill = holder.get_known_skill(skill.skill_id)
          if old_skill.level == skill.skill_level - 1
            result << skill
          end
        elsif skill.skill_level == 1
          result << skill
        end
      end
    end

    result
  end

  def get_all_available_skills(pc : L2PcInstance, id : ClassId, fs : Bool, auto : Bool) : Enumerable(Skill)
    holder = PlayerSkillHolder.new(pc)
    learnable = get_available_skills(pc, id, fs, auto, holder)

    while learnable.size > 0
      learnable.each do |s|
        sk = SkillData[s.skill_id, s.skill_level]?
        holder.add_skill(sk) if sk
      end
      learnable = get_available_skills(pc, id, fs, auto, holder)
    end

    holder.skills.local_each_value
  end

  def get_available_auto_get_skills(pc : L2PcInstance) : Array(L2SkillLearn)
    result = [] of L2SkillLearn
    skills = get_complete_class_skill_tree(pc.class_id)
    if skills.empty?
      warn { "Skill tree for class #{pc.class_id} is not defined." }
      return result
    end

    race = pc.race
    skills.each_value do |skill|
      if !skill.races.empty? && !skill.races.includes?(race)
        next
      end
      if skill.auto_get? && pc.level >= skill.get_level
        if old_skill = pc.skills[skill.skill_id]?
          if old_skill.level < skill.skill_level
            result << skill
          end
        else
          result << skill
        end
      end
    end

    result
  end

  def get_available_fishing_skills(pc : L2PcInstance) : Array(L2SkillLearn)
    result = [] of L2SkillLearn
    race = pc.race
    FISHING_SKILL_TREE.each_value do |skill|
      if !skill.races.empty? && !skill.races.includes?(race)
        next
      end

      if skill.learned_by_npc? && pc.level >= skill.get_level
        if old_skill = pc.skills[skill.skill_id]?
          if old_skill.level == skill.skill_level - 1
            result << skill
          end
        elsif skill.skill_level == 1
          result << skill
        end
      end
    end

    result
  end

  def get_available_collect_skills(pc : L2PcInstance) : Array(L2SkillLearn)
    result = [] of L2SkillLearn

    COLLECT_SKILL_TREE.each_value do |skill|
      if old_skill = pc.skills[skill.skill_id]?
        if old_skill.level == skill.skill_level - 1
          result << skill
        end
      elsif skill.skill_level == 1
        result << skill
      end
    end

    result
  end

  def get_available_transfer_skills(pc : L2PcInstance) : Array(L2SkillLearn)
    result = [] of L2SkillLearn
    class_id = pc.class_id

    if class_id.level == 3
      class_id = class_id.parent
    end

    unless tmp = TRANSFER_SKILL_TREES[class_id]?
      return result
    end

    tmp.each_value do |skill|
      unless pc.get_known_skill(skill.skill_id)
        result << skill
      end
    end

    result
  end

  def get_available_transform_skills(pc : L2PcInstance) : Array(L2SkillLearn)
    result = [] of L2SkillLearn
    race = pc.race

    TRANSFORM_SKILL_TREE.each_value do |skill|
      if pc.level >= skill.get_level && skill.races.empty? || skill.races.includes?(race)
        if old_skill = pc.skills[skill.skill_id]?
          if old_skill.level == skill.skill_level - 1
            result << skill
          end
        elsif skill.skill_level == 1
          result << skill
        end
      end
    end

    result
  end

  def get_available_pledge_skills(clan : L2Clan) : Array(L2SkillLearn)
    result = [] of L2SkillLearn

    PLEDGE_SKILL_TREE.each_value do |skill|
      if !skill.residencial_skill? && clan.level >= skill.get_level
        if old_skill = clan.skills[skill.skill_id]?
          if old_skill.level + 1 == skill.skill_level
            result << skill
          end
        elsif skill.skill_level == 1
          result << skill
        end
      end
    end

    result
  end

  def get_max_pledge_skills(clan : L2Clan, include_squad : Bool) : Hash(Int32, L2SkillLearn)
    result = {} of Int32 => L2SkillLearn

    PLEDGE_SKILL_TREE.each_value do |skill|
      if !skill.residencial_skill? && clan.level >= skill.get_level
        old_skill = clan.skills[skill.skill_id]?
        if !old_skill || old_skill.level < skill.skill_level
          result[skill.skill_id] = skill
        end
      end
    end

    if include_squad
      SUBPLEDGE_SKILL_TREE.each_value do |skill|
        if clan.level >= skill.get_level
          old_skill = clan.skills[skill.skill_id]?
          if !old_skill || old_skill.level < skill.skill_level
            result[skill.skill_id] = skill
          end
        end
      end
    end

    result
  end

  def get_available_subpledge_skills(clan : L2Clan) : Array(L2SkillLearn)
    SUBPLEDGE_SKILL_TREE.select_values do |skill|
      clan.level >= skill.get_level &&
      clan.learnable_sub_skill?(skill.skill_id, skill.skill_level)
    end
  end

  def get_available_subclass_skills(pc : L2PcInstance) : Array(L2SkillLearn)
    result = [] of L2SkillLearn

    SUBCLASS_SKILL_TREE.each_value do |skill|
      if pc.level >= skill.get_level
        pc.subclasses.each_value do |subclass|
          subclass_conds = skill.subclass_conditions
          if !subclass_conds.empty? && subclass.class_index <= subclass_conds.size && subclass.class_index == subclass_conds[subclass.class_index - 1].slot && subclass_conds[subclass.class_index - 1].lvl <= subclass.level
            if old_skill = pc.skills[skill.skill_id]?
              if old_skill.level == skill.skill_level - 1
                result << skill
              end
            elsif skill.skill_level == 1
              result << skill
            end
          end
        end
      end
    end

    result
  end

  def get_skill_learn(acq_type : AcquireSkillType, id : Int32, lvl : Int32, pc : L2PcInstance) : L2SkillLearn?
    case acq_type
    when AcquireSkillType::CLASS
      get_class_skill(id, lvl, pc.learning_class)
    when AcquireSkillType::TRANSFORM
      get_transform_skill(id, lvl)
    when AcquireSkillType::FISHING
      get_fishing_skill(id, lvl)
    when AcquireSkillType::PLEDGE
      get_pledge_skill(id, lvl)
    when AcquireSkillType::SUBPLEDGE
      get_subpledge_skill(id, lvl)
    when AcquireSkillType::TRANSFER
      get_transfer_skill(id, lvl, pc.class_id)
    when AcquireSkillType::SUBCLASS
      get_subclass_skill(id, lvl)
    when AcquireSkillType::COLLECT
      get_collect_skill(id, lvl)
    end
  end

  def get_transform_skill(id : Int32, lvl : Int32) : L2SkillLearn?
    TRANSFORM_SKILL_TREE[SkillData.get_skill_hash(id, lvl)]?
  end

  def get_class_skill(id : Int32, lvl : Int32, class_id : ClassId) : L2SkillLearn?
    get_complete_class_skill_tree(class_id)[SkillData.get_skill_hash(id, lvl)]?
  end

  {% for acq in %w(fishing pledge subpledge subclass common collect) %}
    def get_{{acq.id}}_skill(id : Int32, lvl : Int32) : L2SkillLearn?
      {{acq.upcase.id}}_SKILL_TREE[SkillData.get_skill_hash(id, lvl)]?
    end
  {% end %}

  def get_transfer_skill(id : Int32, lvl : Int32, class_id : ClassId) : L2SkillLearn?
    if parent = class_id.parent?
      if tree = TRANSFER_SKILL_TREES[parent]?
        tree[SkillData.get_skill_hash(id, lvl)]?
      end
    end
  end

  def get_fishing_skill(id : Int32, lvl : Int32) : L2SkillLearn?
    FISHING_SKILL_TREE[SkillData.get_skill_hash(id, lvl)]?
  end

  def get_min_level_for_new_skill(pc : L2PcInstance, tree : Hash(Int32, L2SkillLearn)) : Int32
    min = 0

    if tree.empty?
      warn { "Skill tree not defined for get_min_level_for_new_skill" }
    else
      tree.each_value do |s|
        if s.learned_by_npc? && pc.level < s.get_level
          if min == 0 || min > s.get_level
            min = s.get_level
          end
        end
      end
    end

    min
  end

  def hero_skill?(id : Int32, lvl : Int32) : Bool
    if HERO_SKILL_TREE.has_key?(SkillData.get_skill_hash(id, lvl))
      return true
    end

    HERO_SKILL_TREE.each_value do |skill|
      if skill.skill_id == id && lvl == -1
        return true
      end
    end

    false
  end

  def gm_skill?(id : Int32, lvl : Int32) : Bool
    if lvl <= 0
      GM_SKILL_TREE.each_value { |s| return true if s.skill_id == id }
      GM_AURA_SKILL_TREE.each_value { |s| return true if s.skill_id == id }

      false
    else
      hash = SkillData.get_skill_hash(id, lvl)
      GM_SKILL_TREE.has_key?(hash) || GM_AURA_SKILL_TREE.has_key?(hash)
    end
  end

  def clan_skill?(id : Int32, lvl : Int32) : Bool
    hash = SkillData.get_skill_hash(id, lvl)
    PLEDGE_SKILL_TREE.has_key?(hash) || SUBPLEDGE_SKILL_TREE.has_key?(hash)
  end

  def add_skills(gm : L2PcInstance, aura : Bool)
    tree = aura ? GM_AURA_SKILL_TREE : GM_SKILL_TREE
    tree.each_value do |sl|
      gm.add_skill(SkillData[sl.skill_id, sl.skill_level], false)
    end
  end

  def skill_allowed?(pc : L2PcInstance, skill : Skill) : Bool
    if skill.excluded_from_check?
      return true
    end

    if pc.gm? && skill.gm_skill?
      return true
    end

    if @@loading
      return true
    end


    max_lvl = SkillData.get_max_level(skill.id)
    hash = SkillData.get_skill_hash(skill.id, Math.min(skill.level, max_lvl))

    if SKILLS_BY_CLASS_ID_HASH_CODES[pc.class_id.to_i].bincludes?(hash)
      return true
    end

    if SKILLS_BY_RACE_HASH_CODES[pc.race.to_i].bincludes?(hash)
      return true
    end

    if ALL_SKILLS_HASH_CODES.bincludes?(hash)
      return true
    end

    lvl = Math.min(skill.level, max_lvl)
    if get_transfer_skill(skill.id, lvl, pc.class_id)
      return true
    end

    false
  end

  def get_available_residential_skills(id : Int32) : Enumerable(L2SkillLearn)
    PLEDGE_SKILL_TREE.local_each_value.select do |skill|
      skill.residencial_skill? && skill.residence_ids.includes?(id)
    end
  end

  private def report
    class_skill_tree_count = 0
    CLASS_SKILL_TREES.each_value { |tree| class_skill_tree_count += tree.size }

    transfer_skill_tree_count = 0
    TRANSFER_SKILL_TREES.each_value { |tree| transfer_skill_tree_count += tree.size }

    dw_fish_skill_tree_count = 0
    FISHING_SKILL_TREE.each_value do |skill|
      if skill.races.includes?(Race::DWARF)
        dw_fish_skill_tree_count += 1
      end
    end

    res_skill_count = 0
    PLEDGE_SKILL_TREE.each_value do |skill|
      if skill.residencial_skill?
        res_skill_count += 1
      end
    end

    info do
      "Loaded #{class_skill_tree_count} Class Skills for #{CLASS_SKILL_TREES.size} Class Skill Trees.\n" \
      "Loaded #{SUBCLASS_SKILL_TREE.size} Subclass Skills.\n" \
      "Loaded #{transfer_skill_tree_count} Transfer Skills for #{TRANSFER_SKILL_TREES.size} Transfer Skill Trees.\n" \
      "Loaded #{FISHING_SKILL_TREE.size} Fishing Skills, #{dw_fish_skill_tree_count} Dwarven only Fishing Skills.\n" \
      "Loaded #{COLLECT_SKILL_TREE.size} Collect Skills.\n" \
      "Loaded #{PLEDGE_SKILL_TREE.size} Pledge Skills, #{PLEDGE_SKILL_TREE.size - res_skill_count} for Pledge and #{res_skill_count} Residential.\n" \
      "Loaded #{SUBPLEDGE_SKILL_TREE.size} Subpledge Skills.\n" \
      "Loaded #{TRANSFORM_SKILL_TREE.size} Transform Skills.\n" \
      "Loaded #{NOBLE_SKILL_TREE.size} Noble Skills.\n" \
      "Loaded #{HERO_SKILL_TREE.size} Hero Skills.\n" \
      "Loaded #{GM_SKILL_TREE.size} GM Skills.\n" \
      "Loaded #{GM_AURA_SKILL_TREE.size} GM Aura Skills.\n" \
      "Loaded #{COMMON_SKILL_TREE.size} Common Skills to all classes."
    end
  end
end
