class InstanceType < EnumClass
  @type_l : Int64
  @type_h : Int64
  @mask_l : Int64
  @mask_h : Int64
  getter parent

  def initialize(@parent : self?)
    high = to_i64 - Int64::MAX - 1
    if high < 0
      @type_l = 1i64 << to_i
      @type_h = 0i64
    else
      @type_l = 0i64
      @type_h = 1i64 << high
    end

    if parent
      @mask_l = @type_l | parent.@mask_l
      @mask_h = @type_h | parent.@mask_h
    else
      @mask_l = @type_l
      @mask_h = @type_h
    end
  end

  def type?(it : self) : Bool
    @mask_l & it.@type_l > 0 || @mask_h & it.@type_h > 0
  end

  def types?(*types : self) : Bool
    types?(types)
  end

  def types?(types : Enumerable(self)) : Bool
    types.any? { |it| type?(it) }
  end

  add(L2Object, nil)
  add(L2ItemInstance, L2Object)
  add(L2Character, L2Object)
  add(L2Npc, L2Character)
  add(L2Playable, L2Character)
  add(L2Summon, L2Playable)
  add(L2Decoy, L2Character)
  add(L2PcInstance, L2Playable)
  add(L2NpcInstance, L2Npc)
  add(L2MerchantInstance, L2NpcInstance)
  add(L2WarehouseInstance, L2NpcInstance)
  add(L2StaticObjectInstance, L2Character)
  add(L2DoorInstance, L2Character)
  add(L2TerrainObjectInstance, L2Npc)
  add(L2EffectPointInstance, L2Npc)
  # Summons, Pets, Decoys and Traps
  add(L2ServitorInstance, L2Summon)
  add(L2PetInstance, L2Summon)
  add(L2BabyPetInstance, L2PetInstance) # deprecated
  add(L2DecoyInstance, L2Decoy)
  add(L2TrapInstance, L2Npc)
  # Attackable
  add(L2Attackable, L2Npc)
  add(L2GuardInstance, L2Attackable)
  add(L2QuestGuardInstance, L2GuardInstance)
  add(L2MonsterInstance, L2Attackable)
  add(L2ChestInstance, L2MonsterInstance)
  add(L2ControllableMobInstance, L2MonsterInstance)
  add(L2FeedableBeastInstance, L2MonsterInstance)
  add(L2TamedBeastInstance, L2FeedableBeastInstance)
  add(L2FriendlyMobInstance, L2Attackable)
  add(L2RiftInvaderInstance, L2MonsterInstance)
  add(L2RaidBossInstance, L2MonsterInstance)
  add(L2GrandBossInstance, L2RaidBossInstance)
  # FlyMobs
  add(L2FlyNpcInstance, L2NpcInstance) # unused
  add(L2FlyMonsterInstance, L2MonsterInstance) # unused
  add(L2FlyRaidBossInstance, L2RaidBossInstance) # unused
  add(L2FlyTerrainObjectInstance, L2Npc)
  # Sepulchers
  add(L2SepulcherNpcInstance, L2NpcInstance)
  add(L2SepulcherMonsterInstance, L2MonsterInstance)
  # Festival
  add(L2FestivalGuideInstance, L2Npc)
  add(L2FestivalMonsterInstance, L2MonsterInstance)
  # Vehicles
  add(L2Vehicle, L2Character)
  add(L2BoatInstance, L2Vehicle)
  add(L2AirShipInstance, L2Vehicle)
  add(L2ControllableAirShipInstance, L2AirShipInstance)
  # Siege
  add(L2DefenderInstance, L2Attackable)
  add(L2ArtefactInstance, L2NpcInstance)
  add(L2ControlTowerInstance, L2Npc)
  add(L2FlameTowerInstance, L2Npc)
  add(L2SiegeFlagInstance, L2Npc)
  # Fort Siege
  add(L2FortCommanderInstance, L2DefenderInstance)
  # Fort NPCs
  add(L2FortLogisticsInstance, L2MerchantInstance)
  add(L2FortManagerInstance, L2MerchantInstance)
  # Seven Signs
  add(L2SignsPriestInstance, L2Npc)
  add(L2DawnPriestInstance, L2SignsPriestInstance)
  add(L2DuskPriestInstance, L2SignsPriestInstance)
  add(L2DungeonGatekeeperInstance, L2Npc)
  # City NPCs
  add(L2AdventurerInstance, L2NpcInstance)
  add(L2AuctioneerInstance, L2Npc)
  add(L2ClanHallManagerInstance, L2MerchantInstance)
  add(L2FishermanInstance, L2MerchantInstance) # deprecated
  add(L2ObservationInstance, L2Npc)
  add(L2OlympiadManagerInstance, L2Npc)
  add(L2PetManagerInstance, L2MerchantInstance)
  add(L2RaceManagerInstance, L2Npc)
  add(L2TeleporterInstance, L2Npc)
  add(L2TrainerInstance, L2NpcInstance)
  add(L2VillageMasterInstance, L2NpcInstance)
  # Doormens
  add(L2DoormenInstance, L2NpcInstance)
  add(L2CastleDoormenInstance, L2DoormenInstance)
  add(L2FortDoormenInstance, L2DoormenInstance)
  add(L2ClanHallDoormenInstance, L2DoormenInstance)
  # Custom
  add(L2NpcBufferInstance, L2Npc)
  add(L2EventMobInstance, L2Npc)
end
