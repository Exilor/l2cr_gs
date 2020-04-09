abstract class AbstractInstance < AbstractNpcAI
  def initialize(name : String, desc : String)
    super
  end

  def initialize(name : String)
    super(name, "instances")
  end

  def enter_instance(pc : L2PcInstance, instance : InstanceWorld, template : String, template_id : Int32)
    if world = InstanceManager.get_player_world(pc)
      if world.template_id == template_id
        on_enter_instance(pc, world, false)
        inst = InstanceManager.get_instance(world.instance_id).not_nil!
        if inst.remove_buff_enabled?
          handle_remove_buffs(pc, world)
        end
        return
      end
      pc.send_packet(SystemMessageId::YOU_HAVE_ENTERED_ANOTHER_INSTANT_ZONE_THEREFORE_YOU_CANNOT_ENTER_CORRESPONDING_DUNGEON)
      return
    end

    if check_conditions(pc, template_id)
      instance.instance_id = InstanceManager.create_dynamic_instance(template)
      instance.template_id = template_id
      instance.status = 0
      InstanceManager.add_world(instance)
      on_enter_instance(pc, instance, true)
      inst = InstanceManager.get_instance(instance.instance_id).not_nil!
      if inst.reenter_type.on_instance_enter?
        handle_reenter_time(instance)
      end
      if inst.remove_buff_enabled?
        handle_remove_buffs(instance)
      end

      if Config.debug_instances
        debug "Instance #{inst.name} #{instance.template_id} has been created by #{pc.name}."
      end
    end
  end

  def finish_instance(world : InstanceWorld)
    finish_instance(world, Config.instance_finish_time)
  end

  def finish_instance(world : InstanceWorld, duration : Int32)
    inst = InstanceManager.get_instance(world.instance_id).not_nil!

    if inst.reenter_type.on_instance_finish?
      handle_reenter_time(world)
    end

    if duration == 0
      InstanceManager.destroy_instance(inst.id)
    elsif duration > 0
      inst.duration = duration
      inst.empty_destroy_time = 0
    end
  end

  def handle_reenter_time(world : InstanceWorld)
    inst = InstanceManager.get_instance(world.instance_id).not_nil!
    reenter_data = inst.reenter_data

    time = -1i64

    reenter_data.each do |data|
      if data.time > 0
        time = Time.ms + data.time
        break
      end

      calendar = Calendar.new
      # calendar.am_pm = data.hour >= 12 ? 1 : 0 # TODO
      calendar.hour = data.hour
      calendar.minute = data.minute
      calendar.second = 0

      if calendar.ms <= Time.ms
        calendar.add(1.day)
      end
      if day = data.day
        while calendar.day_of_week != day.to_i
          calendar.add(1.day)
        end
      end

      if time == -1 || calendar.ms < time
        time = calendar.ms
      end
    end

    if time > 0
      set_reenter_time(world, time)
    end
  end

  private def handle_remove_buffs(world : InstanceWorld)
    world.allowed.each do |l2id|
      if pc = L2World.get_player(l2id)
        handle_remove_buffs(pc, world)
      end
    end
  end

  private def handle_remove_buffs(pc : L2PcInstance, world : InstanceWorld)
    inst = InstanceManager.get_instance(world.instance_id).not_nil!
    case inst.remove_buff_type
    when InstanceRemoveBuffType::ALL
      pc.stop_all_effects_except_those_that_last_through_death
      if summon = pc.summon
        summon.stop_all_effects_except_those_that_last_through_death
      end
    when InstanceRemoveBuffType::WHITELIST
      pc.effect_list.buffs.safe_each do |info|
        unless inst.buff_exception_list.includes?(info.skill.id)
          info.effected.effect_list.stop_skill_effects(true, info.skill)
        end
      end
      if summon = pc.summon
        summon.effect_list.buffs.safe_each do |info|
          unless inst.buff_exception_list.includes?(info.skill.id)
            info.effected.effect_list.stop_skill_effects(true, info.skill)
          end
        end
      end
    when InstanceRemoveBuffType::BLACKLIST
      pc.effect_list.buffs.safe_each do |info|
        if inst.buff_exception_list.includes?(info.skill.id)
          info.effected.effect_list.stop_skill_effects(true, info.skill)
        end
      end

      if summon = pc.summon
        summon.effect_list.buffs.safe_each do |info|
          if inst.buff_exception_list.includes?(info.skill.id)
            info.effected.effect_list.stop_skill_effects(true, info.skill)
          end
        end
      end
    else
      # [automatically added else]
    end

  end

  abstract def on_enter_instance(pc : L2PcInstance, world : InstanceWorld, first_entrance : Bool)

  private def check_conditions(pc : L2PcInstance, template_id : Int32) : Bool
    check_conditions(pc)
  end

  private def check_conditions(pc : L2PcInstance) : Bool
    true
  end

  private def spawn_group(group_name : String, instance_id : Int32) : Array(L2Npc)
    InstanceManager.get_instance(instance_id).not_nil!.spawn_group(group_name).not_nil!
  end

  private def set_reenter_time(world : InstanceWorld, time : Int64)
    world.allowed.each do |l2id|
      InstanceManager.set_instance_time(l2id, world.template_id, time)
      pc = L2World.get_player(l2id)
      if pc && pc.online?
        sm = SystemMessage.instant_zone_from_here_s1_s_entry_has_been_restricted
        inst = InstanceManager.get_instance(world.instance_id).not_nil!
        sm.add_string(inst.name)
        pc.send_packet(sm)
      end
    end

    if Config.debug_instances
      debug "Time restrictions have been set for player in instance id: #{world.instance_id} (#{Time.from_ms(time)})."
    end
  end
end
