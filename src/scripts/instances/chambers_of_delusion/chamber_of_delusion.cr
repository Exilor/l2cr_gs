abstract class ChamberOfDelusion < AbstractInstance
  private class CDWorld < InstanceWorld
    getter party_inside, chamber
    getter banish_task : TaskScheduler::PeriodicTask?
    property current_room : Int32

    def initialize(chamber : ChamberOfDelusion, party : L2Party)
      @chamber = chamber
      @current_room = 0
      @party_inside = party
      @banish_task = ThreadPoolManager.schedule_general_at_fixed_rate(BanishTask.new(self), 60000, 60000)
    end

    def schedule_room_change(boss_room)
      inst = InstanceManager.get_instance(@chamber.instance_id).not_nil!
      if boss_room
        next_interval = 60000
      else
        next_interval = (ROOM_CHANGE_INTERVAL + Rnd.rand(ROOM_CHANGE_RANDOM_TIME)) * 1000
      end

      # Schedule next room change only if remaining time is enough
      if inst.instance_end_time - Time.ms > next_interval
        @room_change_task = ThreadPoolManager.schedule_general(ChangeRoomTask.new(@chamber, self), next_interval - 5000)
      end
    end

    def stop_banish_task
      @banish_task.try &.cancel
    end

    def stop_room_change_task
      @room_change_task.try &.cancel
    end

    private struct BanishTask
      initializer world : CDWorld

      def call
        inst = InstanceManager.get_instance(@world.chamber.instance_id)

        if inst.nil? || inst.instance_end_time - Time.ms < 60000
          @world.banish_task.try &.cancel
        else
          inst.players.each do |l2id|
            pl = L2World.get_player(l2id)
            if pl && pl.online?
              if !pl.in_party? || @world.party_inside != pl.party
                @world.chamber.exit_instance(pl)
              end
            end
          end
        end
      end
    end

    private struct ChangeRoomTask
      initializer chamber : ChamberOfDelusion, world : CDWorld

      def call
        @chamber.earthquake(@world)
        task = ChangeRoomTask2.new(@chamber, @world)
        ThreadPoolManager.schedule_general(task, 5000)
      end
    end

    private struct ChangeRoomTask2
      initializer chamber : ChamberOfDelusion, world : CDWorld

      def call
        @chamber.change_room(@world)
      end
    end
  end

  # Items
  private ENRIA = 4042
  private ASOFE = 4043
  private THONS = 4044
  private LEONARD = 9628
  private DELUSION_MARK = 15311

  # Skills
  private SUCCESS_SKILL = SkillHolder.new(5758)
  private FAIL_SKILL = SkillHolder.new(5376, 4)

  private ROOM_CHANGE_INTERVAL = 480 # 8 min
  private ROOM_CHANGE_RANDOM_TIME = 120 # 2 min

  # Instance restart time
  private RESET_HOUR = 6
  private RESET_MIN = 30

  @room_enter_points = [] of Location
  @return : String

  getter instance_id

  def initialize(name : String, description : String, instance_id : Int32, instance_template_name : String, entrance_gk_id : Int32, room_gk_first_id : Int32, room_gk_last_id : Int32, aenkinel_id : Int32, box_id : Int32)
    super(name, description)

    @instance_id = instance_id
    @instance_template = instance_template_name
    @entrance_gatekeeper = entrance_gk_id
    @room_gatekeeper_first = room_gk_first_id
    @room_gatekeeper_last = room_gk_last_id
    @aenkinel = aenkinel_id
    @box = box_id
    @return = self.class.simple_name + "_return"

    add_start_npc(@entrance_gatekeeper)
    add_talk_id(@entrance_gatekeeper)
    @room_gatekeeper_first.upto(@room_gatekeeper_last) do |i|
      add_start_npc(i)
      add_talk_id(i)
    end
    add_kill_id(@aenkinel)
    add_attack_id(@box)
    add_spell_finished_id(@box)
    add_event_received_id(@box)
  end

  private def is_big_chamber
    @instance_id == 131 || @instance_id == 132
  end

  private def is_boss_room(world)
    world.current_room == @room_enter_points.size - 1
  end

  private def check_conditions(pc)
    unless party = pc.party
      pc.send_packet(SystemMessageId::NOT_IN_PARTY_CANT_ENTER)
      return false
    end

    if party.leader != pc
      pc.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return false
    end

    party.members.each do |m|
      if m.level < 80
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

      if is_big_chamber
        reentertime = InstanceManager.get_instance_time(m.l2id, @instance_id)

        if Time.ms < reentertime
          sm = SystemMessage.c1_may_not_re_enter_yet
          sm.add_pc_name(m)
          party.broadcast_packet(sm)
          return false
        end
      end
    end

    true
  end

  private def mark_restriction(world)
    if world.is_a?(CDWorld)
      reenter = Calendar.new
      reenter.minute = RESET_MIN
      reenter.hour = RESET_HOUR
      if reenter.before?(Time.local)
        reenter.add(:DAY, 1)
      end
      sm = SystemMessage.instant_zone_from_here_s1_s_entry_has_been_restricted
      sm.add_string(InstanceManager.get_instance_id_name(world.template_id))
      # set instance reenter time for all allowed players
      world.allowed.each do |l2id|
        pc = L2World.get_player(l2id)
        if pc && pc.online?
          InstanceManager.set_instance_time(l2id, world.template_id, reenter.ms)
          pc.send_packet(sm)
        end
      end
    end
  end

  def change_room(world)
    return unless party = world.party_inside
    return unless inst = InstanceManager.get_instance(world.instance_id)

    new_room = world.current_room

    # Do nothing, if there are raid room of Sqare or Tower Chamber
    if is_big_chamber && is_boss_room(world)
      return

    # Teleport to raid room 10 min or lesser before instance end time for Tower and Square Chambers
    elsif is_big_chamber && inst.instance_end_time - Time.ms < 600000
      new_room = @room_enter_points.size - 1

    # 10% chance for teleport to raid room if not here already for Northern, Southern, Western and Eastern Chambers
    elsif !is_big_chamber && !is_boss_room(world) && Rnd.rand(100) < 10
      new_room = @room_enter_points.size - 1
    else
      while new_room == world.current_room # otherwise teleport to another room, except current
        new_room = Rnd.rand(@room_enter_points.size - 1)
      end
    end

    party.members.each do |m|
      if world.instance_id == m.instance_id
        m.intention = AI::IDLE
        teleport_player(m, @room_enter_points[new_room], world.instance_id)
      end
    end

    world.current_room = new_room

    # Do not schedule room change for Square and Tower Chambers, if raid room is reached
    if is_big_chamber && is_boss_room(world)
      inst.duration = (inst.instance_end_time - Time.ms) + 1200000 # Add 20 min to instance time if raid room is reached

      inst.npcs.each do |npc|
        if npc.id == @room_gatekeeper_last
          npc_str = NpcString::N21_MINUTES_ARE_ADDED_TO_THE_REMAINING_TIME_IN_THE_INSTANT_ZONE
          say = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, npc_str)
          npc.broadcast_packet(say)
        end
      end
    else
      world.schedule_room_change(false)
    end
  end

  private def enter(world)
    unless party = world.party_inside
      return
    end

    party.members.each do |m|
      if has_quest_items?(m, DELUSION_MARK)
        take_items(m, DELUSION_MARK, -1)
      end

      if party.leader?(m)
        give_items(m, DELUSION_MARK, 1)
      end

      # Save location for teleport back into main hall
      m.variables[@return] = m.xyz.join(';')

      m.instance_id = world.instance_id
      world.add_allowed(m.l2id)
    end

    change_room(world)
  end

  def earthquake(world)
    unless party = world.party_inside
      return
    end

    party.members.each do |m|
      if world.instance_id == m.instance_id
        m.send_packet(Earthquake.new(m.x, m.y, m.z, 20, 10))
      end
    end
  end

  def on_enter_instance(pc, world, first_entrance)
    world = world.as(CDWorld)
    if first_entrance
      enter(world)
    else
      teleport_player(pc, @room_enter_points[world.current_room], world.instance_id)
    end
  end

  def exit_instance(pc)
    if pc.nil? || !pc.online? || pc.instance_id == 0
      return
    end
    inst = InstanceManager.get_instance(pc.instance_id).not_nil!
    ret = inst.exit_loc.not_nil!
    return_point = pc.variables.get_string(@return, nil)
    if return_point
      coords = return_point.split(';')
      if coords.size == 3
        begin
          x = coords[0].to_i
          y = coords[1].to_i
          z = coords[2].to_i
          ret.location = Location.new(x, y, z)
        rescue e
          warn e
        end
      end
    end

    teleport_player(pc, ret, 0)
    if world = InstanceManager.get_player_world(pc)
      world.remove_allowed(pc.l2id)
    end
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    world = InstanceManager.get_world(npc.instance_id)

    if pc && world.is_a?(CDWorld) && npc.id.between?(@room_gatekeeper_first, @room_gatekeeper_last)
      party = pc.party
      # Change room from dialog
      if event == "next_room"
        if party.nil?
          html = get_htm(pc, "data/scripts/instances/ChambersOfDelusion/no_party.html")
        elsif party.leader_l2id != pc.l2id
          html = get_htm(pc, "data/scripts/instances/ChambersOfDelusion/no_leader.html")
        elsif has_quest_items?(pc, DELUSION_MARK)
          take_items(pc, DELUSION_MARK, 1)
          world.stop_room_change_task
          change_room(world)
        else
          html = get_htm(pc, "data/scripts/instances/ChambersOfDelusion/no_item.html")
        end
      elsif event == "go_out"
        if party.nil?
          html = get_htm(pc, "data/scripts/instances/ChambersOfDelusion/no_party.html")
        elsif party.leader_l2id != pc.l2id
          html = get_htm(pc, "data/scripts/instances/ChambersOfDelusion/no_leader.html")
        else
          inst = InstanceManager.get_instance(world.instance_id).not_nil!

          world.stop_room_change_task
          world.stop_banish_task

          party.members.each do |m|
            exit_instance(m)
          end

          inst.empty_destroy_time = 0
        end
      elsif event == "look_party"
        if party && party == world.party_inside
          teleport_player(pc, @room_enter_points[world.current_room], world.instance_id, false)
        end
      end
    end

    html || ""
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    if !npc.busy? && npc.current_hp < npc.max_hp / 10
      npc.busy = true
      if Rnd.rand(100) < 25 # 25% chance to reward
        if Rnd.rand(100) < 33
          npc.drop_item(attacker, ENRIA, (3 * Config.rate_quest_drop).to_i64)
        end
        if Rnd.bool
          npc.drop_item(attacker, THONS, (4 * Config.rate_quest_drop).to_i64)
        end
        if Rnd.bool
          npc.drop_item(attacker, ASOFE, (4 * Config.rate_quest_drop).to_i64)
        end
        if Rnd.rand(100) < 16
          npc.drop_item(attacker, LEONARD, (2 * Config.rate_quest_drop).to_i64)
        end

        npc.broadcast_event("SCE_LUCKY", 2000, nil)
        npc.do_cast(SUCCESS_SKILL)
      else
        npc.broadcast_event("SCE_DREAM_FIRE_IN_THE_HOLE", 2000, nil)
      end
    end

    super
  end

  def on_event_received(event_name, sender, receiver, reference)
    case event_name
    when "SCE_LUCKY"
      receiver.busy = true
      receiver.do_cast(SUCCESS_SKILL)
    when "SCE_DREAM_FIRE_IN_THE_HOLE"
      receiver.busy = true
      receiver.do_cast(FAIL_SKILL)
    end


    nil
  end

  def on_kill(npc, pc, is_summon)
    world = InstanceManager.get_player_world(pc)
    if world.is_a?(CDWorld)
      inst = InstanceManager.get_instance(world.instance_id).not_nil!

      if is_big_chamber
        mark_restriction(world) # Set reenter restriction
        if inst.instance_end_time - Time.ms > 300000
          inst.duration = 300000 # Finish instance in 5 minutes
        end
      else
        world.stop_room_change_task
        world.schedule_room_change(true)
      end

      inst.spawn_group("boxes")
    end

    super
  end

  def on_spell_finished(npc, pc, skill)
    if npc.id == @box && (skill.id == 5376 || skill.id == 5758) && npc.alive?
      npc.do_die(pc)
    end

    super
  end

  def on_talk(npc, pc)
    get_quest_state(pc, false) || new_quest_state(pc)

    if npc.id == @entrance_gatekeeper
      if check_conditions(pc)
        party = pc.party.not_nil!
        enter_instance(pc, CDWorld.new(self, party), @instance_template, @instance_id)
      end
    end

    ""
  end
end
