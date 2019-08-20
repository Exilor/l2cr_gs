class ListenersContainer
end

abstract class L2Object < ListenersContainer
end

abstract class L2Character < L2Object
end

abstract class L2Playable < L2Character
end

class L2PcInstance < L2Playable
end

abstract class L2Summon < L2Playable
end

class L2ServitorInstance < L2Summon
end

class L2PetInstance < L2Summon
end

abstract class L2Npc < L2Character
end

abstract class L2Attackable < L2Npc
end

class L2MonsterInstance < L2Attackable
end

class L2FriendlyMobInstance < L2Attackable
end

class L2RaidBossInstance < L2MonsterInstance
end

class L2GrandBossInstance < L2MonsterInstance
end

class L2RiftInvaderInstance < L2MonsterInstance
end

class L2FestivalMonsterInstance < L2MonsterInstance
end

class L2FestivalGuideInstance < L2Npc
end

class L2ControllableMobInstance < L2MonsterInstance
end

abstract class L2Decoy < L2Character
end

class L2DecoyInstance < L2Decoy
end

abstract class L2Vehicle < L2Character
end

class L2BoatInstance < L2Vehicle
end

class L2AirshipInstance < L2Vehicle
end

class L2DoorInstance < L2Character
end

class L2Spawn
end

class L2GroupSpawn < L2Spawn
end

#

abstract class AI
end

class L2CharacterAI < AI
end

class L2AttackableAI < L2CharacterAI
end

module Packets
  module Outgoing
  end

  module Incoming
  end
end
