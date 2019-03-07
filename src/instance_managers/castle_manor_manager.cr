require "../enums/manor_mode"
require "../models/l2_seed"
require "../models/seed_production"
require "../models/crop_procure"

module CastleManorManager
  extend self
  extend XMLReader
  # extend Storable

  private INSERT_PRODUCT = "INSERT INTO castle_manor_production VALUES (?, ?, ?, ?, ?, ?)"
  private INSERT_CROP = "INSERT INTO castle_manor_procure VALUES (?, ?, ?, ?, ?, ?, ?)"

  private SEEDS = {} of Int32 => L2Seed
  private PROCURE = {} of Int32 => Array(CropProcure)
  private PROCURE_NEXT = {} of Int32 => Array(CropProcure)
  private PRODUCTION = {} of Int32 => Array(SeedProduction)
  private PRODUCTION_NEXT = {} of Int32 => Array(SeedProduction)

  @@mode = ManorMode::APPROVED
  @@next_mode_change = Calendar.new

  def load
    unless Config.allow_manor
      info "Manor system is disabled."
      return
    end

    load_xml
    load_db

    time = Calendar.new
    hour = time.hour
    min = time.minute
    maintenance_min = Config.alt_manor_refresh_min + Config.alt_manor_maintenance_min

    if ((hour >= Config.alt_manor_refresh_time) && (min >= maintenance_min)) || (hour < Config.alt_manor_approve_time) || ((hour == Config.alt_manor_approve_time) && (min <= Config.alt_manor_approve_min))
      @@mode = ManorMode::MODIFIABLE
    elsif hour == Config.alt_manor_refresh_time && ((min >= Config.alt_manor_refresh_min) && (min < maintenance_min))
      @@mode = ManorMode::MAINTENANCE
    end

    schedule_mode_change

    unless Config.alt_manor_save_all_actions
      delay = Time.hours_to_ms(Config.alt_manor_save_period_rate)
      interval = Time.hours_to_ms(Config.alt_manor_save_period_rate)
      ThreadPoolManager.schedule_general_at_fixed_rate(->store_me, delay, interval)
    end

    if Config.debug
      info "Current mode: #{@@mode}."
    end
  end

  def load_xml
    parse_datapack_file("seeds.xml")
    info "Loaded #{SEEDS.size} seeds."
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("castle") do |d|
        castle_id = d["id"].to_i
        d.find_element("crop") do |c|
          set = StatsSet.new(c.attributes)
          set["castleId"] = castle_id
          SEEDS[set.get_i32("seedId")] = L2Seed.new(set)
        end
      end
    end
  end

  private def load_db
    sql1 = "SELECT * FROM castle_manor_production WHERE castle_id=?"
    sql2 = "SELECT * FROM castle_manor_procure WHERE castle_id=?"

    CastleManager.castles.each do |castle|
      castle_id = castle.residence_id

      pcurrent = [] of SeedProduction
      pnext = [] of SeedProduction

      GameDB.each(sql1, castle_id) do |rs|
        seed_id = rs.get_i32("seed_id")
        if SEEDS.has_key?(seed_id)
          amount = rs.get_i64("amount")
          price = rs.get_i64("price")
          start_amount = rs.get_i64("start_amount")
          sp = SeedProduction.new(seed_id, amount, price, start_amount)
          if rs.get_bool("next_period")
            pnext << sp
          else
            pcurrent << sp
          end
        else
          warn "Unknown seed id #{seed_id}."
        end
      end

      PRODUCTION[castle_id] = pcurrent
      PRODUCTION_NEXT[castle_id] = pnext


      pcurrent = [] of CropProcure
      pnext = [] of CropProcure
      crop_ids = crop_ids()

      GameDB.each(sql2, castle_id) do |rs|
        crop_id = rs.get_i32("crop_id")
        if crop_ids.includes?(crop_id)
          amount = rs.get_i64("amount")
          reward_type = rs.get_i32("reward_type")
          start_amount = rs.get_i64("start_amount")
          price = rs.get_i64("price")
          cp = CropProcure.new(crop_id, amount, reward_type, start_amount, price)
          if rs.get_bool("next_period")
            pnext << cp
          else
            pcurrent << cp
          end
        else
          warn "Unknown crop id #{crop_id}."
        end
      end

      PROCURE[castle_id] = pcurrent
      PROCURE_NEXT[castle_id] = pnext
    end

    info "Manor data loaded."
  rescue e
    error e
  end

  private def schedule_mode_change
    @@next_mode_change.time = Time.now
    @@next_mode_change.second = 0

    case @@mode
    when .modifiable?
      @@next_mode_change.hour = Config.alt_manor_approve_time
      @@next_mode_change.minute = Config.alt_manor_approve_min
      if @@next_mode_change.before?(Time.now)
        @@next_mode_change.add(1.day)
      end
    when .maintenance?
      @@next_mode_change.hour = Config.alt_manor_refresh_time
      @@next_mode_change.minute = Config.alt_manor_refresh_min + Config.alt_manor_maintenance_min
    when .approved?
      @@next_mode_change.hour = Config.alt_manor_refresh_time
      @@next_mode_change.minute = Config.alt_manor_refresh_min
    end

    ThreadPoolManager.schedule_general(->change_mode, @@next_mode_change.ms - Time.ms)
  end

  def change_mode
    case @@mode
    when .approved?
      @@mode = ManorMode::MAINTENANCE

      CastleManager.castles.each do |castle|
        unless owner = castle.owner?
          next
        end

        castle_id = castle.residence_id
        cwh = owner.warehouse

        PROCURE[castle_id].each do |crop|
          if crop.start_amount > 0
            if crop.start_amount != crop.amount
              count = ((crop.start_amount - crop.amount) * 0.9).to_i64
              if count < 1 && Rnd.rand(99) < 90
                count = 1i64
              end

              if count > 0
                item_id = get_seed_by_crop(crop.id).not_nil!.mature_id
                cwh.add_item("Manor", item_id, count, nil, nil)
              end
            end

            if crop.amount > 0
              castle.add_to_treasury_no_tax(crop.amount * crop.price)
            end
          end
        end

        next_production = PRODUCTION_NEXT[castle_id]
        next_procure = PROCURE_NEXT[castle_id]

        PRODUCTION[castle_id] = next_production
        PROCURE[castle_id] = next_procure

        if castle.treasury < get_manor_cost(castle_id, false)
          PRODUCTION_NEXT[castle_id].clear # L2J sets this to empty list
          PROCURE_NEXT[castle_id].clear # L2J sets this to empty list
        else
          production = next_production.dup
          production.each do |s|
            s.amount = s.start_amount
          end
          PRODUCTION_NEXT[castle_id] = production
          procure = next_procure.dup
          procure.each do |cr|
            cr.amount = cr.start_amount
          end
          PROCURE_NEXT[castle_id] = procure
        end
      end

      store_me
    when .maintenance?
      CastleManager.castles.each do |castle|
        if owner = castle.owner?
          leader = owner.leader?
          if leader && leader.online?
            leader.player.send_packet(SystemMessageId::THE_MANOR_INFORMATION_HAS_BEEN_UPDATED)
          end
        end
      end

      @@mode = ManorMode::MODIFIABLE
    when .modifiable?
      @@mode = ManorMode::APPROVED

      CastleManager.castles.each do |castle|
        unless owner = castle.owner?
          next
        end

        slots = 0
        castle_id = castle.residence_id
        cwh = owner.warehouse
        PROCURE_NEXT[castle_id].each do |crop|
          mature_id = get_seed_by_crop(crop.id).not_nil!.mature_id
          if crop.start_amount > 0 && cwh.get_items_by_item_id(mature_id).nil?
            slots += 1
          end

          manor_cost = get_manor_cost(castle_id, true)

          if !cwh.validate_capacity(slots) && castle.treasury < manor_cost
            PRODUCTION_NEXT[castle_id].clear
            PROCURE_NEXT[castle_id].clear

            leader = owner.leader?
            if leader && leader.online?
              leader.player.send_packet(SystemMessageId::THE_AMOUNT_IS_NOT_SUFFICIENT_AND_SO_THE_MANOR_IS_NOT_IN_OPERATION)
            end
          else
            castle.add_to_treasury_no_tax(-manor_cost)
          end
        end
      end

      if Config.alt_manor_save_all_actions
        store_me
      end
    end

    schedule_mode_change

    if Config.debug
      info "Manor mode changed to #{@@mode}."
    end
  end

  def set_next_seed_production(list : Array(SeedProduction), castle_id : Int32)
    PRODUCTION_NEXT[castle_id] = list

    if Config.alt_manor_save_all_actions
      sql = "DELETE FROM castle_manor_production WHERE castle_id = ? AND next_period = 1"
      GameDB.exec(sql, castle_id)

      unless list.empty?
        # TODO: do it in batch
        list.each do |sp|
          GameDB.exec(
            INSERT_PRODUCT,
            castle_id,
            sp.id,
            sp.amount,
            sp.start_amount,
            sp.price,
            true
          )
        end
      end
    end
  rescue e
    error e
  end

  def set_next_crop_procure(list : Array(CropProcure), castle_id : Int32)
    PROCURE_NEXT[castle_id] = list

    if Config.alt_manor_save_all_actions
      sql = "DELETE FROM castle_manor_procure WHERE castle_id = ? AND next_period = 1"
      GameDB.exec(sql, castle_id)

      unless list.empty?
        # TODO: do it in batch
        list.each do |sp|
          GameDB.exec(
            INSERT_CROP,
            castle_id,
            sp.id,
            sp.amount,
            sp.start_amount,
            sp.price,
            sp.reward,
            true
          )
        end
      end
    end
  rescue e
    error e
  end

  def update_current_production(castle_id : Int32, items : Enumerable(SeedProduction))
    sql = "UPDATE castle_manor_production SET amount = ? WHERE castle_id = ? AND seed_id = ? AND next_period = 0"
    # TODO: do it in batch
    items.each do |sp|
      GameDB.exec(
        sql,
        sp.amount,
        castle_id,
        sp.id
      )
    end
  rescue e
    error e
  end

  def update_current_procure(castle_id : Int32, items : Enumerable(CropProcure))
    sql = "UPDATE castle_manor_procure SET amount = ? WHERE castle_id = ? AND crop_id = ? AND next_period = 0"
    # TODO: do it in batch
    items.each do |sp|
      GameDB.exec(
        sql,
        sp.amount,
        castle_id,
        sp.id
      )
    end
  rescue e
    error e
  end

  def get_seed_production(castle_id : Int32, next_period : Bool) : Array(SeedProduction)
    if next_period
      PRODUCTION_NEXT[castle_id]
    else
      PRODUCTION[castle_id]
    end
  end

  def get_seed_product(castle_id : Int32, seed_id : Int32, next_period : Bool)
    get_seed_production(castle_id, next_period).find do |sp|
      sp.id == seed_id
    end
  end

  def get_crop_procure(castle_id : Int32, next_period : Bool) : Array(CropProcure)
    if next_period
      PROCURE_NEXT[castle_id]
    else
      PROCURE[castle_id]
    end
  end

  def get_crop_procure(castle_id : Int32, crop_id : Int32, next_period : Bool)
    get_crop_procure(castle_id, next_period).find do |sp|
      sp.id == crop_id
    end
  end

  def get_manor_cost(castle_id : Int32, next_period : Bool) : Int64
    procure = get_crop_procure(castle_id, next_period)
    production = get_seed_production(castle_id, next_period)

    total = 0i64

    production.each do |seed|
      s = get_seed(seed.id)
      total += s ? s.seed_reference_price * seed.start_amount : 1
    end
    procure.each do |crop|
      total += crop.price * crop.start_amount
    end

    total
  end

  # TODO: use batch!
  def store_me : Bool
    ds = "DELETE FROM castle_manor_production"
    is = INSERT_PRODUCT
    dp = "DELETE FROM castle_manor_procure"
    ip = INSERT_CROP

    GameDB.exec(ds)

    PRODUCTION.each do |key, value|
      value.each do |sp|
        GameDB.exec(
          is,
          key,
          sp.id,
          sp.amount,
          sp.start_amount,
          sp.price,
          false
        )
      end
    end

    PRODUCTION_NEXT.each do |key, value|
      value.each do |sp|
        GameDB.exec(
          is,
          key,
          sp.id,
          sp.amount,
          sp.start_amount,
          sp.price,
          true
        )
      end
    end

    GameDB.exec(dp)

    PROCURE.each do |key, value|
      value.each do |cp|
        GameDB.exec(
          ip,
          key,
          cp.id,
          cp.amount,
          cp.start_amount,
          cp.price,
          cp.reward,
          false
        )
      end
    end

    PROCURE_NEXT.each do |key, value|
      value.each do |cp|
        GameDB.exec(
          ip,
          key,
          cp.id,
          cp.amount,
          cp.start_amount,
          cp.price,
          cp.reward,
          true
        )
      end
    end

    true
  rescue e
    error e
    false
  end

  def reset_manor_data(castle_id : Int32)
    unless Config.allow_manor
      return
    end

    PROCURE[castle_id].clear
    PROCURE_NEXT[castle_id].clear
    PRODUCTION[castle_id].clear
    PRODUCTION_NEXT[castle_id].clear

    if Config.alt_manor_save_all_actions
      sql = "DELETE FROM castle_manor_production WHERE castle_id = ?"
      GameDB.exec(sql, castle_id)

      sql = "DELETE FROM castle_manor_procure WHERE castle_id = ?"
      GameDB.exec(sql, castle_id)
    end
  rescue e
    error e
  end

  def under_maintenance? : Bool
    @@mode.maintenance?
  end

  def manor_approved? : Bool
    @@mode.approved?
  end

  def modifiable_period? : Bool
    @@mode.modifiable?
  end

  def current_mode_name : String
    @@mode.to_s
  end

  def next_mode_change : String
    Time.now.to_s("%d/%M &H:&m:&s")
  end

  def crops : Array(L2Seed)
    seeds = [] of L2Seed
    crop_ids = [] of Int32
    SEEDS.each_value do |seed|
      unless crop_ids.includes?(seed.crop_id)
        seeds << seed
        crop_ids << seed.crop_id
      end
    end
    crop_ids.clear
    seeds
  end

  def get_seeds_for_castle(castle_id : Int32) : Set(L2Seed)
    SEEDS.local_each_value.select { |s| s.castle_id == castle_id }.to_set
  end

  def seed_ids : Set(Int32)
    SEEDS.local_each_key.to_set
  end

  def crop_ids : Set(Int32)
    SEEDS.local_each_value.map(&.crop_id).to_set
  end

  def get_seed(seed_id : Int32) : L2Seed?
    SEEDS[seed_id]?
  end

  def get_seed_by_crop(crop_id : Int32, castle_id : Int32) : L2Seed?
    get_seeds_for_castle(castle_id).find { |s| s.crop_id == crop_id }
  end

  def get_seed_by_crop(crop_id : Int32) : L2Seed?
    SEEDS.local_each_value.find { |s| s.crop_id == crop_id }
  end
end
