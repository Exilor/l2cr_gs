struct FameTask
  initializer pc: L2PcInstance, value: Int32

  def call
    if @pc.dead? && !Config.fame_for_dead_players
      return
    end

    client = @pc.client?

    if client.nil? || (client.detached? && !Config.offline_fame)
      return
    end

    @pc.fame += @value
    sm = Packets::Outgoing::SystemMessage.acquired_s1_reputation_score
    sm.add_int(@value)
    @pc.send_packet(sm)
    @pc.send_packet(Packets::Outgoing::UserInfo.new(@pc))
  end
end
