class Scripts::UrbanArea < AbstractInstance
  private class UrbanAreaWorld < InstanceWorld
    property active_amaskari_call : TaskExecutor::Scheduler::DelayedTask?
    property! spawned_amaskari : L2MonsterInstance?
    property? amaskari_dead = false
  end

  # NPCs
  private TOMBSTONE = 32343
  private KANAF = 32346
  private KEYMASTER = 22361
  private AMASKARI = 22449
  private DOWNTOWN_NATIVE = 32358
  private TOWN_GUARD = 22359
  private TOWN_PATROL = 22360
  # Items
  private KEY = 9714
  # Skills
  private STONE = SkillHolder.new(4616)
  # Locations
  private AMASKARI_SPAWN_POINT = Location.new(19424, 253360, -2032, 16860)
  private ENTRY_POINT = Location.new(14117, 255434, -2016)
  private EXIT_POINT = Location.new(16262, 283651, -9700)
  # Misc
  private MIN_LV = 78
  private TEMPLATE_ID = 2

  private NPC_STRING_ID = {
    NpcString::INVADER,
    NpcString::YOU_HAVE_DONE_WELL_IN_FINDING_ME_BUT_I_CANNOT_JUST_HAND_YOU_THE_KEY
  }

  private NATIVES_NPC_STRING_ID = {
    NpcString::THANK_YOU_FOR_SAVING_ME,
    NpcString::GUARDS_ARE_COMING_RUN,
    NpcString::NOW_I_CAN_ESCAPE_ON_MY_OWN
  }

  def initialize
    super(self.class.simple_name, "hellbound/Instances")

    add_first_talk_id(DOWNTOWN_NATIVE)
    add_start_npc(KANAF, DOWNTOWN_NATIVE)
    add_talk_id(KANAF, DOWNTOWN_NATIVE)
    add_attack_id(TOWN_GUARD, KEYMASTER)
    add_aggro_range_enter_id(TOWN_GUARD)
    add_kill_id(AMASKARI)
    add_spawn_id(DOWNTOWN_NATIVE, TOWN_GUARD, TOWN_PATROL, KEYMASTER)
  end

  def on_first_talk(npc, player)
    unless npc.affected_by_skill?(STONE.skill_id)
      return "32358-02.htm"
    end

    "32358-01.htm"
  end

  def on_talk(npc, pc)
    if npc.id == KANAF
      unless pc.override_instance_conditions?
        if HellboundEngine.instance.level < 10
          html = "32346-lvl.htm"
        end

        unless pc.in_party?
          html = "32346-party.htm"
        end
      end

      unless html
        enter_instance(pc, UrbanAreaWorld.new, "UrbanArea.xml", TEMPLATE_ID)
      end
    elsif npc.id == TOMBSTONE
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(UrbanAreaWorld)
        party = pc.party

        if party.nil?
          html = "32343-02.htm"
        elsif npc.busy?
          html = "32343-02c.htm"
        elsif pc.inventory.get_inventory_item_count(KEY, -1, false) >= 1
          party.members.each do |m|
            unless Util.in_range?(300, npc, m, true)
              return "32343-02b.htm"
            end
          end

          if pc.destroy_item_by_item_id("Quest", KEY, 1, npc, true)
            npc.busy = true
            # destroy instance after 5 min
            inst = InstanceManager.get_instance(world.instance_id).not_nil!
            inst.duration = 5 * 60000
            inst.empty_destroy_time = 0
            ThreadPoolManager.schedule_general(ExitInstance.new(self, party, world), 285000)
            html = "32343-02d.htm"
          end
        else
          html = "32343-02a.htm"
        end
      end
    end

    html
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(UrbanAreaWorld)
      if npc.id == DOWNTOWN_NATIVE
        if event.casecmp?("rebuff") && !world.amaskari_dead?
          STONE.skill.apply_effects(npc, npc)
        elsif event.casecmp?("break_chains")
          if !npc.affected_by_skill?(STONE.skill_id) || world.amaskari_dead?
            broadcast_npc_say(npc, Say2::NPC_ALL, NATIVES_NPC_STRING_ID[0])
            broadcast_npc_say(npc, Say2::NPC_ALL, NATIVES_NPC_STRING_ID[2])
          else
            cancel_quest_timer("rebuff", npc, nil)
            if npc.affected_by_skill?(STONE.skill_id)
              npc.stop_skill_effects(false, STONE.skill_id)
            end

            broadcast_npc_say(npc, Say2::NPC_ALL, NATIVES_NPC_STRING_ID[0])
            broadcast_npc_say(npc, Say2::NPC_ALL, NATIVES_NPC_STRING_ID[1])
            HellboundEngine.instance.update_trust(10, true)
            npc.schedule_despawn(3000)
            # Try to call Amaskari
            if world.spawned_amaskari? && !world.spawned_amaskari.dead?
              if Rnd.rand(1000) < 25
                if Util.in_range?(5000, npc, world.spawned_amaskari, false)
                  world.active_amaskari_call.try &.cancel
                  world.active_amaskari_call = ThreadPoolManager.schedule_general(CallAmaskari.new(npc), 25000)
                end
              end
            end
          end
        end
      end
    end

    super
  end

  def on_spawn(npc)
    if npc.id == DOWNTOWN_NATIVE
      npc.as(L2QuestGuardInstance).passive = true
      npc.as(L2QuestGuardInstance).auto_attackable = false
      STONE.skill.apply_effects(npc, npc)
      start_quest_timer("rebuff", 357000, npc, nil)
    elsif npc.id == TOWN_GUARD || npc.id == KEYMASTER
      npc.busy = false
      npc.busy_message = ""
    end

    super
  end

  def on_aggro_range_enter(npc, pc, is_summon)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(UrbanAreaWorld)
      unless npc.busy?
        broadcast_npc_say(npc, Say2::NPC_ALL, NPC_STRING_ID[0])
        npc.busy = true

        if world.spawned_amaskari? && !world.spawned_amaskari.dead?
          if Rnd.rand(1000) < 25
            if Util.in_range?(1000, npc, world.spawned_amaskari, false)
              world.active_amaskari_call.try &.cancel
              world.active_amaskari_call = ThreadPoolManager.schedule_general(CallAmaskari.new(npc), 25000)
            end
          end
        end
      end
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(UrbanAreaWorld)
      if !world.amaskari_dead? && !(npc.busy_message.casecmp?("atk") || npc.busy?)
        case npc.id
        when TOWN_GUARD
          msg_id = 0
          range = 1000
        when KEYMASTER
          msg_id = 1
          range = 5000
        else
          msg_id = -1
          range = 0
        end
        if msg_id >= 0
          broadcast_npc_say(npc, Say2::NPC_ALL, NPC_STRING_ID[msg_id], range)
        end
        npc.busy = true
        npc.busy_message = "atk"

        if world.spawned_amaskari? && !world.spawned_amaskari.dead?
          if Rnd.rand(1000) < 25
            if Util.in_range?(range, npc, world.spawned_amaskari, false)
              world.active_amaskari_call.try &.cancel
              world.active_amaskari_call = ThreadPoolManager.schedule_general(CallAmaskari.new(npc), 25000)
            end
          end
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(UrbanAreaWorld)
      world.amaskari_dead = true
    end

    super
  end

  private def check_conditions(pc)
    if pc.override_instance_conditions?
      return true
    end

    party = pc.party

    if party.nil? || !party.leader?(pc)
      pc.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return false
    end

    party.members.each do |m|
      if m.level < MIN_LV
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end

      unless Util.in_range?(1000, pc, m, true)
        sm = SystemMessage.c1_is_in_a_location_which_cannot_be_entered_therefore_it_cannot_be_processed
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end

      if InstanceManager.get_player_world(pc)
        sm = SystemMessage.you_have_entered_another_instant_zone_therefore_you_cannot_enter_corresponding_dungeon
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
    end

    true
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      party = pc.party
      if party.nil?
        teleport_player(pc, ENTRY_POINT, world.instance_id)
        world.add_allowed(pc.l2id)
      else
        party.members.each do |m|
          teleport_player(m, ENTRY_POINT, world.instance_id)
          world.add_allowed(m.l2id)
        end
      end
      world.as(UrbanAreaWorld).spawned_amaskari = add_spawn(AMASKARI, AMASKARI_SPAWN_POINT, false, 0, false, world.instance_id).as(L2MonsterInstance)
    else
      teleport_player(pc, ENTRY_POINT, world.instance_id)
    end
  end

  private struct CallAmaskari
    initializer caller : L2Npc

    def call
      if @caller.alive?
        world = InstanceManager.get_world(@caller.instance_id)
        if world.is_a?(UrbanAreaWorld)
          if world.spawned_amaskari? && !world.spawned_amaskari.dead?
            world.spawned_amaskari.tele_to_location(@caller.location)
            world.spawned_amaskari.broadcast_packet(NpcSay.new(world.spawned_amaskari.l2id, Say2::NPC_ALL, world.spawned_amaskari.id, NpcString::ILL_MAKE_YOU_FEEL_SUFFERING_LIKE_A_FLAME_THAT_IS_NEVER_EXTINGUISHED))
          end
        end
      end
    end
  end

  private struct ExitInstance
    initializer instance : UrbanArea, party : L2Party, world : UrbanAreaWorld

    def call
      @party.members.each do |m|
        if m.alive?
          @world.remove_allowed(m.l2id)
          @instance.teleport_player(m, EXIT_POINT, 0)
        end
      end
    end
  end
end
