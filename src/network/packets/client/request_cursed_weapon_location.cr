class Packets::Incoming::RequestCursedWeaponLocation < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    list = [] of CursedWeaponInfo
    CursedWeaponsManager.cursed_weapons.each do |cw|
      if cw.active?
        if pos = cw.world_position
          list << CursedWeaponInfo.new(pos, cw.item_id, cw.activated? ? 1 : 0)
        end
      end
    end

    unless list.empty?
      pc.send_packet(ExCursedWeaponLocation.new(list))
    end
  end

  private record CursedWeaponInfo, pos : Location, id : Int32, status : Int32
end
