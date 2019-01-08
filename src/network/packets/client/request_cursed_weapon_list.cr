class Packets::Incoming::RequestCursedWeaponList < GameClientPacket
  no_action_request

  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char

    list = CursedWeaponsManager.cursed_weapons_ids
    pc.send_packet(ExCursedWeaponList.new(list))
  end
end
