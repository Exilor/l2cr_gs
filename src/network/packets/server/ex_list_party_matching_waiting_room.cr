class Packets::Outgoing::ExListPartyMatchingWaitingRoom < GameServerPacket
  private TOTAL = 64

  @total_matching_players : Int32

  def initialize(page : Int32, min_lvl : Int32, max_lvl : Int32, classes : Set(Int32), filter : String)
    @players = PartyMatchWaitingList.find_players(min_lvl, max_lvl, classes, filter)
    @total_matching_players = @players.size
    @players = @players.skip((page - 1) * TOTAL)[0..page * TOTAL]
  end

  private def write_impl
    c 0xfe
    h 0x36

    d @total_matching_players
    d @players.size
    @players.each do |pc|
      s pc.name
      d pc.active_class
      d pc.level
      d MapRegionManager.get_map_region(pc).not_nil!.bbs
      instances = InstanceManager.get_all_instance_times(pc.l2id)
      d instances.size
      instances.each_key do |id|
        d id
      end
    end
  end
end
