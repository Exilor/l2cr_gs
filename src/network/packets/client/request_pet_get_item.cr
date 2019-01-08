class Packets::Incoming::RequestPetGetItem < GameClientPacket
  @l2id = 0

  def read_impl
    @l2id = d
  end

  def run_impl
    return unless pc = active_char

    item = L2World.find_object(@l2id)
    if !item || !pc.has_pet?
      action_failed
      return
    end

    pet = pc.summon!.as(L2PetInstance)

    castle_id = MercTicketManager.get_ticket_castle_id(item.id)
    if castle_id > 0
      action_failed
      return
    end

    if FortSiegeManager.combat?(item.id)
      action_failed
      return
    end

    if pet.dead? || pet.out_of_control?
      action_failed
      return
    end

    if pet.uncontrollable?
      send_packet(SystemMessageId::WHEN_YOUR_PETS_HUNGER_GAUGE_IS_AT_0_YOU_CANNOT_USE_YOUR_PET)
      return
    end

    pet.set_intention(AI::PICK_UP, item)
  end
end
