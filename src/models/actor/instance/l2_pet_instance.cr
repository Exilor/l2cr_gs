require "../l2_summon"
require "../stat/pet_stat"
require "../../item_containers/pet_inventory"

class L2PetInstance < L2Summon
  extend Synchronizable

  @exp_before_death = 0i64
  @cur_weight_penalty = 0
  @feed_task : TaskScheduler::PeriodicTask?
  @mountable : Bool
  @data : L2PetData?
  @level_data : L2PetLevelData?

  getter control_l2id : Int32
  getter current_feed = 0
  getter(inventory) { PetInventory.new(self) }
  getter name = ""
  getter? mountable : Bool
  getter? in_support_mode = true # L2J: _bufferMode
  property? respawned : Bool = false

  def initialize(template : L2NpcTemplate, owner : L2PcInstance, control : L2ItemInstance)
    level = template.display_id == 12564 ? owner.level : template.level.to_i32
    initialize(template, owner, control, level)
  end

  def initialize(template : L2NpcTemplate, owner : L2PcInstance, control : L2ItemInstance, level : Int32)
    super(template, owner)

    @control_l2id = control.l2id

    stat.level = Math.max(level, min_level)

    @mountable = PetDataTable.mountable?(template.id)

    pet_data
    pet_level_data
    inventory.restore
  end

  def instance_type : InstanceType
    InstanceType::L2PetInstance
  end

  def inventory? : PetInventory?
    @inventory
  end

  def template : L2NpcTemplate
    super.as(L2NpcTemplate)
  end

  private def init_char_stat
    @stat = PetStat.new(self)
  end

  def stat : PetStat
    super.as(PetStat)
  end

  def pet_level_data : L2PetLevelData
    @level_data ||= PetDataTable.get_pet_level_data(template.id, stat.level)
  end

  def pet_data : L2PetData
    @data ||= PetDataTable.get_pet_data(template.id)
  end

  def pet_data=(@level_data : L2PetLevelData)
  end

  private def feed_task
    if !owner.has_summon? || self != owner.summon
      stop_feed
      return
    elsif current_feed > feed_consume
      self.current_feed &-= feed_consume
    else
      self.current_feed = 0
    end

    broadcast_status_update

    food_ids = pet_data.food
    if food_ids.empty?
      if uncontrollable?
        if template.id == 16050 && @owner
          owner.pk_kills = Math.max(owner.pk_kills - Rnd.rand(1..6), 0)
        end
        send_packet(SystemMessageId::THE_HELPER_PET_LEAVING)
        delete_me(@owner)
      elsif hungry?
        send_packet(SystemMessageId::THERE_NOT_MUCH_TIME_REMAINING_UNTIL_HELPER_LEAVES)
      end

      return
    end

    food = nil
    food_ids.each do |id|
      break if food = inventory.get_item_by_item_id(id)
    end

    if food && hungry?
      if handler = ItemHandler[food.etc_item]
        sm = SystemMessage.pet_took_s1_because_he_was_hungry
        sm.add_item_name(food.id)
        send_packet(sm)
        handler.use_item(self, food, false)
      end
    end

    if uncontrollable?
      send_packet(SystemMessageId::YOUR_PET_IS_STARVING_AND_WILL_NOT_OBEY_UNTIL_IT_GETS_ITS_FOOD_FEED_YOUR_PET)
    end
  end

  def feed_consume : Int32
    if attacking_now?
      pet_level_data.pet_feed_battle
    else
      pet_level_data.pet_feed_normal
    end
  end

  def self.spawn_pet(template : L2NpcTemplate, owner : L2PcInstance, control : L2ItemInstance) : L2PetInstance?
    sync do
      return if L2World.get_pet(owner.l2id)

      data = PetDataTable.get_pet_data(template.id)

      if pet = GameDB.pet.load(control, template, owner)
        pet.title = owner.name
        if data.sync_level? && pet.level != owner.level
          pet.stat.level = owner.level
          pet.stat.exp = pet.stat.get_exp_for_level(owner.level)
        end
        L2World.add_pet(owner.l2id, pet)
      end

      pet
    end
  end

  def summon_type : Int32
    2
  end

  def control_item : L2ItemInstance?
    owner.inventory.get_item_by_l2id(@control_l2id)
  end

  def current_feed=(num : Int32)
    if num <= 0
      send_packet(ExChangeNpcState.new(@l2id, 0x64))
    elsif @current_feed <= 0 && num > 0
      send_packet(ExChangeNpcState.new(@l2id, 0x65))
    end

    @current_feed = num > max_fed ? max_fed : num
  end

  def active_weapon_instance : L2ItemInstance?
    inventory.items.find do |item|
      item.item_location.pet_equip? &&
      item.template.body_part == L2Item::SLOT_R_HAND
    end
  end

  def active_weapon_item : L2Weapon?
    active_weapon_instance.try &.template.as(L2Weapon)
  end

  def destroy_item(process : String?, l2id : Int32, count : Int64, reference : L2Object?, send_msg : Bool) : Bool
    if item = inventory.get_item_by_l2id(l2id)
      item = inventory.destroy_item(process, item, count, owner, reference)
    end

    unless item
      if send_msg
        send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
      end

      return false
    end

    iu = PetInventoryUpdate.new
    iu.add_item(item)
    send_packet(iu)

    if send_msg
      if count > 1
        sm = SystemMessage.s2_s1_disappeared
        sm.add_item_name(item.id)
        sm.add_long(count)
        send_packet(sm)
      else
        sm = SystemMessage.s1_disappeared
        sm.add_item_name(item.id)
        send_packet(sm)
      end
    end

    true
  end

  def destroy_item_by_item_id(process : String?, item_id : Int32, count : Int64, reference, send_msg : Bool) : Bool
    item = inventory.destroy_item_by_item_id(process, item_id, count, owner, reference)

    unless item
      if send_msg
        send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
      end

      return false
    end

    iu = PetInventoryUpdate.new
    iu.add_item(item)
    send_packet(iu)

    if send_msg
      if count > 1
        sm = SystemMessage.s2_s1_disappeared
        sm.add_item_name(item.id)
        sm.add_long(count)
        send_packet(sm)
      else
        sm = SystemMessage.s1_disappeared
        sm.add_item_name(item.id)
        send_packet(sm)
      end
    end

    true
  end

  def do_pickup_item(target : L2Object)
    return if dead?

    set_intention(AI::IDLE)
    broadcast_packet(StopMove.new(self))

    unless target.is_a?(L2ItemInstance)
      action_failed
      return
    end

    follow = follow_status

    if CursedWeaponsManager.cursed?(target.id)
      sm = SystemMessage.failed_to_pickup_s1
      sm.add_item_name(target.id)
      send_packet(sm)
      return
    elsif FortSiegeManager.combat?(target.id)
      return
    end

    target.sync do
      unless target.visible?
        action_failed
        return
      end

      unless target.drop_protection.try_pick_up(self)
        action_failed
        sm = SystemMessage.failed_to_pickup_s1
        sm.add_item_name(target)
        send_packet(sm)
        return
      end

      party = party()

      if ((party && party.distribution_type.finders_keepers?) || !party) && !inventory.validate_capacity(target)
        action_failed
        send_packet(SystemMessageId::YOUR_PET_CANNOT_CARRY_ANY_MORE_ITEMS)
        return
      end

      if target.owner_id != 0 && target.owner_id != owner.l2id && !owner.in_looter_party?(target.owner_id)
        if target.id == Inventory::ADENA_ID
          sm = SystemMessage.failed_to_pickup_s1_adena
          sm.add_long(target.count)
        elsif target.count > 1
          sm = SystemMessage.failed_to_pickup_s2_s1_s
          sm.add_item_name(target)
          sm.add_long(target.count)
        else
          sm = SystemMessage.failed_to_pickup_s1
          sm.add_item_name(target)
        end

        action_failed
        send_packet(sm)
        return
      end

      if target.item_loot_schedule
        if target.owner_id == owner.l2id || owner.in_looter_party?(target.owner_id)
          target.reset_owner_timer
        end
      end

      target.pickup_me(self)

      if Config.save_dropped_item
        ItemsOnGroundManager.remove_object(target)
      end
    end

    if target.template.has_ex_immediate_effect?
      if handler = ItemHandler[target.etc_item]
        handler.use_item(self, target, false)
      end

      ItemTable.destroy_item("Consume", target, owner, nil)
      broadcast_status_update
    else
      if target.id == Inventory::ADENA_ID
        sm = SystemMessage.pet_picked_s1_adena
        sm.add_long(target.count)
      elsif target.enchant_level > 0
        sm = SystemMessage.pet_picked_s1_s2
        sm.add_int(target.enchant_level)
        sm.add_item_name(target)
      elsif target.count > 1
        sm = SystemMessage.pet_picked_s2_s1_s
        sm.add_long(target.count)
        sm.add_item_name(target)
      else
        sm = SystemMessage.pet_picked_s1
        sm.add_item_name(target)
      end
      send_packet(sm)

      if (party = owner.party) && !party.distribution_type.finders_keepers?
        party.distribute_item(owner, target)
      else
        item = inventory.add_item("Pickup", target, owner, self)
        send_packet(PetInventoryUpdate.new(item))
      end
    end

    set_intention(AI::IDLE)

    if follow
      follow_owner
    end
  end

  def delete_me(owner : L2PcInstance)
    inventory.transfer_items_to_owner
    super
    destroy_control_item(owner, false)
    SummonTable.pets.delete(owner().l2id)
  end

  def do_die(killer : L2Character?) : Bool
    if !owner.in_duel? && (!inside_pvp_zone? || inside_siege_zone?)
      death_penalty
    end

    return false unless super(killer, true)

    stop_feed
    send_packet(SystemMessageId::MAKE_SURE_YOU_RESSURECT_YOUR_PET_WITHIN_24_HOURS)
    DecayTaskManager.add(self)

    true
  end

  def do_revive(power : Float64)
    restore_exp(power)
    do_revive
  end

  def do_revive
    owner.remove_reviving

    super

    DecayTaskManager.cancel(self)
    start_feed
    unless hungry?
      set_running
    end
    set_intention(AI::ACTIVE)
  end

  def transfer_item(process : String?, l2id : Int32, count : Int64, target : ItemContainer?, actor : L2PcInstance, reference) : L2ItemInstance?
    old_item = inventory.get_item_by_l2id(l2id).not_nil!
    player_old_item = target.get_item_by_item_id(old_item.id)
    new_item = inventory.transfer_item(process, l2id, count, target, actor, reference)
    return unless new_item

    iu = PetInventoryUpdate.new
    if old_item.count > 0 && old_item != new_item
      iu.add_modified_item(old_item)
    else
      iu.add_removed_item(old_item)
    end
    send_packet(iu)

    if !new_item.stackable?
      send_packet(InventoryUpdate.added(new_item))
    elsif player_old_item && new_item.stackable?
      send_packet(InventoryUpdate.modified(new_item))
    end

    new_item
  end

  def destroy_control_item(owner : L2PcInstance, evolve : Bool)
    L2World.remove_pet(owner.l2id)

    begin
      if evolve
        removed_item = owner.inventory.destroy_item("Evolve", control_l2id, 1, owner(), self)
      else
        removed_item = owner.inventory.destroy_item("PetDestroy", control_l2id, 1, owner(), self)
        if removed_item
          sm = SystemMessage.s1_disappeared
          sm.add_item_name(removed_item)
          owner.send_packet(sm)
        end
      end

      if removed_item.nil?
        warn { "Couldn't destroy pet control item (owner: #{owner}, evolve: #{evolve})." }
      else
        owner.send_packet(InventoryUpdate.removed(removed_item))
        owner.send_packet(StatusUpdate.current_load(owner))
        owner.broadcast_user_info
        L2World.remove_object(removed_item)
      end
    rescue e
      error e
    end

    GameDB.pet.delete(self)
  end

  def drop_all_items
    inventory.items.safe_each { |item| drop_item_here(item) }
  end

  def drop_item_here(dropit : L2ItemInstance, protect : Bool = false)
    dropit = inventory.drop_item_id("Drop", dropit.l2id, dropit.count, @owner, self)
    if dropit
      if protect
        dropit.drop_protection.protect(@owner)
      end

      dropit.drop_me(self, x, y, z + 100)
    end
  end

  def stop_skill_effects(removed : Bool, skill_id : Int32)
    super
    SummonEffectsTable.remove_pet_effects(control_l2id, skill_id)
  end

  def store_me
    return if control_l2id == 0
    unless Config.restore_pet_on_reconnect
      self.restore_summon = false
    end

    if respawned?
      GameDB.pet.update(self)
    else
      GameDB.pet.insert(self)
    end

    self.respawned = true

    if restore_summon?
      SummonTable.pets[owner.l2id] = control_l2id
    else
      SummonTable.pets.delete(owner.l2id)
    end
  end

  def store_effect(store : Bool)
    return unless Config.summon_store_skill_cooltime
    SummonEffectsTable.clear_pet_effects(control_l2id)
    GameDB.pet_skill_save.insert(self, store)
  end

  def restore_effects
    GameDB.pet_skill_save.load(self)
    SummonEffectsTable.apply_pet_effects(self, control_l2id)
  end

  def stop_feed
    sync do
      if task = @feed_task
        task.cancel
        @feed_task = nil
      end
    end
  end

  def start_feed
    sync do
      if alive? && owner.summon == self
        task = ->feed_task
        @feed_task = ThreadPoolManager.schedule_general_at_fixed_rate(task, 10000, 10000)
      end
    end
  end

  def unsummon(owner : L2PcInstance)
    sync do
      stop_feed
      stop_hp_mp_regeneration

      super

      if alive?
        @inventory.try &.delete_me
        L2World.remove_pet(owner.l2id)
      end
    end
  end

  def restore_exp(percent : Float64)
    if @exp_before_death > 0
      exp = (((@exp_before_death - stat.exp) * percent) / 100).round.to_i64
      stat.add_exp(exp)
      @exp_before_death = 0i64
    end
  end

  private def death_penalty
    # L2J doesn't have much faith in the accuracy of this
    lvl = stat.level
    percent_lost = (-0.07 * lvl) + 6.5
    lost_exp = (((stat.get_exp_for_level(lvl + 1) - stat.get_exp_for_level(lvl)) * percent_lost) / 100).round
    @exp_before_death = stat.exp
    stat.remove_exp(lost_exp.to_i64)
  end

  def add_exp(exp : Int64)
    stat.add_exp(exp)
  end

  def get_exp_for_level(level : Int32) : Int64
    stat.get_exp_for_level(level)
  end

  def add_exp_and_sp(exp : Int64, sp : Int32)
    if sin_eater?
      stat.add_exp_and_sp((exp * Config.sineater_xp_rate).round.to_i64, sp)
    else
      stat.add_exp_and_sp((exp * Config.pet_xp_rate).round.to_i64, sp)
    end
  end

  def exp : Int64
    stat.exp
  end

  def exp=(exp : Int64)
    stat.exp = exp
  end

  def exp_for_this_level : Int64
    stat.get_exp_for_level(level)
  end

  def exp_for_next_level : Int64
    stat.get_exp_for_level(level &+ 1)
  end

  def level : Int32
    stat.level
  end

  def sp=(sp : Int32)
    stat.sp = sp
  end

  def min_level : Int32
    PetDataTable.get_pet_min_level(template.id)
  end

  def add_level(value : Int32) : Bool
    if level &+ value > stat.max_level
      return false
    end

    level_increased = stat.add_level(value)
    on_level_change(level_increased)
    level_increased
  end

  def on_level_change(level_increased : Bool)
    pet = stat.active_char
    su = StatusUpdate.level_max_hp_mp(pet, level, max_hp, max_mp)
    pet.broadcast_packet(su)

    if level_increased
      pet.broadcast_packet(SocialAction.level_up(l2id))
    end

    pet.update_and_broadcast_status(1)

    pet.control_item.try &.enchant_level = level
  end

  def max_fed : Int32
    stat.max_feed
  end

  def update_ref_owner(owner : L2PcInstance)
    old_owner_id = owner().l2id
    @owner = owner
    L2World.remove_pet(old_owner_id)
    L2World.add_pet(old_owner_id, self) # shouldn't this use the new owner's id?
  end

  def inventory_limit : Int32
    Config.inventory_maximum_pet
  end

  def refresh_overloaded
    max_load = max_load()
    if max_load > 0
      weight_proc = ((current_load - bonus_weight_penalty) * 100) / max_load
      new_weight_penalty = case
      when weight_proc < 500 || owner.diet_mode?
        0
      when weight_proc < 666
        1
      when weight_proc < 800
        2
      when weight_proc < 1000
        3
      else
        4
      end

      if @cur_weight_penalty != new_weight_penalty
        @cur_weight_penalty = new_weight_penalty
        if new_weight_penalty > 0
          add_skill(SkillData[4270, new_weight_penalty])
          self.overloaded = current_load >= max_load
        else
          remove_skill(get_known_skill(4270), true)
          self.overloaded = false
        end
      end
    end
  end

  def update_and_broadcast_status(val : Int32)
    refresh_overloaded
    super
  end

  def hungry? : Bool
    current_feed < pet_data.hungry_limit.fdiv(100) * pet_level_data.pet_max_feed
  end

  def uncontrollable? : Bool
    current_feed <= 0
  end

  def weapon : Int32
    inventory.rhand_slot.try &.id || 0
  end

  def armor : Int32
    inventory.chest_slot.try &.id || 0
  end

  def jewel : Int32
    inventory.neck_slot.try &.id || 0
  end

  def soulshots_per_hit : Int16
    pet_level_data.pet_soulshot
  end

  def spiritshots_per_hit : Int16
    pet_level_data.pet_spiritshot
  end

  def name=(name : String?)
    if control_item = control_item()
      if control_item.custom_type_2 == (name ? 0 : 1)
        control_item.custom_type_2 = (name ? 1 : 0)
        control_item.update_database
        send_packet(InventoryUpdate.modified(control_item))
      end
    else
      warn "No pet control item found."
    end

    super
  end

  def can_eat_food_id?(id : Int) : Bool
    pet_data.food.includes?(id)
  end

  def pet? : Bool
    true
  end

  def run_speed : Float64
    super * (uncontrollable? ? 0.5 : 1.0)
  end

  def walk_speed : Float64
    super * (uncontrollable? ? 0.5 : 1.0)
  end

  def movement_speed_multiplier : Float64
    super * (uncontrollable? ? 0.5 : 1.0)
  end

  def move_speed : Float64
    if inside_water_zone?
      running? ? swim_run_speed : swim_walk_speed
    else
      running? ? run_speed : walk_speed
    end
  end

  def max_load : Int32
    calc_stat(
      Stats::WEIGHT_LIMIT,
      (BaseStats::CON.calc_bonus(self) * 34500 * Config.alt_weight_limit).floor,
      self
    ).to_i
  end

  def bonus_weight_penalty : Int32
    calc_stat(Stats::WEIGHT_PENALTY, 1, self).to_i
  end

  def current_load : Int32
    inventory.total_weight
  end

  def sin_eater? : Bool
    id == 12564
  end
end
