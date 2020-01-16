class Participant
  getter l2id : Int32
  getter name : String
  getter side : Int32
  getter base_class : Int32
  getter clan_name : String
  getter clan_id : Int32
  getter! stats : StatsSet
  property! player : L2PcInstance?
  property? defaulted : Bool = false
  property? disconnected : Bool = false

  def initialize(pc : L2PcInstance, olympiad_side : Int32)
    @l2id = pc.l2id
    @player = pc
    @name = pc.name
    @side = olympiad_side
    @base_class = pc.base_class
    @stats = Olympiad.get_noble_stats(@l2id)
    clan = pc.clan
    @clan_name = clan ? clan.name : ""
    @clan_id = pc.clan_id
  end

  def initialize(l2id : Int32, olympiad_side : Int32)
    @l2id = l2id
    @name = "-"
    @side = olympiad_side
    @base_class = 0
    @clan_name = ""
    @clan_id = 0
  end

  def update_player : Bool
    pc = @player

    if pc.nil? || !pc.online?
      @player = L2World.get_player(l2id)
    end

    !!@player
  end

  def update_stat(stat_name : String, increment : Int32)
    stats[stat_name] = Math.max(stats.get_i32(stat_name) + increment, 0)
  end
end
