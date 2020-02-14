module SummonTable
  extend self
  extend Loggable

  private PETS = Concurrent::Map(Int32, Int32).new
  private SERVITORS = Concurrent::Map(Int32, Int32).new

  private INIT_PET = "SELECT ownerId, item_obj_id FROM pets WHERE restore = 'true'"
  private INIT_SUMMONS = "SELECT ownerId, summonSkillId FROM character_summons"
  private LOAD_SUMMON = "SELECT curHp, curMp, time FROM character_summons WHERE ownerId = ? AND summonSkillId = ?"
  private REMOVE_SUMMON = "DELETE FROM character_summons WHERE ownerId = ?"
  private SAVE_SUMMON = "REPLACE INTO character_summons (ownerId,summonSkillId,curHp,curMp,time) VALUES (?,?,?,?,?)"

  def load
    if Config.restore_servitor_on_reconnect
      GameDB.each(INIT_SUMMONS) do |rs|
        owner_id = rs.get_i32("ownerId")
        skill_id = rs.get_i32("summonSkillId")
        SERVITORS[owner_id] = skill_id
      end

      info { "Restored #{SERVITORS.size} servitors." }
    else
      info "Restoration of servitors is disabled."
    end

    if Config.restore_pet_on_reconnect
      GameDB.each(INIT_PET) do |rs|
        owner_id = rs.get_i32("ownerId")
        item_id = rs.get_i32("item_obj_id")
        PETS[owner_id] = item_id
      end

      info { "Restored #{PETS.size} pets." }
    else
      info "Restoration of pets is disabled."
    end
  end

  def remove_servitor(pc : L2PcInstance)
    SERVITORS.delete(pc.l2id)
    GameDB.exec(REMOVE_SUMMON, pc.l2id)
  end

  def restore_pet(pc : L2PcInstance)
    obj_id = PETS[pc.l2id]
    unless item = pc.inventory.get_item_by_l2id(obj_id)
      warn { "No pet summoning item found with l2id #{obj_id}." }
      return
    end

    unless data = PetDataTable.get_pet_data_by_item_id(item.id)
      warn { "No pet data found for item #{item}." }
      return
    end

    unless template = NpcData[data.npc_id]?
      warn { "No NPC template found with ID #{data.npc_id}." }
      return
    end

    unless pet = L2PetInstance.spawn_pet(template, pc, item)
      warn { "Pet couldn't be restored (template: #{template}, pc: #{pc}, item: #{item})." }
      return
    end

    pet.show_summon_animation = true
    pet.title = pc.name

    unless pet.respawned?
      pet.heal!
      pet.stat.exp = pet.exp_for_this_level
      pet.current_feed = pet.max_fed
    end

    pet.set_running

    unless pet.respawned?
      pet.store_me
    end

    item.enchant_level = pet.level
    pc.pet = pet
    pet.spawn_me(pc.x + 50, pc.y + 100, pc.z)
    pet.start_feed
    pet.follow_status = true
    pil = Packets::Outgoing::PetItemList.new(pet.inventory.items)
    pet.owner.send_packet(pil)
    pet.broadcast_status_update
  end

  def restore_servitor(pc : L2PcInstance)
    skill_id = SERVITORS[pc.l2id]

    GameDB.each(LOAD_SUMMON, pc.l2id, skill_id) do |rs|
      cur_hp = rs.get_i32("curHp")
      cur_mp = rs.get_i32("curMp")
      time = rs.get_i32("time")
      unless skill = SkillData[skill_id, pc.get_skill_level(skill_id)]?
        remove_servitor(pc)
        return
      end
      skill.apply_effects(pc, pc)
      if pc.has_servitor?
        summon = pc.summon.as(L2ServitorInstance)
        summon.current_hp = cur_hp.to_f
        summon.current_mp = cur_mp.to_f
        summon.original_hp_mp = {cur_hp.to_f, cur_mp.to_f}
        summon.life_time_remaining = time
      end
    end
  end

  def save_summon(summon : L2ServitorInstance?)
    return unless summon
    return if summon.life_time_remaining <= 0
    SERVITORS[summon.owner.l2id] = summon.reference_skill

    GameDB.exec(
      SAVE_SUMMON,
      summon.owner.l2id,
      summon.reference_skill,
      summon.current_hp.to_i32,
      summon.current_mp.to_i32,
      summon.life_time_remaining
    )

    debug { "Saved #{summon}." }
  end

  def pets : IHash(Int32, Int32)
    PETS
  end

  def servitors : IHash(Int32, Int32)
    SERVITORS
  end
end
