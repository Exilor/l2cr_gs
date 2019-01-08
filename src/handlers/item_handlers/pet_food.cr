module ItemHandler::PetFood
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    if playable.is_a?(L2PetInstance) && !playable.can_eat_food_id?(item.id)
      playable.send_packet(SystemMessageId::PET_CANNOT_USE_ITEM)
      return false
    end

    if skills = item.template.skills
      skills.each { |sk| use_food(playable, sk.skill_id, sk.skill_lvl, item) }
    end

    true
  end

  def use_food(char, skill_id, skill_lvl, item)
    return false unless skill = SkillData[skill_id, skill_lvl]?

    if pet = char.as?(L2PetInstance)
      if pet.destroy_item("Consume", item.l2id, 1, nil, false)
        msu = MagicSkillUse.new(pet, pet, skill_id, skill_id, 0, 0)
        pet.broadcast_packet(msu)
        skill.apply_effects(pet, pet)
        pet.broadcast_status_update
        if pet.hungry?
          pet.send_packet(SystemMessageId::YOUR_PET_ATE_A_LITTLE_BUT_IS_STILL_HUNGRY)
        end
        return true
      end
    elsif char.player?
      pc = char.acting_player
      if pc.mounted?
        food_ids = PetDataTable.get_pet_data(pc.mount_npc_id).not_nil!.food
        if food_ids.includes?(item.id)
          if pc.destroy_item("Consume", item.l2id, 1, nil, false)
            msu = MagicSkillUse.new(pc, pc, skill_id, skill_lvl, 0, 0)
            pc.broadcast_packet(msu)
            skill.apply_effects(pc, pc)
            return true
          end
        end
      end

      sm = SystemMessage.s1_cannot_be_used
      sm.add_item_name(item)
      pc.send_packet(sm)
    end

    false
  end
end
