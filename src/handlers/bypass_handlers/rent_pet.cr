module BypassHandler::RentPet
  extend self
  extend BypassHandler

  private COST = {1800, 7200, 720000, 6480000}
  private RIDE_TIME = {30, 60, 600, 1900}

  def use_bypass(command, pc, target)
    return unless target.is_a?(L2MerchantInstance)
    return unless Config.allow_rentpet
    return false unless Config.list_pet_rent_npc.includes?(target.id)

    st = command.split
    st.shift

    if st.empty?
      msg = NpcHtmlMessage.new(target.l2id)
      msg.html = "<html><body>Pet Manager:<br>You can rent a wyvern or strider for adena.<br>My prices:<br1><table border=0><tr><td>Ride</td></tr><tr><td>Wyvern</td><td>Strider</td></tr><tr><td><a action=\"bypass -h npc_%objectId%_RentPet 1\">30 sec/1800 adena</a></td><td><a action=\"bypass -h npc_%objectId%_RentPet 11\">30 sec/900 adena</a></td></tr><tr><td><a action=\"bypass -h npc_%objectId%_RentPet 2\">1 min/7200 adena</a></td><td><a action=\"bypass -h npc_%objectId%_RentPet 12\">1 min/3600 adena</a></td></tr><tr><td><a action=\"bypass -h npc_%objectId%_RentPet 3\">10 min/720000 adena</a></td><td><a action=\"bypass -h npc_%objectId%_RentPet 13\">10 min/360000 adena</a></td></tr><tr><td><a action=\"bypass -h npc_%objectId%_RentPet 4\">30 min/6480000 adena</a></td><td><a action=\"bypass -h npc_%objectId%_RentPet 14\">30 min/3240000 adena</a></td></tr></table></body></html>"
      msg["%objectId%"] = target.l2id
      pc.send_packet(msg)
    else
      try_rent_pet(pc, st.shift.to_i)
    end

    true
  end

  private def try_rent_pet(pc, val)
    return unless pc
    return if pc.has_summon? || pc.mounted? || pc.rented_pet?
    return if pc.transformed? || pc.cursed_weapon_equipped?
    return unless pc.disarm_weapons

    price = 1.0

    if val > 10
      pet_id = 12526
      val &-= 10
      price /= 2
    else
      pet_id = 12621
    end

    return if val < 1 || val > 4

    price *= COST[val &- 1]
    time = RIDE_TIME[val &- 1]

    return unless pc.reduce_adena("Rent", price.to_i64, pc.last_folk_npc, true)

    pc.mount(pet_id, 0, false)
    sg = SetupGauge.green(time * 1000)
    pc.send_packet(sg)
    pc.start_rent_pet(time)
  end

  def commands
    {"RentPet"}
  end
end
