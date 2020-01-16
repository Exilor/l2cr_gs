class Scripts::SteelCitadelTeleport < AbstractNpcAI
  # NPCs
  private BELETH = 29118
  private NAIA_CUBE = 32376
  # Location
  private TELEPORT_CITADEL = Location.new(16342, 209557, -9352)

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(NAIA_CUBE)
    add_talk_id(NAIA_CUBE)
  end

  def on_talk(npc, player)
    beleth_status = GrandBossManager.get_boss_status(BELETH).not_nil!
    if beleth_status == 3
      return "32376-02.htm"
    end
    if beleth_status > 0
      return "32376-03.htm"
    end

    cc = player.party.try &.command_channel
    if cc.nil? || (cc.leader.l2id != player.l2id || cc.size < Config.beleth_min_players)
      return "32376-02a.htm"
    end

    zone = ZoneManager.get_zone_by_id(12018)
    if zone.is_a?(L2BossZone)
      GrandBossManager.set_boss_status(BELETH, 1)

      cc.each do |pl|
        if pl.inside_radius?(*npc.xyz, 3000, true, false)
          zone.allow_player_entry(pl, 30)
          pl.tele_to_location(TELEPORT_CITADEL, true)
        end
      end
    end

    nil
  end
end
