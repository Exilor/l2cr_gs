class DimensionalRift
  include Loggable

  private SECONDS_5 = 5000i64

  @completed_rooms = [] of Int8
  @jumps_current = 0i8
  @earthquake_task : Concurrent::DelayedTask?
  @boss_room = false
  @has_jumped = false
  @dead_players = [] of L2PcInstance
  @revived_in_waiting_room = [] of L2PcInstance
  getter type, current_room
  property teleport_timer : TaskGroup?
  property teleport_timer_task : Concurrent::DelayedTask?
  property spawn_timer : TaskGroup?
  property spawn_timer_task : Concurrent::DelayedTask?

  def initialize(@party : L2Party, @type : Int8, room : Int8)
    @current_room = room
    coords = get_room_coord(room)
    party.dimensional_rift = self

    unless rift_quest = QuestManager.get_quest(635)
      warn "Rift quest (Q00635_IntoTheDimensionalRift) not found."
    end

    party.members.each do |m|
      if rift_quest
        qs = m.get_quest_state(rift_quest.name)
        unless qs
          qs = rift_quest.new_quest_state(m)
        end
        unless qs.started?
          qs.start_quest
        end
      end

      m.tele_to_location(coords)
    end

    create_spawn_timer(room)
    create_teleporter_timer(true)
  end

  protected def create_teleporter_timer(reason : Bool)
    if temp = @teleport_timer_task
      temp.cancel
      @teleport_timer_task = nil
    end

    if temp = @teleport_timer
      temp.cancel
      @teleport_timer = nil
    end

    if temp = @earthquake_task
      temp.cancel
      @earthquake_task = nil
    end

    teleport_timer = TaskGroup.new
    teleport_timer_task = -> do
      if @current_room > -1
        DimensionalRiftManager.get_room(@type, @current_room)
        .unspawn.party_inside = false
      end

      if reason && @jumps_current < max_jumps && @party.size > @dead_players.size
        @jumps_current += 1
        @completed_rooms << @current_room
        @current_room = -1i8
        @party.each do |m|
          unless @revived_in_waiting_room.includes?(m)
            teleport_to_next_room(m)
          end
        end
        create_teleporter_timer(true)
        create_spawn_timer(@current_room)
      else
        @party.each do |m|
          unless @revived_in_waiting_room.includes?(m)
            teleport_to_waiting_room(m)
          end
        end
        kill_rift
        teleport_timer_task().try &.cancel
      end
    end

    @teleport_timer = teleport_timer

    if reason
      jump_time = calc_time_to_next_jump
      @teleport_timer_task = teleport_timer.schedule(teleport_timer_task, jump_time)

      quake = -> do
        @party.each do |m|
          unless @revived_in_waiting_room.includes?(m)
            packet = Packets::Outgoing::Earthquake.new(*m.xyz, 65, 9)
            m.send_packet(packet)
          end
        end
      end
      @earthquake_task = ThreadPoolManager.schedule_general(quake, jump_time - 7000)
    else
      @teleport_timer_task = teleport_timer.schedule(teleport_timer_task, SECONDS_5)
    end
  end

  def create_spawn_timer(room : Int8)
    if temp = @spawn_timer_task
      temp.cancel
      @spawn_timer_task = nil
    end

    if temp = @spawn_timer
      temp.cancel
      @spawn_timer = nil
    end

    spawn_timer = TaskGroup.new
    spawn_timer_task = -> do
      DimensionalRiftManager.get_room(@type, room).spawn
    end
    @spawn_timer_task = spawn_timer.schedule(spawn_timer_task, Config.rift_spawn_delay)
    @spawn_timer = spawn_timer
  end

  def party_member_invited
    create_teleporter_timer(false)
  end

  def party_member_exited(pc : L2PcInstance)
    @dead_players.delete(pc)
    @revived_in_waiting_room.delete(pc)

    if @party.size < Config.rift_min_party_size || @party.size == 1
      @party.each { |m| teleport_to_waiting_room(m) }
      kill_rift
    end
  end

  def manual_teleport(pc : L2PcInstance, npc : L2Npc)
    if !pc.in_party? || !pc.party.in_dimensional_rift?
      return
    end

    if pc.l2id != pc.party.leader_l2id
      DimensionalRiftManager.show_html_file(pc, "data/html/seven_signs/rift/NotPartyLeader.htm", npc)
      return
    end

    if @has_jumped
      DimensionalRiftManager.show_html_file(pc, "data/html/seven_signs/rift/AlreadyTeleported.htm", npc)
      return
    end

    @has_jumped = true
    DimensionalRiftManager.get_room(@type, @current_room)
    .unspawn.party_inside = false
    @completed_rooms << @current_room
    @current_room = -1i8

    @party.each { |m| teleport_to_next_room(m) }

    DimensionalRiftManager.get_room(@type, @current_room)
    .party_inside = true

    create_spawn_timer(@current_room)
    create_teleporter_timer(true)
  end

  def manual_exit_rift(pc : L2PcInstance, npc : L2Npc)
    if !pc.in_party? || !pc.party.in_dimensional_rift?
      return
    end

    if pc.l2id != pc.party.leader_l2id
      DimensionalRiftManager.show_html_file(pc, "data/html/seven_signs/rift/NotPartyLeader.htm", npc)
      return
    end

    @party.each { |m| teleport_to_waiting_room(m) }

    kill_rift
  end

  protected def teleport_to_next_room(pc : L2PcInstance)
    if @current_room == -1
      empty_rooms = DimensionalRiftManager.get_free_rooms(@type)
      empty_rooms -= @completed_rooms
      if empty_rooms.empty?
        empty_rooms = DimensionalRiftManager.get_free_rooms(@type)
      end
      @current_room = empty_rooms.sample(random: Rnd)
    end

    DimensionalRiftManager.get_room(@type, @current_room).party_inside = true
    check_boss_room(@current_room)
    pc.tele_to_location(get_room_coord(@current_room))
  end

  protected def teleport_to_waiting_room(pc : L2PcInstance)
    DimensionalRiftManager.teleport_to_waiting_room(pc)
    if quest = QuestManager.get_quest(635)
      if qs = pc.get_quest_state(quest.name)
        if qs.cond?(1)
          qs.exit_quest(true, true)
        end
      end
    end
  end

  def kill_rift
    @completed_rooms.clear
    @party.dimensional_rift = nil
    # @party = nil
    @revived_in_waiting_room.clear
    @dead_players.clear

    if task = @earthquake_task
      task.cancel
      @earthquake_task = nil
    end

    DimensionalRiftManager.get_room(@type, @current_room)
    .unspawn.party_inside = false
    DimensionalRiftManager.kill_rift(self)
  end

  private def calc_time_to_next_jump : Int64
    min = Config.rift_auto_jumps_time_min.to_i64
    max = Config.rift_auto_jumps_time_max.to_i64
    time = Rnd.rand(min..max) * 1000

    if @boss_room
      return (time * Config.rift_boss_room_time_multiply).to_i64
    end

    time
  end

  def member_dead(pc : L2PcInstance)
    unless @dead_players.includes?(pc)
      @dead_players << pc
    end
  end

  def member_resurrected(pc : L2PcInstance)
    @dead_players.delete(pc)
  end

  def used_teleport(pc : L2PcInstance)
    unless @revived_in_waiting_room.includes?(pc)
      @revived_in_waiting_room << pc
    end

    unless @dead_players.includes?(pc)
      @dead_players << pc
    end

    if @party.size - @revived_in_waiting_room.size < Config.rift_min_party_size
      @party.each do |m|
        unless @revived_in_waiting_room.includes?(m)
          teleport_to_waiting_room(m)
        end
      end

      kill_rift
    end
  end

  def dead_member_list : Array(L2PcInstance)
    @dead_players
  end

  def revived_at_waiting_room : Array(L2PcInstance)
    @revived_in_waiting_room
  end

  def check_boss_room(room : Int8)
    @boss_room = DimensionalRiftManager.get_room(@type, room).boss_room?
  end

  def get_room_coord(room : Int8) : Location
    DimensionalRiftManager.get_room(@type, room).teleport_coordinates
  end

  def max_jumps : Int8
    if Config.rift_max_jumps <= 8 && Config.rift_max_jumps >= 1
      return Config.rift_max_jumps.to_i8
    end

    4i8
  end

  private struct TaskGroup # L2J: java.util.Timer
    @tasks = [] of Concurrent::ScheduledTask

    def schedule(job, delay)
      task = ThreadPoolManager.schedule_general(job, delay)
      @tasks << task
      task
    end

    def schedule(job, delay, interval)
      task = ThreadPoolManager.schedule_general_at_fixed_rate(job, delay, interval)
      @tasks << task
      task
    end

    def cancel
      @tasks.each &.cancel
      @tasks.clear
    end
  end
end
