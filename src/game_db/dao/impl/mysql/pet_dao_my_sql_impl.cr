module GameDB
  module PetDAOMySQLImpl
    extend self
    extend PetDAO

    private UPDATE_FOOD = "UPDATE pets SET fed=? WHERE item_obj_id=?"
    private DELETE = "DELETE FROM pets WHERE item_obj_id=?"
    private INSERT = "INSERT INTO pets (name,level,curHp,curMp,exp,sp,fed,ownerId,restore,item_obj_id) VALUES (?,?,?,?,?,?,?,?,?,?)"
    private UPDATE = "UPDATE pets SET name=?,level=?,curHp=?,curMp=?,exp=?,sp=?,fed=?,ownerId=?,restore=? WHERE item_obj_id=?"
    private SELECT = "SELECT item_obj_id, name, level, curHp, curMp, exp, sp, fed FROM pets WHERE item_obj_id=?"

    def update_food(pc : L2PcInstance, pet_id : Int32)
      if pc.control_item_id != 0 && pet_id != 0
        GameDB.exec(UPDATE_FOOD, pc.current_feed, pc.control_item_id)
        pc.control_item_id = 0
      end
    rescue e
      error e
    end

    def delete(pet : L2PetInstance)
      GameDB.exec(DELETE, pet.control_l2id)
    rescue e
      error e
    end

    def load(control : L2ItemInstance, template : L2NpcTemplate, owner : L2PcInstance) : L2PetInstance?
      GameDB.each(SELECT, control.l2id) do |rs|
        pet = L2PetInstance.new(template, owner, control, rs.get_i32("level"))
        pet.respawned = true
        # pet.name = rs.get_string?("name")
        if name = rs.get_string?("name")
          pet.name = name
        else
          debug "#{pet} has no name in DB."
        end

        exp = rs.get_i64("exp")
        info = PetDataTable.get_pet_level_data(pet.id, pet.level)
        if info && exp < info.pet_max_exp
          exp = info.pet_max_exp
        end

        pet.exp = exp
        pet.sp = rs.get_i32("sp")
        pet.status.current_hp = rs.get_f64("curHp")
        pet.status.current_mp = rs.get_f64("curMp")
        pet.status.current_cp = pet.max_cp.to_f64
        if rs.get_f64("curHp") < 1
          pet.dead = true
          pet.stop_hp_mp_regeneration
        end

        pet.current_feed = rs.get_i32("fed")

        return pet
      end

      L2PetInstance.new(template, owner, control) #
    rescue e
      error e
      nil
    end

    def insert(pet : L2PetInstance)
      insert_or_update(pet, INSERT)
    end

    def update(pet : L2PetInstance)
      insert_or_update(pet, UPDATE)
    end

    private def insert_or_update(pet, sql)
      GameDB.exec(
        sql,
        pet.name,
        pet.level,
        pet.status.current_hp,
        pet.status.current_mp,
        pet.exp,
        pet.sp,
        pet.current_feed,
        pet.owner.l2id,
        pet.restore_summon?.to_s,
        pet.control_l2id
      )
    rescue e
      error e
    end
  end
end
