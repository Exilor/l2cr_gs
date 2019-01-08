require "./transform_type"

class Transform
  # include Identifiable

  getter id : Int32
  getter display_id : Int32
  getter type : TransformType
  getter spawn_height : Int32
  getter name : String?
  getter title : String?
  getter? can_swim : Bool
  getter? can_attack : Bool
  @male_template : TransformTemplate?
  @female_template : TransformTemplate?

  def initialize(set : StatsSet)
    @id = set.get_i32("id")
    @display_id = set.get_i32("displayId", @id)
    @type = set.get_enum("type", TransformType, TransformType::COMBAT)
    @can_swim = set.get_i32("can_swim", 0) == 1
    @can_attack = set.get_i32("normal_attackable", 1) == 1
    @spawn_height = set.get_i32("spawn_height", 0)
    @name = set.get_string("setName", nil)
    @title = set.get_string("setTitle", nil)
  end

  def get_template(pc : L2PcInstance) : TransformTemplate?
    pc.appearance.sex ? @female_template : @male_template
  end

  def set_template(male : Bool, template : TransformTemplate)
    if male
      @male_template = template
    else
      @female_template = template
    end
  end

  def stance? : Bool
    @type.mode_change?
  end

  def riding? : Bool
    @type.riding_mode?
  end

  def pure_stats? : Bool
    @type.pure_stat?
  end

  def combat? : Bool
    @type.combat?
  end

  def non_combat? : Bool
    @type.non_combat?
  end

  def flying? : Bool
    @type.flying?
  end

  def cursed? : Bool
    @type.cursed?
  end

  def get_collision_height(pc : L2PcInstance) : Float64
    get_template(pc).try &.collision_height || pc.collision_height
  end

  def get_collision_radius(pc : L2PcInstance) : Float64
    get_template(pc).try &.collision_radius || pc.collision_radius
  end

  def get_base_attack_range(pc : L2PcInstance) : Int32
    get_template(pc).try &.base_attack_range || pc.template.base_attack_range
  end

  def on_transform(pc : L2PcInstance)
    return unless template = get_template(pc)
    pc.flying = true if flying?

    if name = @name
      pc.appearance.visible_name = name
    end

    if title = @title
      pc.appearance.visible_title = title
    end

    unless template.additional_items.empty?
      allowed = [] of Int32
      not_allowed = [] of Int32

      template.additional_items.each do |holder|
        if holder.allowed_to_use?
          allowed << holder.id
        else
          not_allowed << holder.id
        end
      end

      unless allowed.empty?
        pc.inventory.set_inventory_block(allowed, 1)
      end

      unless not_allowed.empty?
        pc.inventory.set_inventory_block(not_allowed, 2)
      end
    end

    if list = template.basic_action_list
      pc.send_packet(list)
    end
  end

  def on_untransform(pc : L2PcInstance)
    return unless template = get_template(pc)

    pc.flying = false if flying?

    if @name
      pc.appearance.visible_name = nil
    end

    if @title
      pc.appearance.visible_title = nil
    end

    template.skills.each do |holder|
      if skill = holder.skill
        unless SkillTreesData.skill_allowed?(pc, skill)
          pc.remove_skill(skill, false, skill.passive?)
        end
      end
    end

    template.additional_skills.each do |holder|
      if skill = holder.skill
        if pc.level >= holder.min_level && !SkillTreesData.skill_allowed?(pc, skill)
          pc.remove_skill(skill, false, skill.passive?)
        end
      end
    end

    pc.remove_all_transform_skills

    unless template.additional_items.empty?
      pc.inventory.unblock
    end

    pc.send_packet(Packets::Outgoing::ExBasicActionList::DEFAULT_LIST)
  end

  def on_level_up(pc : L2PcInstance)
    if template = get_template(pc)
      template.additional_skills.each do |holder|
        if pc.level >= holder.min_level
          if pc.get_skill_level(holder.skill_id) < holder.skill_lvl
            pc.add_skill(holder.skill, false)
            pc.add_transform_skill(holder.skill)
          end
        end
      end
    end
  end

  def get_stat(pc : L2PcInstance, stats : Stats) : Float64
    val = 0.0
    if template = get_template(pc)
      val = template.get_stats(stats)
      if data = template.get_data(pc.level)
        val = data.get_stats(stats)
      end
    end
    val
  end

  def get_base_def_by_slot(pc : L2PcInstance, slot : Int32)
    if template = get_template(pc)
      template.get_defense(slot)
    else
      pc.template.get_base_def_by_slot(slot)
    end
  end

  def get_level_mod(pc : L2PcInstance) : Float64
    if template = get_template(pc)
      if data = template.get_data(pc.level)
        return data.level_mod
      end
    end

    -1.0
  end
end
