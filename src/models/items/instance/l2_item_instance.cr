require "../../../enums/item_location"
require "../../l2_augmentation"
require "../../drop_protection"
require "../../actor/known_list/null_known_list"

class L2ItemInstance < L2Object
  UNCHANGED = 0
  ADDED = 1
  REMOVED = 3
  MODIFIED = 2

  DEFAULT_ENCHANT_OPTIONS = Slice.new(3, 0, read_only: true)
  private MANA_CONSUMPTION_RATE = 60_000

  @consuming_mana = false
  @db_lock = MyMutex.new
  @shots_mask = 0
  @enchant_options = [] of Options
  @life_time_task : TaskScheduler::DelayedTask?

  getter owner_id = 0
  getter count : Int64 = 0i64
  getter enchant_level = 0
  getter mana = -1
  getter time : Int64 = 0i64
  getter drop_protection = DropProtection.new
  getter elementals : Array(Elementals)?
  getter augmentation : L2Augmentation?
  getter agathion_remaining_energy = 0
  getter? published = false
  property custom_type_1 : Int32 = 0
  property custom_type_2 : Int32 = 0
  property loc : ItemLocation = ItemLocation::VOID
  property loc_data : Int32 = 0
  property drop_time : Int64 = 0i64
  property last_change : Int32 = 2
  property dropper_l2id : Int32 = 0
  property item_loot_schedule : TaskScheduler::DelayedTask?
  property? protected : Bool = false
  property? exists_in_db : Bool = false
  property? stored_in_db : Bool = false

  def initialize(l2id : Int32, item_id : Int32)
    super(l2id)

    unless item = ItemTable[item_id]?
      raise ArgumentError.new("No L2Item with id #{item_id}")
    end

    @item = item
    self.name = item.name
    self.count = 1
    @mana = item.duration
    @time = item.time == -1 ? -1i64 : Time.ms + (item.time * 60 * 1000)
    if info = AgathionRepository.get_by_item_id(item_id)
      @agathion_remaining_energy = info.max_energy
    end

    schedule_life_time_task
  end

  def initialize(l2id : Int32, item : L2Item)
    @item = item
    super(l2id)

    if item.id == 0
      raise ArgumentError.new("item id cannot be 0")
    end
    self.name = item.name
    self.count = 1
    @mana = item.duration
    @time = item.time == -1 ? -1i64 : Time.ms + (item.time * 60 * 1000)
    if info = AgathionRepository.get_by_item_id(item.id)
      @agathion_remaining_energy = info.max_energy
    end

    schedule_life_time_task
  end

  def initialize(item_id : Int32)
    initialize(IdFactory.next, item_id)
  end

  def instance_type : InstanceType
    InstanceType::L2ItemInstance
  end

  private def init_known_list
    @known_list = NullKnownList::INSTANCE
  end

  def publish
    @published = true
  end

  def template : L2Item
    @item
  end

  delegate equip_reuse_delay, display_id, reference_price, reuse_delay,
    shared_reuse_group, stackable?, destroyable?, potion?, elixir?, scroll?,
    hero_item?, oly_restricted_item?, freightable?, quest_item?, pet_item?,
    body_part, mask, use_skill_dis_time, default_enchant_level, to: @item

  def pickup_me(pc : L2Character)
    unless old_region = world_region
      warn "#pickup_me: @world_region should not be nil"
    end

    pc.broadcast_packet(GetItem.new(self, pc.l2id))

    sync do
      self.visible = false
      self.world_region = nil
    end

    if MercTicketManager.get_ticket_castle_id(id) > 0
      MercTicketManager.remove_ticket(self)
      ItemsOnGroundManager.remove_object(self)
    end

    L2World.remove_visible_object(self, old_region)

    if pc.is_a?(L2PcInstance)
      OnPlayerItemPickup.new(pc, self).async(@item)
    end
  end

  def set_owner_id(process : String?, id : Int32, pc : L2PcInstance?, reference)
    self.owner_id = id

    if Config.log_items
      # TODO
    end

    if Config.gmaudit && pc && pc.gm?
      ref_name = "no-reference"
      case reference
      when L2Object
        ref_name = reference.name.empty? ? "no-name" : reference.name
      when String
        ref_name = reference
      end

      target_name = pc.target.try &.name
      GMAudit.log(pc, "#{process}(#{id} name: #{name})", target_name, "L2Object referencing this action is: #{ref_name}")
    end
  end

  def owner_id=(id : Int32)
    return if id == @owner_id

    remove_skills_from_owner

    @owner_id = id
    @stored_in_db = false

    give_skills_to_owner
  end

  def item_location=(loc : ItemLocation)
    set_item_location(loc)
  end

  def set_item_location(loc : ItemLocation, loc_data : Int32 = 0)
    return if loc == @loc && loc_data == @loc_data

    remove_skills_from_owner

    @loc = loc
    @loc_data = loc_data
    @stored_in_db = false

    give_skills_to_owner
  end

  def item_location : ItemLocation
    @loc
  end

  def count=(count : Int64)
    return if count() == count
    @count = count >= -1 ? count : 0i64
    @stored_in_db = false
  end

  def change_count(process : String?, count : Int64, pc : L2PcInstance?, reference)
    return if count == 0

    # old = count() # commented out until logging below is implemented

    max = id == Inventory::ADENA_ID ? Inventory.max_adena : Int32::MAX
    max = max.to_i64

    if count > 0 && count() > max - count
      self.count = max
    else
      self.count += count
    end

    if count() < 0
      self.count = 0
    end

    @stored_in_db = false

    # logging

    if Config.gmaudit && pc && pc.gm?
      ref_name = "no-reference"
      case reference
      when L2Object
        ref_name = reference.name.empty? ? "no-name" : reference.name
      when String
        ref_name = reference
      end

      target_name = pc.target.try &.name
      GMAudit.log(pc, "#{process}(#{id} name: #{name})", target_name, "L2Object referencing this action is: #{ref_name}")
    end
  end

  def change_count_without_trace(count : Int64, pc : L2PcInstance?, reference)
    change_count(nil, count, pc, reference)
  end

  def enchantable : Int32
    if item_location.inventory? || item_location.paperdoll?
      return @item.enchantable
    end

    0
  end

  def equippable? : Bool
    return false if @item.body_part == 0
    !@item.item_type.in?(EtcItemType::ARROW, EtcItemType::BOLT, EtcItemType::LURE)
  end

  def equipped? : Bool
    @loc.paperdoll? || @loc.pet_equip?
  end

  def location_slot : Int32
    # unless @loc.paperdoll? || @loc.pet_equip? || @loc.inventory? || @loc.mail? || @loc.freight?
    #   debug "#location_slot: @loc_data shouldn't be #{@loc_data}."
    #   debug caller.join("\n")
    # end

    @loc_data
  end

  def item_id : Int32
    @item.id
  end

  def id : Int32
    item_id
  end

  def etc_item : L2EtcItem?
    @item.as?(L2EtcItem)
  end

  def etc_item! : L2EtcItem
    @item.as(L2EtcItem)
  end

  def weapon_item : L2Weapon?
    @item.as?(L2Weapon)
  end

  def weapon_item! : L2Weapon
    @item.as(L2Weapon)
  end

  def armor_item : L2Armor?
    @item.as?(L2Armor)
  end

  def armor_item! : L2Armor
    @item.as(L2Armor)
  end

  def etc_item? : Bool
    @item.is_a?(L2EtcItem)
  end

  def weapon? : Bool
    @item.is_a?(L2Weapon)
  end

  def armor? : Bool
    @item.is_a?(L2Armor)
  end

  def night_lure? : Bool
    id.between?(8505, 8513) || id == 8485
  end

  def auto_attackable?(attacker : L2Character) : Bool
    false
  end

  def crystal_count : Int32
    @item.get_crystal_count(@enchant_level)
  end

  def item_name : String
    @item.name
  end

  def droppable? : Bool
    !augmented? && @item.droppable?
  end

  def tradeable? : Bool
    !augmented? && @item.tradeable?
  end

  def sellable? : Bool
    !augmented? && @item.sellable?
  end

  def depositable?(private_warehouse : Bool) : Bool
    if equipped? || !@item.depositable?
      return false
    end

    unless private_warehouse
      if !tradeable? || shadow_item?
        return false
      end
    end

    true
  end

  def common_item? : Bool
    @item.common?
  end

  def pvp? : Bool
    @item.pvp_item?
  end

  # def available?(pc : L2PcInstance, allow_adena : Bool, allow_non_tradeable : Bool) : Bool
  #   !equipped? &&
  #   @item.type_2 != ItemType2::QUEST && # Not Quest Item
  #   (@item.type_2 != ItemType2::MONEY || @item.type_1 != ItemType1::SHIELD_ARMOR) && # not money, not shield
  #   # (!pc.has_summon? || @l2id != pc.summon.not_nil!.control_l2id) && # Not Control item of currently summoned pet
  #   (smn = pc.summon; smn.nil? || @l2id != smn.control_l2id) && # Not Control item of currently summoned pet
  #   pc.active_enchant_item_id != @l2id && # Not currently used enchant scroll
  #   pc.active_enchant_support_item_id != @l2id && # Not currently used enchant support item
  #   pc.active_enchant_attr_item_id != @l2id && # Not currently used enchant attribute item
  #   (allow_adena || id != Inventory::ADENA_ID) && # Not Adena
  #   # (!pc.current_skill || pc.current_skill.not_nil!.skill.item_consume_id != id) && (!pc.casting_simultaneously_now? || pc.last_simultaneous_skill_cast.nil? || pc.last_simultaneous_skill_cast.not_nil!.item_consume_id != id) &&
  #   (current_skill = pc.current_skill; current_skill.nil? || current_skill.skill.item_consume_id != id) &&
  #   (!pc.casting_simultaneously_now? || (cast = pc.last_simultaneous_skill_cast; cast.nil? || cast.item_consume_id != id)) &&
  #   (allow_non_tradeable || (tradeable? && (!(@item.item_type == EtcItemType::PET_COLLAR && pc.has_pet_items?))))
  # end

  def available?(pc : L2PcInstance, allow_adena : Bool, allow_non_tradeable : Bool) : Bool
    return false if equipped?
    return false if @item.type_2.quest? || @item.type_2.money?
    if smn = pc.summon
      return false if smn.control_l2id == l2id
    end
    return false if pc.active_enchant_item_id == l2id
    return false if pc.active_enchant_support_item_id == l2id
    return false if pc.active_enchant_attr_item_id == l2id
    return false if !allow_adena && id == Inventory::ADENA_ID
    if holder = pc.current_skill
      return false if holder.skill.item_consume_id == id
    end
    if pc.casting_simultaneously_now?
      if cast = pc.last_simultaneous_skill_cast
        return false if cast.item_consume_id == id
      end
    end
    return false if !allow_non_tradeable && !tradeable?
    if @item.item_type == EtcItemType::PET_COLLAR && pc.has_pet_items?
      return false
    end

    true
  end

  def enchant_level=(lvl : Int32)
    return if @enchant_level == lvl

    clear_enchant_stats
    @enchant_level = lvl
    apply_enchant_stats
    @stored_in_db = false
  end

  def time_limited_item? : Bool
    @time > 0
  end

  def remaining_time : Int64
    @time - Time.ms
  end

  def augmented? : Bool
    !!@augmentation
  end

  def get_elemental(attribute : Int) : Elementals?
    @elementals.try &.find { |e| e.element == attribute }
  end

  def attack_element_type : Int8
    if !weapon?
      -2i8
    elsif elementals = @item.elementals
      elementals[0].not_nil!.element
    elsif elementals = @elementals
      elementals[0].not_nil!.element
    else
      -2i8
    end
  end

  def attack_element_power : Int32
    if !weapon?
      0
    elsif elementals = @item.elementals
      elementals[0].not_nil!.value
    elsif elementals = @elementals
      elementals[0].not_nil!.value
    else
      0
    end
  end

  def get_element_def_attr(element : Int) : Int32
    if !armor?
      # do nothing
    elsif @item.elementals
      if elm = @item.get_elemental(element)
        return elm.value
      end
    elsif @elementals
      if elm = get_elemental(element)
        return elm.value
      end
    end

    0
  end

  def shadow_item? : Bool
    @mana >= 0
  end

  def enchant_options : Slice(Int32)
    if temp = EnchantItemOptionsData.get_options(self)
      return temp.options
    end

    DEFAULT_ENCHANT_OPTIONS
  end

  def clear_enchant_stats
    unless pc = acting_player
      @enchant_options.clear
      return
    end

    @enchant_options.each &.remove(pc)
    @enchant_options.clear
  end

  def update_database(force : Bool = false)
    @db_lock.synchronize do
      if @exists_in_db
        if @owner_id == 0 || @loc.void? || @loc.refund? || (@count == 0 && !@loc.lease?)
          remove_from_db
        elsif !Config.lazy_items_update || force
          update_in_db
        end
      else
        if @owner_id == 0 || @loc.void? || @loc.refund? || (@count == 0 && !@loc.lease?)
          return
        end
        insert_into_db
      end
    end
  end

  def update_in_db
    unless @exists_in_db
      error "#update_in_db: @exists_in_db should be true."
    end

    return if @stored_in_db

    begin
      sql = "UPDATE items SET owner_id=?,count=?,loc=?,loc_data=?,enchant_level=?,custom_type1=?,custom_type2=?,mana_left=?,time=? WHERE object_id = ?"
      GameDB.exec(
        sql,
        @owner_id,
        count,
        @loc.to_s,
        @loc_data,
        enchant_level,
        custom_type_1,
        custom_type_2,
        mana,
        time,
        l2id
      )

      @exists_in_db = true
      @stored_in_db = true
    rescue e
      error e
    end
  end

  def insert_into_db
    # unless !@exists_in_db && @l2id != 0
    #   error "#insert_into_db: expectation failed"
    # end

    sql = "INSERT INTO items (owner_id,item_id,count,loc,loc_data,enchant_level,object_id,custom_type1,custom_type2,mana_left,time) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
    GameDB.exec(
      sql,
      @owner_id,
      id,
      count,
      @loc.to_s,
      @loc_data,
      enchant_level,
      l2id,
      @custom_type_1,
      @custom_type_2,
      mana,
      time
    )

    @exists_in_db = true
    @stored_in_db = true

    if @augmentation
      update_item_attributes
    end

    if @elementals
      update_item_elements
    end
  rescue e
    error e
  end

  def remove_from_db
    unless @exists_in_db
      error "#remove_from_db: @exists_in_db should be true"
    end

    @exists_in_db = false
    @stored_in_db = false

    begin
      sql = "DELETE FROM items WHERE object_id = ?"
      GameDB.exec(sql, l2id)
    rescue e
      error e
    end

    begin
      sql = "DELETE FROM item_attributes WHERE itemId = ?"
      GameDB.exec(sql, l2id)
    rescue e
      error e
    end

    begin
      sql = "DELETE FROM item_elementals WHERE itemId = ?"
      GameDB.exec(sql, l2id)
    rescue e
      error e
    end
  end

  def self.restore_from_db(owner_id : Int32, rs : ResultSetReader)
    l2id = rs.get_i32(:"object_id")
    item_id = rs.get_i32(:"item_id")
    count = rs.get_i64(:"count")
    enchant_level = rs.get_i32(:"enchant_level")
    loc = ItemLocation.parse(rs.get_string(:"loc"))
    loc_data = rs.get_i32(:"loc_data")
    type_1 = rs.get_i32(:"custom_type1")
    type_2 = rs.get_i32(:"custom_type2")
    mana_left = rs.get_i32(:"mana_left")
    time = rs.get_i64(:"time")
    agathion_energy = rs.get_i32(:"agathion_energy")

    item = ItemTable[item_id]

    inst = new(l2id, item)
    inst.count = count
    inst.custom_type_1 = type_1
    inst.custom_type_2 = type_2
    inst.exists_in_db = true
    inst.stored_in_db = true
    inst.loc = loc
    inst.loc_data = loc_data
    inst.set_attrs_from_db(owner_id, enchant_level, mana_left, time, agathion_energy)

    if inst.equippable?
      inst.restore_attributes
    end

    inst
  end

  protected def set_attrs_from_db(owner_id, enchant_level, mana_left, time, agathion_energy)
    @owner_id = owner_id
    @enchant_level = enchant_level
    @mana = mana_left
    @time = time
    @agathion_remaining_energy = agathion_energy
  end

  def delete_me
    if task = @life_time_task
      unless task.done?
        task.cancel
        @life_time_task = nil
      end
    end
  end

  def heading=(heading)
    # no-op
  end

  def drop_me(dropper : L2Character?, x : Int32, y : Int32, z : Int32)
    task = ItemDropTask.new(self, dropper, x, y, z)
    ThreadPoolManager.execute_general(task)

    if dropper.is_a?(L2PcInstance)
      loc = Location.new(x, y, z)
      OnPlayerItemDrop.new(dropper, self, loc).async(template)
    end
  end

  class ItemDropTask
    initializer item : L2ItemInstance, dropper : L2Character?, x : Int32,
      y : Int32, z : Int32

    def call
      if dropper = @dropper
        loc = GeoData.move_check(*dropper.xyz, @x, @y, @z, dropper.instance_id)
        @x, @y, @z = loc.xyz
        @item.instance_id = dropper.instance_id
      else
        @item.instance_id = 0
      end

      @item.sync do
        @item.visible = true
        @item.set_xyz(@x, @y, @z)
        @item.world_region = L2World.get_region(@item)
      end

      @item.world_region.not_nil!.add_visible_object(@item)
      @item.drop_time = Time.ms
      @item.dropper_l2id = @dropper.try &.l2id || 0

      L2World.add_visible_object(@item, @item.world_region.not_nil!)

      if Config.save_dropped_item
        ItemsOnGroundManager.save(@item)
      end

      @item.dropper_l2id = 0
    end
  end

  def send_info(pc : L2PcInstance)
    if @dropper_l2id != 0
      pc.send_packet(DropItem.new(self, @dropper_l2id))
    else
      pc.send_packet(SpawnItem.new(self))
    end
  end

  def acting_player : L2PcInstance?
    L2World.get_player(owner_id)
  end

  def item? : Bool
    true
  end

  def enchanted? : Bool
    @enchant_level > 0
  end

  def get_stat_funcs(char : L2Character) : Enumerable(AbstractFunction)
    @item.get_stat_funcs(self, char)
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    return unless command.starts_with?("Quest")

    quest_name = command.from(6)
    if idx = quest_name.index(' ')
      event = quest_name.from(idx).strip
    end

    if event
      OnItemBypassEvent.new(self, pc, event).async(@item)
    else
      OnItemTalk.new(self, pc).async(@item)
    end
  end

  def charged_shot?(type : ShotType) : Bool
    @shots_mask & type.mask == type.mask
  end

  def set_charged_shot(type : ShotType, charged : Bool)
    charged ? (@shots_mask |= type.mask) : (@shots_mask &= ~type.mask)
  end

  def uncharge_all_shots
    @shots_mask = 0
  end

  def has_passive_skills? : Bool
    item_type == EtcItemType::RUNE && item_location.inventory? &&
      owner_id > 0 && @item.has_skills?
  end

  def give_skills_to_owner
    return unless has_passive_skills?

    if pc = acting_player
      @item.skills.try &.each do |sh|
        skill = sh.skill?
        if skill && skill.passive?
          pc.add_skill(skill, false)
        end
      end
    end
  end

  def remove_skills_from_owner
    return unless has_passive_skills?

    if pc = acting_player
      @item.skills.try &.each do |sh|
        skill = sh.skill?
        if skill && skill.passive?
          pc.remove_skill(skill, false, true)
        end
      end
    end
  end

  def decay_me : Bool
    if Config.save_dropped_item
      ItemsOnGroundManager.remove_object(self)
    end

    super
  end

  def set_augmentation(aug : L2Augmentation) : Bool
    if @augmentation
      warn "#augmentation=: already has an augmentation."
      return false
    end

    @augmentation = aug

    update_item_attributes

    if pc = acting_player
      OnPlayerAugment.new(pc, self, aug, true).async(@item)
    end

    true
  end

  private def update_item_attributes
    sql = "REPLACE INTO item_attributes VALUES(?,?)"
    GameDB.exec(sql, l2id, @augmentation.try &.attributes || -1)
  rescue e
    error e
  end

  def remove_augmentation
    return unless augment = @augmentation
    @augmentation = nil

    begin
      sql = "DELETE FROM item_attributes WHERE itemId = ?"
      GameDB.exec(sql, l2id)
    rescue e
      error e
    end

    if pc = acting_player
      OnPlayerAugment.new(pc, self, augment, false).async(@item)
    end
  end

  def restore_attributes
    sql1 = "SELECT augAttributes FROM item_attributes WHERE itemId=?"
    GameDB.query_each(sql1, l2id) do |rs|
      aug_attributes = rs.read(Int32)
      if aug_attributes != -1
        @augmentation = L2Augmentation.new(aug_attributes)
      end
    end

    sql2 = "SELECT elemType,elemValue FROM item_elementals WHERE itemId=?"
    GameDB.query_each(sql2, l2id) do |rs|
      elem_type = rs.read(Int8)
      elem_value = rs.read(Int32)
      if elem_type != -1 && elem_value != -1
        apply_attribute(elem_type, elem_value)
      end
    end
  rescue e
    error e
  end

  private def apply_attribute(element : Int8, value : Int32)
    if elementals = @elementals
      if elm = get_elemental(element)
        elm.value = value
      else
        elementals << Elementals.new(element, value)
      end
    else
      @elementals = [Elementals.new(element, value)]
    end
  end

  def set_element_attr(element : Int8, value : Int32)
    apply_attribute(element, value)
    update_item_elements
  end

  def clear_element_attr(element : Int)
    return if !get_elemental(element) && element != -1
    if elementals = @elementals
      if element != -1 && elementals.size > 1
        elementals.reject! { |e| e.element == element }
      end
    end

    begin
      if element != -1
        sql = "DELETE FROM item_elementals WHERE itemId = ? AND elemType = ?"
        GameDB.exec(sql, l2id, element)
      else
        sql = "DELETE FROM item_elementals WHERE itemId = ?"
        GameDB.exec(sql, l2id)
      end
    rescue e
      error e
    end
  end

  private def update_item_elements
    sql = "DELETE FROM item_elementals WHERE itemId = ?"
    GameDB.exec(sql, l2id)

    sql = "INSERT INTO item_elementals VALUES(?,?,?)"
    @elementals.try &.each do |elm|
      GameDB.exec(sql, l2id, elm.element, elm.value)
    end
  rescue e
    error e
  end

  def apply_enchant_stats
    return unless pc = acting_player

    if !equipped? || enchant_options == DEFAULT_ENCHANT_OPTIONS
      return
    end

    enchant_options.each do |id|
      if options = OptionData[id]
        options.apply(pc)
        @enchant_options << options
      elsif id != 0
        warn { "#apply_enchant_stats: Option with id #{id} not found." }
      end
    end
  end

  def update_element_attr_bonus(pc : L2PcInstance)
    @elementals.try &.each &.update_bonus(pc, armor?)
  end

  def remove_element_attr_bonus(pc : L2PcInstance)
    @elementals.try &.each &.remove_bonus(pc)
  end

  def item_type : ItemType
    @item.item_type.as(ItemType)
  end

  def oly_enchant_level : Int32
    enchant = enchant_level
    return enchant unless pc = acting_player

    if pc.in_olympiad_mode? && Config.alt_oly_enchant_limit >= 0
      if enchant > Config.alt_oly_enchant_limit
        enchant = Config.alt_oly_enchant_limit
      end
    end

    enchant
  end

  def elementable? : Bool
    (item_location.inventory? || item_location.paperdoll?) && @item.elementable?
  end

  def schedule_life_time_task
    return unless time_limited_item?

    remaining_time = remaining_time()

    if remaining_time <= 0
      end_of_life
    else
      @life_time_task.try &.cancel
      task = LifetimeTask.new(self)
      @life_time_task = ThreadPoolManager.schedule_general(task, remaining_time)
    end
  end

  def end_of_life
    unless pc = acting_player
      return
    end

    if equipped?
      uneq = pc.inventory.unequip_item_in_slot_and_record(location_slot)
      iu = InventoryUpdate.new

      uneq.each do |item|
        item.uncharge_all_shots
        iu.add_modified_item(item)
      end

      pc.send_packet(iu)
      pc.broadcast_user_info
    end

    if item_location.warehouse?
      pc.warehouse.destroy_item("L2ItemInstance", self, pc, nil)
    else
      pc.inventory.destroy_item("L2ItemInstance", self, pc, nil)
      pc.send_packet(InventoryUpdate.removed(self))
      pc.send_packet(StatusUpdate.current_load(pc))
    end

    pc.send_packet(SystemMessageId::TIME_LIMITED_ITEM_DELETED)
    L2World.remove_object(self)
  end

  def decrease_mana(reset_consuming_mana : Bool, count : Int = 1)
    return unless shadow_item?

    if @mana - count >= 0
      @mana &-= count
    else
      @mana = 0
    end

    @stored_in_db = false if @stored_in_db
    @consuming_mana = false if reset_consuming_mana

    return unless pc = acting_player

    case @mana
    when 10
      sm = SystemMessage.s1s_remaining_mana_is_now_10
    when 5
      sm = SystemMessage.s1s_remaining_mana_is_now_5
    when 1
      sm = SystemMessage.s1s_remaining_mana_is_now_1
    end

    if sm
      sm.add_item_name(@item)
      pc.send_packet(sm)
    end

    if @mana == 0
      sm = SystemMessage.s1s_remaining_mana_is_now_0
      sm.add_item_name(@item)
      pc.send_packet(sm)

      if equipped?
        uneq = pc.inventory.unequip_item_in_slot_and_record(location_slot)
        iu = InventoryUpdate.new
        uneq.each do |it|
          it.uncharge_all_shots
          iu.add_modified_item(it)
        end
        pc.send_packet(iu)
        pc.broadcast_user_info
      end

      if item_location.warehouse?
        pc.warehouse.destroy_item("L2ItemInstance", self, pc, nil)
      else
        pc.inventory.destroy_item("L2ItemInstance", self, pc, nil)
        pc.send_packet(InventoryUpdate.removed(self))
        pc.send_packet(StatusUpdate.current_load(pc))
      end

      L2World.remove_object(self)
    else
      if !@consuming_mana && equipped?
        schedule_consume_mana_task
      end

      unless item_location.warehouse?
        pc.send_packet(InventoryUpdate.modified(self))
      end
    end
  end

  def schedule_consume_mana_task
    return if @consuming_mana
    @consuming_mana = true
    task = ConsumeManaTask.new(self)
    ThreadPoolManager.schedule_general(task, MANA_CONSUMPTION_RATE)
  end

  def reset_owner_timer
    if task = @item_loot_schedule
      task.cancel
      @item_loot_schedule = nil
    end
  end

  def agathion_remaining_energy=(energy : Int32)
    @agathion_remaining_energy = energy
    @stored_in_db = false
  end

  def to_s(io : IO)
    if stackable?
      io.print({{@type.stringify + "("}}, @item.name, " x", @count, ')')
    else
      io.print({{@type.stringify + "("}}, @item.name, ')')
    end
  end

  private struct LifetimeTask
    include Loggable

    initializer item : L2ItemInstance

    def call
      @item.end_of_life
    rescue e
      error e
    end
  end

  private struct ConsumeManaTask
    include Loggable

    initializer item : L2ItemInstance

    def call
      @item.decrease_mana(true)
    rescue e
      error e
    end
  end
end
