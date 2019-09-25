class Packets::Outgoing::EtcStatusUpdate < GameServerPacket
  initializer pc : L2PcInstance

  def write_impl
    c 0xf9

    d @pc.charges
    d @pc.weight_penalty
    d (@pc.message_refusal? || @pc.chat_banned? || @pc.silence_mode?) ? 1 : 0
    d @pc.inside_danger_area_zone? ? 1 : 0
    d @pc.expertise_weapon_penalty
    d @pc.expertise_armor_penalty
    d @pc.charm_of_courage? ? 1 : 0
    d @pc.death_penalty_buff_level
    d @pc.charged_souls
  end
end
