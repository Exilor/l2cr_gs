module Evolve
  extend self
  extend Loggable
  include Packets::Outgoing

  def do_evolve(pc : L2PcInstance, npc : L2Npc, item_id_take : Int32, item_id_give : Int32, pet_min_lvl : Int32) : Bool
    if item_id_take == 0 || item_id_give == 0 || pet_min_lvl == 0
      return false
    end

    unless pet = pc.summon.as?(L2PetInstance)
      return false
    end

    if pet.looks_dead?
      Util.punish(pc, "tried to evolve a dead pet.")
      return false
    end

    pet_exp = pet.exp
    old_name = pet.name
    old_x, old_y, old_z = pet.xyz

    unless old_data = PetDataTable.get_pet_data_by_item_id(item_id_take)
      return false
    end

    old_npc_id = old_data.npc_id

    if pet.stat.level < pet_min_lvl || pet.id != old_npc_id
      return false
    end

    unless pet_data = PetDataTable.get_pet_data_by_item_id(item_id_give)
      return false
    end

    npc_id = pet_data.npc_id

    if npc_id == 0
      return false
    end

    npc_template = NpcData[npc_id]

    pet.unsummon(pc)

    pet.destroy_control_item(pc, true)

    item = pc.inventory.add_item("Evolve", item_id_give, 1, pc, npc).not_nil!
    unless pet_summon = L2PetInstance.spawn_pet(npc_template, pc, item)
      return false
    end

    minimum_exp = pet_summon.stat.get_exp_for_level(pet_min_lvl)
    if pet_exp < minimum_exp
      pet_exp = minimum_exp
    end

    # Adding exp before setting current_feed causes #add_exp to fail because the
    # pet is uncontrollable due to having 0 current_feed. This doesn't happen in
    # L2J but I don't know why.
    pet_summon.current_feed = pet_summon.max_fed
    pet_summon.add_exp(pet_exp)
    pet_summon.heal!
    pet_summon.title = pc.name
    pet_summon.name = old_name
    pet_summon.set_running
    pet_summon.store_me

    pc.pet = pet_summon

    pc.send_packet(MagicSkillUse.new(npc, 2046, 1, 1000, 600_000))
    pc.send_packet(SystemMessageId::SUMMON_A_PET)

    pet_summon.spawn_me(old_x, old_y, old_z)
    pet_summon.start_feed
    item.enchant_level = pet_summon.level

    ThreadPoolManager.schedule_general(EvolveFinalizer.new(pc, pet_summon), 900)

    if pet_summon.current_feed <= 0
      ThreadPoolManager.schedule_general(EvolveFeedWait.new(pc, pet_summon), 60_000)
    else
      pet_summon.start_feed
    end

    true
  end

  def do_restore(pc : L2PcInstance, npc : L2Npc, item_id_take : Int32, item_id_give : Int32, pet_min_lvl : Int32) : Bool
    if item_id_take == 0 || item_id_give == 0 || pet_min_lvl == 0
      return false
    end

    unless item = pc.inventory.get_item_by_item_id(item_id_take)
      return false
    end

    old_pet_lvl = item.enchant_level
    if old_pet_lvl < pet_min_lvl
      old_pet_lvl = pet_min_lvl
    end

    unless PetDataTable.get_pet_data_by_item_id(item_id_take)
      return false
    end

    unless pet_data = PetDataTable.get_pet_data_by_item_id(item_id_give)
      return false
    end

    npc_id = pet_data.npc_id
    if npc_id == 0
      return false
    end

    npc_template = NpcData[npc_id]

    removed_item = pc.inventory.destroy_item("PetRestore", item, pc, npc).not_nil!
    sm = SystemMessage.s1_disappeared
    sm.add_item_name(removed_item)
    pc.send_packet(sm)

    added_item = pc.inventory.add_item("PetRestore", item_id_give, 1, pc, npc).not_nil!

    unless pet_summon = L2PetInstance.spawn_pet(npc_template, pc, added_item)
      return false
    end

    max_exp = pet_summon.get_exp_for_level(old_pet_lvl)

    pet_summon.add_exp(max_exp)
    pet_summon.heal!
    pet_summon.current_feed = pet_summon.max_fed
    pet_summon.title = pc.name
    pet_summon.set_running
    pet_summon.store_me

    pc.pet = pet_summon

    pc.send_packet(MagicSkillUse.new(npc, 2046, 1, 1000, 600_000))
    pc.send_packet(SystemMessageId::SUMMON_A_PET)
    pet_summon.spawn_me(*pc.xyz)
    pet_summon.start_feed
    added_item.enchant_level = pet_summon.level

    pc.send_packet(InventoryUpdate.removed(removed_item))
    pc.send_packet(StatusUpdate.current_load(pc))

    pc.broadcast_user_info

    L2World.remove_object(removed_item)

    ThreadPoolManager.schedule_general(EvolveFinalizer.new(pc, pet_summon), 900)

    if pet_summon.current_feed <= 0
      ThreadPoolManager.schedule_general(EvolveFeedWait.new(pc, pet_summon), 60_000)
    else
      pet_summon.start_feed
    end

    begin
      sql = "DELETE FROM pets WHERE item_obj_id=?"
      GameDB.exec(sql, removed_item.l2id)
    rescue e
      error e
    end

    true
  end

  private struct EvolveFeedWait
    include Loggable

    initializer pc : L2PcInstance, pet : L2PetInstance

    def call
      if @pet.current_feed <= 0
        @pet.unsummon(@pc)
      else
        @pet.start_feed
      end
    rescue e
      error e
    end
  end

  private struct EvolveFinalizer
    include Loggable

    initializer pc : L2PcInstance, pet : L2PetInstance

    def call
      @pc.send_packet(MagicSkillLaunched.new(@pc, 2046, 1))
      @pet.follow_status = true
      @pet.show_summon_animation = false
    rescue e
      error e
    end
  end
end
