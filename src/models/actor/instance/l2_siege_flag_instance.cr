class L2SiegeFlagInstance < L2Npc
  @can_talk = false
  getter? advanced_headquarter = false
  getter! clan : L2Clan
  getter! siege : Siegable

  def initialize(pc : L2PcInstance, template : L2NpcTemplate, advanced : Bool, outpost : Bool)
    super(template)

    if TerritoryWarManager.tw_in_progress?
      @clan = pc.clan
      @can_talk = false
      if outpost
        self.invul = true
      else
        @advanced_headquarter = advanced
        self.invul = false
      end

      status
      return
    end

    @clan = pc.clan
    @can_talk = true
    @siege = SiegeManager.get_siege(*pc.xyz)
    @siege ||= FortSiegeManager.get_siege(*pc.xyz)
    @siege ||= ClanHallSiegeManager.get_siege(pc)

    unless @clan && @siege
      raise "Initialization failed @clan.nil?: #{@clan.nil?}, @siege.nil?: #{@siege.nil?}"
    end

    unless sc = siege.get_attacker_clan?(clan)
      raise "Cannot find siege clan for #{@clan}"
    end

    sc.add_flag(self)
    @advanced = advanced
    status
    self.invul = false
  end

  def initialize(template : L2NpcTemplate)
    super
    raise "This constructor must not be called"
  end

  def instance_type : InstanceType
    InstanceType::L2SiegeFlagInstance
  end
end
