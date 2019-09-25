struct WaterTask
  initializer pc : L2PcInstance

  def call
    hp = Math.max(@pc.max_hp / 100.0, 1.0)
    @pc.reduce_current_hp(hp, @pc, false, false, nil)
    sm = Packets::Outgoing::SystemMessage.drown_damage_s1
    sm.add_int(hp.to_i)
    @pc.send_packet(sm)
  end
end
