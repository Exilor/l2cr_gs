abstract class ClanHall
  include Packets::Outgoing
  include Loggable

  # Clan Hall Functions
  FUNC_TELEPORT = 1
  FUNC_ITEM_CREATE = 2
  FUNC_RESTORE_HP = 3
  FUNC_RESTORE_MP = 4
  FUNC_RESTORE_EXP = 5
  FUNC_SUPPORT = 6
  FUNC_DECO_FRONTPLATEFORM = 7 # Only Auctionable Halls
  FUNC_DECO_CURTAINS = 8 # Only Auctionable Halls

  @functions = Hash(Int32, ClanHallFunction).new
  @clan_hall_id = 0
  getter doors = [] of L2DoorInstance
  getter name = ""
  getter owner_id = 0
  getter location = ""
  getter desc = ""
  getter? free = true
  property lvl : Int32 = 0
  property end_time : Int64 = 0i64 # L2J: _endDate
  property! zone : L2ClanHallZone

  def initialize(set : StatsSet)
    @clan_hall_id = set.get_i32("id")
    @name = set.get_string("name")
    @owner_id = set.get_i32("ownerId")
    @desc = set.get_string("desc")
    @location = set.get_string("location")

    if @owner_id > 0
      if clan = ClanTable.get_clan(@owner_id)
        clan.hideout_id = id
      else
        free
      end
    end
  end

  def id
    @clan_hall_id
  end

  def get_door(door_id : Int32) : L2DoorInstance?
    if door_id < 0
      return
    end

    doors.find { |door| door.id == door_id }
  end

  def get_function(type : Int32) : ClanHallFunction?
    @functions[type]?
  end

  def in_zone?(x : Int32, y : Int32, z : Int32) : Bool
    zone.inside_zone?(x, y, z)
  end

  def free
    @owner_id = 0
    @free = true
    @functions.each_key { |fc| remove_function(fc) }
    @functions.clear
    update_db
  end

  def owner=(clan : L2Clan?)
    return unless clan
    return if @owner_id > 0

    @owner_id = clan.id
    @free = false
    clan.hideout_id = id
    clan.broadcast_to_online_members(PledgeShowInfoUpdate.new(clan))
    update_db
  end

  def open_close_door(pc : L2PcInstance, door_id : Int32, open : Bool)
    if pc.clan_id == owner_id
      open_close_door(door_id, open)
    else
      debug "#{pc.name}'s clan with id #{pc.clan_id} is not the owner of this clan hall with owner id #{owner_id}."
    end
  end

  def open_close_door(door_id : Int32, open : Bool)
    open_close_door(get_door(door_id), open)
  end

  def open_close_door(door : L2DoorInstance?, open : Bool)
    if door
      open ? door.open_me : door.close_me
    end
  end

  def open_close_doors(pc : L2PcInstance, open : Bool)
    if pc.clan_id == owner_id
      open_close_doors(open)
    end
  end

  def open_close_doors(open : Bool)
    doors.each { |door| open ? door.open_me : door.close_me }
  end

  def banish_foreigners
    if zone = @zone
      zone.banish_foreigners(owner_id)
    else
      warn "Zone is nil for clan hall #{id} #{name}."
    end
  end

  private def load_functions
    sql = "SELECT * FROM clanhall_functions WHERE hall_id = ?"
    GameDB.each(sql, id) do |rs|
      type = rs.get_i32("type")
      lvl = rs.get_i32("lvl")
      lease = rs.get_i32("lease")
      rate = rs.get_i64("rate")
      end_time = rs.get_i64("endTime")

      fn = ClanHallFunction.new(self, type, lvl, lease, 0, rate, end_time, true)
      @functions[type] = fn
    end
  rescue e
    error e
  end

  def remove_function(function_type : Int32)
    @functions.delete(function_type)

    sql = "DELETE FROM clanhall_functions WHERE hall_id=? AND type=?"
    GameDB.exec(sql, id, function_type)
  rescue e
    error e
  end

  def update_functions(pc : L2PcInstance?, type : Int32, lvl : Int32, lease : Int32, rate : Int64, add_new : Bool) : Bool
    unless pc
      return false
    end

    if lease > 0
      unless pc.destroy_item_by_item_id("Consume", Inventory::ADENA_ID, lease.to_i64, nil, true)
        return false
      end
    end

    if add_new
      @functions[type] = ClanHallFunction.new(self, type, lvl, lease, 0, rate, 0, false)
    else
      if lvl == 0 || lease == 0
        remove_function(type)
      else
        diff_lease = lease - @functions[type].lease
        if diff_lease > 0
          @functions.delete(type)
          @functions[type] = ClanHallFunction.new(self, type, lvl, lease, 0, rate, -1, false)
        else
          fn = @functions[type]
          fn.lease = lease
          fn.lvl = lvl
          fn.db_save
        end
      end
    end

    true
  end

  abstract def update_db

  def grade
    0
  end

  def paid_until
    0i64
  end

  def lease
    0
  end

  def siegable_hall?
    false
  end

  class ClanHallFunction
    include Loggable

    getter type, rate
    property lvl : Int32
    property cwh : Bool = false

    def initialize(@ch : ClanHall, @type : Int32, @lvl : Int32, @fee : Int32, @temp_fee : Int32, @rate : Int64, @end_date : Int64, cwh : Bool)
      initialize_task(cwh)
    end

    private def initialize_task(cwh : Bool)
      return if @ch.@free

      time = Time.ms

      # task = FunctionTask.new(self, cwh)
      task = ->{ function_task(cwh) }
      if @end_date > time
        ThreadPoolManager.schedule_general(task, @end_date - time)
      else
        ThreadPoolManager.schedule_general(task, 0)
      end
    end

    private def function_task(cwh : Bool)
      return if @ch.@free
      warehouse = ClanTable.get_clan!(@ch.owner_id).warehouse
      if warehouse.adena >= @fee || !@cwh
        fee = @fee
        if end_time == -1
          fee = @temp_fee
        end
        self.end_time = Time.ms + rate
        db_save
        if @cwh
          warehouse.destroy_item_by_item_id("CH_function_fee", Inventory::ADENA_ID, fee.to_i64, nil, nil)
        end
        task = ->{ function_task(true) }
        ThreadPoolManager.schedule_general(task, rate)
      else
        @ch.remove_function(type)
      end
    rescue e
      error e
    end

    def db_save
      sql = "REPLACE INTO clanhall_functions (hall_id, type, lvl, lease, rate, endTime) VALUES (?,?,?,?,?,?)"
      GameDB.exec( sql, @ch.id, type, lvl, lease, rate, end_time)
    rescue e
      error e
    end

    def lease
      @fee
    end

    def lease=(@fee : Int32)
    end

    def end_time
      @end_date
    end

    def end_time=(@end_date : Int64)
    end
  end
end
