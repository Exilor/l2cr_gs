require "../l2_character"
require "../ai/l2_door_ai"
require "../known_list/door_known_list"
require "../stat/door_stat"
require "../status/door_status"

class L2DoorInstance < L2Character
  OPEN_BY_CLICK = 1
  OPEN_BY_TIME  = 2
  OPEN_BY_ITEM  = 4
  OPEN_BY_SKILL = 8
  OPEN_BY_CYCLE = 16

  @castle_index = -2
  @fort_index = -2
  @auto_close_task : TaskScheduler::DelayedTask?

  getter? open : Bool
  getter? targetable : Bool
  property mesh_index : Int32 = 1
  property! clan_hall : ClanHall?
  property? attackable_door : Bool

  def initialize(template : L2DoorTemplate)
    super

    @open = template.open_by_default?
    @attackable_door = template.attackable?
    @targetable = template.targetable?

    if name = group_name
      DoorData.add_door_group(name, id)
    end

    if openable_by_time?
      start_timer_open
    end

    clan_hall_id = template.clan_hall_id
    if clan_hall_id > 0
      if hall = ClanHallManager.all_clan_halls[clan_hall_id]?
        self.clan_hall = hall
        hall.doors << self
      end
    end

    self.invul = false
    self.lethalable = false
  end

  def closed? : Bool
    !open?
  end

  def instance_type : InstanceType
    InstanceType::L2DoorInstance
  end

  def template : L2DoorTemplate
    super.as(L2DoorTemplate)
  end

  private def init_ai : L2CharacterAI
    L2DoorAI.new(self)
  end

  private def init_known_list
    @known_list = DoorKnownList.new(self)
  end

  private def init_char_stat
    @stat = DoorStat.new(self)
  end

  def stat : DoorStat
    super.as(DoorStat)
  end

  private def init_char_status
    @status = DoorStatus.new(self)
  end

  def status : DoorStatus
    super.as(DoorStatus)
  end

  def group_name : String?
    template.group_name
  end

  def id : Int32
    template.id
  end

  def level : Int32
    template.level
  end

  def emitter : Int32
    template.emitter
  end

  def wall? : Bool
    template.wall?
  end

  def child_id : Int32
    template.child_door_id
  end

  def show_hp? : Bool
    template.show_hp?
  end

  def open=(@open : Bool)
    if child_id > 0
      if sibling = get_sibling_door(child_id)
        sibling.notify_child_event(@open)
      else
        warn { "Cannot find sibling door with id #{child_id}." }
      end
    end
  end

  def door? : Bool
    true
  end

  private def start_timer_open
    delay = @open ? template.open_time : template.close_time
    if template.random_time > 0
      delay += Rnd.rand(template.random_time)
    end

    ThreadPoolManager.schedule_general(TimerOpen.new(self), delay * 1000)
  end

  def openable_by_skill? : Bool
    template.open_type & OPEN_BY_SKILL == OPEN_BY_SKILL
  end

  def openable_by_item? : Bool
    template.open_type & OPEN_BY_ITEM == OPEN_BY_ITEM
  end

  def openable_by_click? : Bool
    template.open_type & OPEN_BY_CLICK == OPEN_BY_CLICK
  end

  def openable_by_time? : Bool
    template.open_type & OPEN_BY_TIME == OPEN_BY_TIME
  end

  def openable_by_cycle? : Bool
    template.open_type & OPEN_BY_CYCLE == OPEN_BY_CYCLE
  end

  def damage : Int32
    dmg = 6 - ((current_hp / max_hp) * 6).ceil.to_i
    dmg.clamp(0, 6)
  end

  def enemy? : Bool
    return false unless show_hp?

    castle = castle?
    fort = fort?
    hall = clan_hall?

    case
    when castle && castle.residence_id > 0 && castle.zone.active? && show_hp?
      return true
    when fort && fort.residence_id > 0 && fort.zone.active? && show_hp?
      return true
    when hall && hall.siegable_hall? && hall.as(SiegableHall).siege_zone.active? && show_hp?
      return true
    end

    false
  end

  def auto_attackable?(attacker : L2Character) : Bool
    unless pc = attacker.acting_player
      return false
    end

    if attackable_door?
      return true
    end

    unless show_hp?
      return false
    end

    if hall = clan_hall?.as?(SiegableHall)
      unless hall.siegable_hall?
        return false
      end

      return hall.in_siege? && hall.siege.door_is_auto_attackable? && hall.siege.attacker?(pc.clan)
    end

    castle = castle?
    fort = fort?

    is_castle = !!castle && castle.residence_id > 0 && castle.zone.active?
    is_fort = !!fort && fort.residence_id > 0 && fort.zone.active?
    active_siege_id = fort ? fort.residence_id : castle ? castle.residence_id : 0

    if TerritoryWarManager.tw_in_progress?
      return !TerritoryWarManager.ally_field?(pc, active_siege_id)
    elsif fort && is_fort
      if clan = pc.clan
        if clan == fort.owner_clan?
          return false
        end
      end
    elsif castle && is_castle
      if clan = pc.clan
        if clan.id == castle.owner_id
          return false
        end
      end
    end

    is_castle || is_fort
  end

  def broadcast_status_update
    return unless known_list.knows_players?
    known_players = known_list.known_players
    return if known_players.empty?

    su = StaticObject.new(self, false)
    tsu = StaticObject.new(self, true)
    dsu = DoorStatusUpdate.new(self)

    if emitter > 0
      oe = OnEventTrigger.new(self, open?)
    end

    castle, fort = castle?, fort?

    known_players.each_value do |pc|
      next unless visible_for?(pc)

      if pc.gm? || (castle && castle.residence_id > 0) || (fort && fort.residence_id > 0)
        pc.send_packet(tsu)
      else
        pc.send_packet(su)
      end

      pc.send_packet(dsu)

      if oe
        pc.send_packet(oe)
      end
    end
  end

  def open_me
    if name = group_name
      manage_group_open(true, name)
    else
      self.open = true
      broadcast_status_update
      start_auto_close_task
    end
  end

  def close_me
    if task = @auto_close_task
      task.cancel
      @auto_close_task = nil
    end

    if name = group_name
      manage_group_open(false, name)
    else
      self.open = false
      broadcast_status_update
    end
  end

  private def manage_group_open(open, group_name)
    first = nil

    DoorData.get_doors_by_group(group_name).try &.each do |id|
      door = get_sibling_door(id).not_nil!

      first ||= door

      if door.open? != open
        door.open = open
        door.broadcast_status_update
      end
    end

    if first && open
      first.start_auto_close_task
    end
  end

  protected def notify_child_event(open : Bool)
    case open ? template.master_door_open : template.master_door_close
    when 1
      open_me
    when -1
      close_me
    end
  end

  def door_name : String
    template.name
  end

  def get_x(i : Int32) : Int32
    template.node_x[i]
  end

  def get_y(i : Int32) : Int32
    template.node_y[i]
  end

  def z_min : Int32
    template.node_z
  end

  def z_max : Int32
    template.node_z + template.height
  end

  def known_defenders : Array(L2DefenderInstance)
    ret = [] of L2DefenderInstance
    known_defenders { |defender| ret << defender }
    ret
  end

  def known_defenders(& : L2DefenderInstance ->)
    known_list.each_object do |o|
      if o.is_a?(L2DefenderInstance)
        yield o
      end
    end
  end

  def reduce_current_hp(damage : Float64, attacker : L2Character?, awake : Bool, dot : Bool, skill : Skill?)
    if attacker && wall? && instance_id == 0
      unless attacker.servitor?
        return
      end

      unless attacker.template.race.siege_weapon?
        return
      end
    end

    super
  end

  def reduce_current_hp_by_dot(damage : Float64, attacker : L2Character?, skill : Skill?)
    # no-op
  end

  def do_die(killer : L2Character?) : Bool
    return false unless super

    if ((fort = fort?) && fort.residence_id > 0 && fort.siege.in_progress?) ||
      ((castle = castle?) && castle.residence_id > 0 && castle.siege.in_progress?) ||
      ((hall = clan_hall?) && hall.siegable_hall? && hall.as(SiegableHall).in_siege?)

      broadcast_packet(SystemMessage.castle_gate_broken_down)
    end

    true
  end

  def move_to_location(x : Int32, y : Int32, z : Int32, offset : Int32)
    # no-op
  end

  def stop_move(loc : Location?)
    # no-op
  end

  def do_attack(target : L2Character?)
    # no-op
  end

  def do_cast(skill : Skill)
    # no-op
  end

  def send_info(pc : L2PcInstance)
    if visible_for?(pc)
      if emitter > 0
        pc.send_packet(OnEventTrigger.new(self, open?))
      end

      pc.send_packet(StaticObject.new(self, pc.gm?))
    end
  end

  def targetable=(val : Bool)
    @targetable = val
    broadcast_status_update
  end

  def check_collision? : Bool
    template.check_collision?
  end

  def castle? : Castle?
    if @castle_index < 0
      @castle_index = CastleManager.get_castle_index(self)
    end

    if @castle_index < 0
      return
    end

    CastleManager.castles[@castle_index]
  end

  def castle : Castle
    castle? || raise "Castle for door id #{id}, l2id #{l2id} not found"
  end

  def fort? : Fort?
    if @fort_index < 0
      @fort_index = FortManager.get_fort_index(self)
    end

    if @fort_index < 0
      return
    end

    FortManager.forts[@fort_index]
  end

  def fort : Fort
    fort? || raise "Fort for door id: #{id}, l2id: #{l2id} not found"
  end

  private def get_sibling_door(door_id : Int32) : self?
    if instance_id == 0
      return DoorData.get_door(door_id)
    end

    InstanceManager.get_instance(instance_id).try &.get_door(door_id)
  end

  def start_auto_close_task
    return if template.close_time < 0 || openable_by_time?

    if task = @auto_close_task
      task.cancel
      @auto_close_task = nil
    end

    task = AutoClose.new(self)
    delay = template.close_time * 1000
    @auto_close_task = ThreadPoolManager.schedule_general(task, delay)
  end

  def update_abnormal_effect
    # no-op
  end

  def active_weapon_instance : L2ItemInstance?
    # return nil
  end

  def active_weapon_item : L2Weapon?
    # return nil
  end

  def secondary_weapon_instance : L2ItemInstance?
    # return nil
  end

  def secondary_weapon_item : L2Weapon?
    # return nil
  end

  private struct AutoClose
    initializer door : L2DoorInstance

    def call
      @door.close_me if @door.open?
    end
  end

  private struct TimerOpen
    initializer door : L2DoorInstance

    def call
      open = @door.open?
      open ? @door.close_me : @door.open_me
      delay = open ? @door.template.close_time : @door.template.open_time
      if @door.template.random_time > 0
        delay += Rnd.rand(@door.template.random_time)
      end
      ThreadPoolManager.schedule_general(self, delay * 1000)
    end
  end
end
