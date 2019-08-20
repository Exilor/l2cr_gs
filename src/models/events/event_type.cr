# require "./base_event"
# require "./returns/*"
# require "./event_dispatcher"

# class EventType < EnumClass
#   getter event_class, return_class

#   protected def initialize(@event_class : (BaseEvent.class)? = nil, @return_class : AbstractEventReturn.class | Nil.class = Nil.class)
#   end

#   private macro def_event(name, event_class = nil, return_class = Nil, &block)
#     {% if event_class %}
#       class ::{{event_class.id}} < BaseEvent

#         {{block.body if block}}

#         def type : EventType
#           EventType::{{name.id}}
#         end

#         def notify(container  : ListenersContainer? = nil) {{(" : #{return_class}?".id) if return_class}}
#           EventDispatcher.notify(self, container, {{return_class.id}})
#         end

#         def async
#           EventDispatcher.async(self)
#         end

#         def async(*containers : ListenersContainer)
#           EventDispatcher.async(self, *containers)
#         end

#         def delayed(container : ListenersContainer, delay : Int64)
#           EventDispatcher.delayed(self, container, delay)
#         end
#       end
#     {% end %}

#     add({{name}}, {{event_class}}.as?(BaseEvent.class), {{return_class}})
#   end


#   # Attackable events
#   def_event(ON_ATTACKABLE_AGGRO_RANGE_ENTER, OnAttackableAggroRangeEnter) do
#     getter npc, active_char
#     getter? summon
#     initializer npc: L2Npc, active_char: L2PcInstance, summon: Bool
#   end
#   def_event(ON_ATTACKABLE_ATTACK, OnAttackableAttack) do
#     getter target, damage, skill
#     getter attacker
#     getter? summon
#     initializer attacker: L2PcInstance, target: L2Attackable, damage: Int32,
#       skill: Skill?, summon: Bool
#   end
#   def_event(ON_ATTACKABLE_FACTION_CALL, OnAttackableFactionCall) do
#     getter npc, caller, attacker
#     getter? summon
#     initializer npc: L2Npc, caller: L2Npc, attacker: L2PcInstance, summon: Bool
#   end
#   def_event(ON_ATTACKABLE_KILL, OnAttackableKill) do
#     getter target
#     getter attacker
#     getter? summon
#     initializer attacker: L2PcInstance, target: L2Attackable, summon: Bool
#   end
#   # Castle events
#   def_event(ON_CASTLE_SIEGE_FINISH, OnCastleSiegeFinish) do
#     getter_initializer siege: Siege
#   end
#   def_event(ON_CASTLE_SIEGE_OWNER_CHANGE, OnCastleSiegeOwnerChange) do
#     getter_initializer siege: Siege
#   end
#   def_event(ON_CASTLE_SIEGE_START, OnCastleSiegeStart) do
#     getter_initializer siege: Siege
#   end

#   # Clan events
#   def_event(ON_CLAN_WAR_FINISH, OnClanWarFinish) do
#     getter_initializer clan1: L2Clan, clan2: L2Clan
#   end
#   def_event(ON_CLAN_WAR_START, OnClanWarStart) do
#     getter_initializer clan1: L2Clan, clan2: L2Clan
#   end

#   # Creature events
#   def_event(ON_CREATURE_ATTACK, OnCreatureAttack, TerminateReturn) do
#     getter_initializer attacker: L2Character, target: L2Character
#   end
#   def_event(ON_CREATURE_ATTACK_AVOID, OnCreatureAttackAvoid) do
#     getter attacker, target
#     getter? damage_over_time
#     initializer attacker: L2Character, target: L2Character,
#       damage_over_time: Bool
#   end
#   def_event(ON_CREATURE_ATTACKED, OnCreatureAttacked, TerminateReturn) do
#     getter_initializer attacker: L2Character, target: L2Character
#   end
#   def_event(ON_CREATURE_DAMAGE_RECEIVED, OnCreatureDamageReceived) do
#     getter attacker, target, damage, skill
#     getter? critical, damage_over_time, reflect
#     initializer attacker: L2Character, target: L2Character, damage: Float64,
#       skill: Skill?, critical: Bool, damage_over_time: Bool, reflect: Bool
#   end
#   def_event(ON_CREATURE_DAMAGE_DEALT, OnCreatureDamageDealt) do
#     getter attacker, target, damage, skill
#     getter? critical, damage_over_time, reflect
#     initializer attacker: L2Character, target: L2Character, damage: Float64,
#       skill: Skill?, critical: Bool, damage_over_time: Bool, reflect: Bool
#   end
#   def_event(ON_CREATURE_KILL, OnCreatureKill, TerminateReturn) do
#     getter! attacker
#     getter target
#     initializer attacker: L2Character?, target: L2Character
#   end
#   def_event(ON_CREATURE_SKILL_USE, OnCreatureSkillUse, TerminateReturn) do
#     getter caster, skill, target, targets
#     getter? simultaneously
#     initializer caster: L2Character, skill: Skill, simultaneously: Bool,
#       target: L2Character, targets: Array(L2Object)?
#   end
#   def_event(ON_CREATURE_TELEPORTED, OnCreatureTeleported) do
#     getter_initializer creature: L2Character
#   end
#   def_event(ON_CREATURE_ZONE_ENTER, OnCreatureZoneEnter) do
#     getter_initializer creature: L2Character, zone: L2ZoneType
#   end
#   def_event(ON_CREATURE_ZONE_EXIT, OnCreatureZoneExit) do
#     getter_initializer creature: L2Character, zone: L2ZoneType
#   end

#   # Fortress events
#   def_event(ON_FORT_SIEGE_FINISH, OnFortSiegeFinish) do
#     getter_initializer siege: FortSiege
#   end
#   def_event(ON_FORT_SIEGE_START, OnFortSiegeStart) do
#     getter_initializer siege: FortSiege
#   end

#   # Item events
#   def_event(ON_ITEM_BYPASS_EVENT, OnItemBypassEvent) do
#     getter_initializer item: L2ItemInstance, active_char: L2PcInstance,
#       event: String
#   end
#   def_event(ON_ITEM_CREATE, OnItemCreate) do
#     getter_initializer process: String?, item: L2ItemInstance,
#       active_char: L2PcInstance?, reference: String | L2Object? # reference should be Object
#   end
#   def_event(ON_ITEM_TALK, OnItemTalk) do
#     getter_initializer item: L2ItemInstance, active_char: L2PcInstance
#   end

#   # NPC events
#   def_event(ON_NPC_CAN_BE_SEEN, OnNpcCanBeSeen, TerminateReturn) do
#     getter_initializer npc: L2Npc, active_char: L2PcInstance
#   end
#   def_event(ON_NPC_CREATURE_SEE, OnNpcCreatureSee) do
#     getter npc, creature
#     getter? summon
#     initializer npc: L2Npc, creature: L2Character, summon: Bool
#   end
#   def_event(ON_NPC_EVENT_RECEIVED, OnNpcEventReceived) do
#     getter_initializer event_name: String, sender: L2Npc, receiver: L2Npc,
#       reference: L2Object?
#   end
#   def_event(ON_NPC_FIRST_TALK, OnNpcFirstTalk) do
#     getter_initializer npc: L2Npc, active_char: L2PcInstance
#   end
#   def_event(ON_NPC_HATE, OnAttackableHate, TerminateReturn) do
#     getter npc, active_char
#     getter? summon
#     initializer npc: L2Npc, active_char: L2PcInstance, summon: Bool
#   end
#   def_event(ON_NPC_MOVE_FINISHED, OnNpcMoveFinished) do
#     getter_initializer npc: L2Npc
#   end
#   def_event(ON_NPC_MOVE_NODE_ARRIVED, OnNpcMoveNodeArrived) do
#     getter_initializer npc: L2Npc
#   end
#   def_event(ON_NPC_MOVE_ROUTE_FINISHED, OnNpcMoveRouteFinished) do
#     getter_initializer npc: L2Npc
#   end
#   def_event(ON_NPC_QUEST_START)
#   def_event(ON_NPC_SKILL_FINISHED, OnNpcSkillFinished) do
#     getter_initializer caster: L2Npc, target: L2PcInstance, skill: Skill
#   end
#   def_event(ON_NPC_SKILL_SEE, OnNpcSkillSee) do
#     getter target, caster, skill, targets
#     getter? summon
#     initializer target: L2Npc, caster: L2PcInstance, skill: Skill,
#       targets: Array(L2Object), summon: Bool
#   end
#   def_event(ON_NPC_SPAWN, OnNpcSpawn) do
#     getter_initializer npc: L2Npc
#   end
#   def_event(ON_NPC_TALK)
#   def_event(ON_NPC_TELEPORT, OnNpcTeleport) do
#     getter_initializer npc: L2Npc
#   end
#   def_event(ON_NPC_MANOR_BYPASS, OnNpcManorBypass) do
#     getter active_char, target, request, manor_id
#     getter? next_period
#     initializer active_char: L2PcInstance, target: L2Npc, request: Int32,
#       manor_id: Int32, next_period: Bool
#   end

#   # Olympiad events
#   def_event(ON_OLYMPIAD_MATCH_RESULT, OnOlympiadMatchResult) do
#     getter_initializer winner: Participant?, loser: Participant,
#       competition_type: CompetitionType
#   end

#   # Playable events
#   def_event(ON_PLAYABLE_EXP_CHANGED, OnPlayableExpChanged, TerminateReturn) do
#     getter_initializer active_char: L2Playable, old_exp: Int64, new_exp: Int64
#   end

#   # Player events
#   def_event(ON_PLAYER_AUGMENT, OnPlayerAugment) do
#     getter active_char, item, augmentation
#     getter? augment
#     initializer active_char: L2PcInstance, item: L2ItemInstance,
#       augmentation: L2Augmentation, augment: Bool
#   end
#   def_event(ON_PLAYER_BYPASS, OnPlayerBypass) do
#     getter_initializer active_char: L2PcInstance, command: String
#   end
#   def_event(ON_PLAYER_CHAT, OnPlayerChat, ChatFilterReturn) do
#     getter_initializer active_char: L2PcInstance, target: L2PcInstance,
#       text: String, chat_type: Int32
#   end

#   # Tutorial events (new feature in l2j)
#   def_event(ON_PLAYER_TUTORIAL_EVENT, OnPlayerTutorialEvent) do
#     getter_initializer active_char: L2PcInstance, command: String
#   end
#   def_event(ON_PLAYER_TUTORIAL_CMD, OnPlayerTutorialCmd) do
#     getter_initializer active_char: L2PcInstance, command: String
#   end
#   def_event(ON_PLAYER_TUTORIAL_CLIENT_EVENT, OnPlayerTutorialClientEvent) do
#     getter_initializer active_char: L2PcInstance, event: Int32
#   end
#   def_event(ON_PLAYER_TUTORIAL_QUESTION_MARK, OnPlayerTutorialQuestionMark) do
#     getter_initializer active_char: L2PcInstance, number: Int32
#   end

#   # Clan events
#   def_event(ON_PLAYER_CLAN_CREATE, OnPlayerClanCreate) do
#     getter_initializer active_char: L2PcInstance, clan: L2Clan
#   end
#   def_event(ON_PLAYER_CLAN_DESTROY, OnPlayerClanDestroy) do
#     getter_initializer active_char: L2ClanMember?, clan: L2Clan
#   end
#   def_event(ON_PLAYER_CLAN_JOIN, OnPlayerClanJoin) do
#     getter_initializer active_char: L2PcInstance, clan: L2Clan
#   end
#   def_event(ON_PLAYER_CLAN_LEADER_CHANGE, OnPlayerClanLeaderChange) do
#     getter_initializer old_leader: L2ClanMember, new_leader: L2ClanMember,
#       clan: L2Clan
#   end
#   def_event(ON_PLAYER_CLAN_LEFT, OnPlayerClanLeft) do
#     getter_initializer active_char: L2ClanMember, clan: L2Clan
#   end
#    # L2J takes {active_char: L2PcInstance, :clan] but only uses :clan}
#   def_event(ON_PLAYER_CLAN_LVLUP, OnPlayerClanLvlUp) do
#     getter_initializer clan: L2Clan
#   end

#   # Clan warehouse events
#   def_event(ON_PLAYER_CLAN_WH_ITEM_ADD, OnPlayerClanWHItemAdd) do
#     getter_initializer process: String?, active_char: L2PcInstance,
#       item: L2ItemInstance, container: ItemContainer
#   end
#   def_event(ON_PLAYER_CLAN_WH_ITEM_DESTROY, OnPlayerClanWHItemDestroy) do
#     getter_initializer process: String?, active_char: L2PcInstance,
#       item: L2ItemInstance, count: Int64, container: ItemContainer
#   end
#   def_event(ON_PLAYER_CLAN_WH_ITEM_TRANSFER, OnPlayerClanWHItemTransfer) do
#     getter_initializer process: String?, active_char: L2PcInstance,
#       item: L2ItemInstance, count: Int64, container: ItemContainer
#   end
#   def_event(ON_PLAYER_CREATE, OnPlayerCreate) do
#     getter_initializer active_char: L2PcInstance, l2id: Int32, name: String,
#       client: GameClient
#   end
#   def_event(ON_PLAYER_DELETE, OnPlayerDelete) do
#     getter_initializer l2id: Int32, name: String, client: GameClient
#   end
#   def_event(ON_PLAYER_DLG_ANSWER, OnPlayerDlgAnswer, TerminateReturn) do
#     getter_initializer active_char: L2PcInstance, message_id: Int32,
#       answer: Int32, requester_id: Int32
#   end
#   def_event(ON_PLAYER_EQUIP_ITEM, OnPlayerEquipItem) do
#     getter_initializer active_char: L2PcInstance, item: L2ItemInstance
#   end
#   def_event(ON_PLAYER_FAME_CHANGED, OnPlayerFameChanged) do
#     getter_initializer active_char: L2PcInstance, old_fame: Int32,
#       new_fame: Int32
#   end

#   # Henna events
#   def_event(ON_PLAYER_HENNA_ADD, OnPlayerHennaAdd) do
#     getter_initializer active_char: L2PcInstance, henna: L2Henna
#   end
#   def_event(ON_PLAYER_HENNA_REMOVE, OnPlayerHennaRemove) do
#     getter_initializer active_char: L2PcInstance, henna: L2Henna
#   end

#   # Inventory events
#   def_event(ON_PLAYER_ITEM_ADD, OnPlayerItemAdd) do
#     getter_initializer active_char: L2PcInstance, item: L2ItemInstance
#   end
#   def_event(ON_PLAYER_ITEM_DESTROY, OnPlayerItemDestroy) do
#     getter_initializer active_char: L2PcInstance, item: L2ItemInstance
#   end
#   def_event(ON_PLAYER_ITEM_DROP, OnPlayerItemDrop) do
#     getter_initializer active_char: L2PcInstance, item: L2ItemInstance,
#       location: Location
#   end
#   def_event(ON_PLAYER_ITEM_PICKUP, OnPlayerItemPickup) do
#     getter_initializer active_char: L2PcInstance, item: L2ItemInstance
#   end
#   def_event(ON_PLAYER_ITEM_TRANSFER, OnPlayerItemTransfer) do
#     getter_initializer active_char: L2PcInstance, item: L2ItemInstance,
#       container: ItemContainer
#   end

#   # Other player events
#   def_event(ON_PLAYER_KARMA_CHANGED, OnPlayerKarmaChanged) do
#     getter_initializer active_char: L2PcInstance, old_karma: Int32,
#       new_karma: Int32
#   end
#   def_event(ON_PLAYER_LEVEL_CHANGED, OnPlayerLevelChanged) do
#     getter_initializer active_char: L2PcInstance, old_level: Int8,
#       new_level: Int8
#   end
#   def_event(ON_PLAYER_LOGIN, OnPlayerLogin) do
#     getter_initializer active_char: L2PcInstance
#   end
#   def_event(ON_PLAYER_LOGOUT, OnPlayerLogout) do
#     getter_initializer active_char: L2PcInstance
#   end
#   def_event(ON_PLAYER_PK_CHANGED, OnPlayerPKChanged) do
#     getter_initializer active_char: L2PcInstance, old_points: Int32,
#       new_points: Int32
#   end
#   def_event(ON_PLAYER_PROFESSION_CHANGE, OnPlayerProfessionChange) do
#     getter active_char, template
#     getter? subclass
#     initializer active_char: L2PcInstance, template: L2PcTemplate,
#       subclass: Bool
#   end
#   def_event(ON_PLAYER_PROFESSION_CANCEL, OnPlayerProfessionCancel) do
#     getter_initializer active_char: L2PcInstance, class_id: Int32
#   end
#   def_event(ON_PLAYER_PVP_CHANGED, OnPlayerPvPChanged) do
#     getter_initializer active_char: L2PcInstance, old_points: Int32,
#       new_points: Int32
#   end
#   def_event(ON_PLAYER_PVP_KILL, OnPlayerPvPKill) do
#     getter_initializer active_char: L2PcInstance, target: L2PcInstance
#   end
#   def_event(ON_PLAYER_RESTORE, OnPlayerRestore) do
#     getter_initializer l2id: Int32, name: String, client: GameClient
#   end
#   def_event(ON_PLAYER_SELECT, OnPlayerSelect, TerminateReturn) do
#     getter_initializer active_char: L2PcInstance, l2id: Int32, name: String,
#       client: GameClient
#   end
#   def_event(ON_PLAYER_SKILL_LEARN, OnPlayerSkillLearn) do
#     getter_initializer trainer: L2Npc, active_char: L2PcInstance, skill: Skill,
#       acquire_type: AcquireSkillType
#   end
#   def_event(ON_PLAYER_SUMMON_SPAWN, OnPlayerSummonSpawn) do
#     getter_initializer summon: L2Summon
#   end
#   def_event(ON_PLAYER_SUMMON_TALK, OnPlayerSummonTalk) do
#     getter_initializer summon: L2Summon
#   end
#   def_event(ON_PLAYER_TRANSFORM, OnPlayerTransform) do
#     getter_initializer active_char: L2PcInstance, transform_id: Int32
#   end
#   def_event(ON_PLAYER_SIT, OnPlayerSit, TerminateReturn) do
#     getter_initializer active_char: L2PcInstance
#   end
#   def_event(ON_PLAYER_STAND, OnPlayerStand, TerminateReturn) do
#     getter_initializer active_char: L2PcInstance
#   end

#   # Trap events
#   def_event(ON_TRAP_ACTION, OnTrapAction) do
#     getter_initializer trap: L2TrapInstance, trigger: L2Character,
#       action: TrapAction
#   end

#   # TvT events.
#   def_event(ON_TVT_EVENT_FINISH, OnTvTEventFinish)
#   def_event(ON_TVT_EVENT_KILL, OnTvTEventKill) do
#     getter_initializer killer: L2PcInstance, victim: L2PcInstance,
#       killer_team: TvTEventTeam
#   end
#   def_event(ON_TVT_EVENT_REGISTRATION_START, OnTvTEventRegistrationStart)
#   def_event(ON_TVT_EVENT_START, OnTvTEventStart)
# end













require "./base_event"
require "./returns/*"
require "./event_dispatcher"

class EventType
  getter event_class, return_class

  protected def initialize(@event_class : (BaseEvent.class)? = nil, @return_class : AbstractEventReturn.class | Nil.class = Nil.class)
  end

  private macro def_event(name, event_class = nil, return_class = Nil, &block)
    {% if event_class %}
      class ::{{event_class.id}} < BaseEvent
        {{block.body if block}}

        def type : EventType
          EventType::{{name.id}}
        end

        def notify(container  : ListenersContainer? = nil) {{(" : #{return_class}?".id) if return_class}}
          EventDispatcher.notify(self, container, {{return_class.id}})
        end

        def async
          EventDispatcher.async(self)
        end

        def async(*containers : ListenersContainer)
          EventDispatcher.async(self, *containers)
        end

        def delayed(container : ListenersContainer, delay : Int64)
          EventDispatcher.delayed(self, container, delay)
        end
      end
    {% end %}

    {{name}} = new({{event_class}}, {{return_class}})
  end

  # Attackable events
  def_event(ON_ATTACKABLE_AGGRO_RANGE_ENTER, OnAttackableAggroRangeEnter) do
    getter npc, active_char
    getter? summon
    initializer npc: L2Npc, active_char: L2PcInstance, summon: Bool
  end
  def_event(ON_ATTACKABLE_ATTACK, OnAttackableAttack) do
    getter target, damage, skill
    getter attacker
    getter? summon
    initializer attacker: L2PcInstance, target: L2Attackable, damage: Int32,
      skill: Skill?, summon: Bool
  end
  def_event(ON_ATTACKABLE_FACTION_CALL, OnAttackableFactionCall) do
    getter npc, caller, attacker
    getter? summon
    initializer npc: L2Npc, caller: L2Npc, attacker: L2PcInstance, summon: Bool
  end
  def_event(ON_ATTACKABLE_KILL, OnAttackableKill) do
    getter target
    getter attacker
    getter? summon
    initializer attacker: L2PcInstance, target: L2Attackable, summon: Bool
  end
  # Castle events
  def_event(ON_CASTLE_SIEGE_FINISH, OnCastleSiegeFinish) do
    getter_initializer siege: Siege
  end
  def_event(ON_CASTLE_SIEGE_OWNER_CHANGE, OnCastleSiegeOwnerChange) do
    getter_initializer siege: Siege
  end
  def_event(ON_CASTLE_SIEGE_START, OnCastleSiegeStart) do
    getter_initializer siege: Siege
  end

  # Clan events
  def_event(ON_CLAN_WAR_FINISH, OnClanWarFinish) do
    getter_initializer clan1: L2Clan, clan2: L2Clan
  end
  def_event(ON_CLAN_WAR_START, OnClanWarStart) do
    getter_initializer clan1: L2Clan, clan2: L2Clan
  end

  # Creature events
  def_event(ON_CREATURE_ATTACK, OnCreatureAttack, TerminateReturn) do
    getter_initializer attacker: L2Character, target: L2Character
  end
  def_event(ON_CREATURE_ATTACK_AVOID, OnCreatureAttackAvoid) do
    getter attacker, target
    getter? damage_over_time
    initializer attacker: L2Character, target: L2Character,
      damage_over_time: Bool
  end
  def_event(ON_CREATURE_ATTACKED, OnCreatureAttacked, TerminateReturn) do
    getter_initializer attacker: L2Character, target: L2Character
  end
  def_event(ON_CREATURE_DAMAGE_RECEIVED, OnCreatureDamageReceived) do
    getter attacker, target, damage, skill
    getter? critical, damage_over_time, reflect
    initializer attacker: L2Character, target: L2Character, damage: Float64,
      skill: Skill?, critical: Bool, damage_over_time: Bool, reflect: Bool
  end
  def_event(ON_CREATURE_DAMAGE_DEALT, OnCreatureDamageDealt) do
    getter attacker, target, damage, skill
    getter? critical, damage_over_time, reflect
    initializer attacker: L2Character, target: L2Character, damage: Float64,
      skill: Skill?, critical: Bool, damage_over_time: Bool, reflect: Bool
  end
  def_event(ON_CREATURE_KILL, OnCreatureKill, TerminateReturn) do
    getter! attacker
    getter target
    initializer attacker: L2Character?, target: L2Character
  end
  def_event(ON_CREATURE_SKILL_USE, OnCreatureSkillUse, TerminateReturn) do
    getter caster, skill, target, targets
    getter? simultaneously
    initializer caster: L2Character, skill: Skill, simultaneously: Bool,
      target: L2Character, targets: Array(L2Object)?
  end
  def_event(ON_CREATURE_TELEPORTED, OnCreatureTeleported) do
    getter_initializer creature: L2Character
  end
  def_event(ON_CREATURE_ZONE_ENTER, OnCreatureZoneEnter) do
    getter_initializer creature: L2Character, zone: L2ZoneType
  end
  def_event(ON_CREATURE_ZONE_EXIT, OnCreatureZoneExit) do
    getter_initializer creature: L2Character, zone: L2ZoneType
  end

  # Fortress events
  def_event(ON_FORT_SIEGE_FINISH, OnFortSiegeFinish) do
    getter_initializer siege: FortSiege
  end
  def_event(ON_FORT_SIEGE_START, OnFortSiegeStart) do
    getter_initializer siege: FortSiege
  end

  # Item events
  def_event(ON_ITEM_BYPASS_EVENT, OnItemBypassEvent) do
    getter_initializer item: L2ItemInstance, active_char: L2PcInstance,
      event: String
  end
  def_event(ON_ITEM_CREATE, OnItemCreate) do
    getter_initializer process: String?, item: L2ItemInstance,
      active_char: L2PcInstance?, reference: String | L2Object? # reference should be Object
  end
  def_event(ON_ITEM_TALK, OnItemTalk) do
    getter_initializer item: L2ItemInstance, active_char: L2PcInstance
  end

  # NPC events
  def_event(ON_NPC_CAN_BE_SEEN, OnNpcCanBeSeen, TerminateReturn) do
    getter_initializer npc: L2Npc, active_char: L2PcInstance
  end
  def_event(ON_NPC_CREATURE_SEE, OnNpcCreatureSee) do
    getter npc, creature
    getter? summon
    initializer npc: L2Npc, creature: L2Character, summon: Bool
  end
  def_event(ON_NPC_EVENT_RECEIVED, OnNpcEventReceived) do
    getter_initializer event_name: String, sender: L2Npc, receiver: L2Npc,
      reference: L2Object?
  end
  def_event(ON_NPC_FIRST_TALK, OnNpcFirstTalk) do
    getter_initializer npc: L2Npc, active_char: L2PcInstance
  end
  def_event(ON_NPC_HATE, OnAttackableHate, TerminateReturn) do
    getter npc, active_char
    getter? summon
    initializer npc: L2Npc, active_char: L2PcInstance, summon: Bool
  end
  def_event(ON_NPC_MOVE_FINISHED, OnNpcMoveFinished) do
    getter_initializer npc: L2Npc
  end
  def_event(ON_NPC_MOVE_NODE_ARRIVED, OnNpcMoveNodeArrived) do
    getter_initializer npc: L2Npc
  end
  def_event(ON_NPC_MOVE_ROUTE_FINISHED, OnNpcMoveRouteFinished) do
    getter_initializer npc: L2Npc
  end
  def_event(ON_NPC_QUEST_START)
  def_event(ON_NPC_SKILL_FINISHED, OnNpcSkillFinished) do
    getter_initializer caster: L2Npc, target: L2PcInstance, skill: Skill
  end
  def_event(ON_NPC_SKILL_SEE, OnNpcSkillSee) do
    getter target, caster, skill, targets
    getter? summon
    initializer target: L2Npc, caster: L2PcInstance, skill: Skill,
      targets: Array(L2Object), summon: Bool
  end
  def_event(ON_NPC_SPAWN, OnNpcSpawn) do
    getter_initializer npc: L2Npc
  end
  def_event(ON_NPC_TALK)
  def_event(ON_NPC_TELEPORT, OnNpcTeleport) do
    getter_initializer npc: L2Npc
  end
  def_event(ON_NPC_MANOR_BYPASS, OnNpcManorBypass) do
    getter active_char, target, request, manor_id
    getter? next_period
    initializer active_char: L2PcInstance, target: L2Npc, request: Int32,
      manor_id: Int32, next_period: Bool
  end

  # Olympiad events
  def_event(ON_OLYMPIAD_MATCH_RESULT, OnOlympiadMatchResult) do
    getter_initializer winner: Participant?, loser: Participant,
      competition_type: CompetitionType
  end

  # Playable events
  def_event(ON_PLAYABLE_EXP_CHANGED, OnPlayableExpChanged, TerminateReturn) do
    getter_initializer active_char: L2Playable, old_exp: Int64, new_exp: Int64
  end

  # Player events
  def_event(ON_PLAYER_AUGMENT, OnPlayerAugment) do
    getter active_char, item, augmentation
    getter? augment
    initializer active_char: L2PcInstance, item: L2ItemInstance,
      augmentation: L2Augmentation, augment: Bool
  end
  def_event(ON_PLAYER_BYPASS, OnPlayerBypass) do
    getter_initializer active_char: L2PcInstance, command: String
  end
  def_event(ON_PLAYER_CHAT, OnPlayerChat, ChatFilterReturn) do
    getter_initializer active_char: L2PcInstance, target: L2PcInstance,
      text: String, chat_type: Int32
  end

  # Tutorial events (new feature in l2j)
  def_event(ON_PLAYER_TUTORIAL_EVENT, OnPlayerTutorialEvent) do
    getter_initializer active_char: L2PcInstance, command: String
  end
  def_event(ON_PLAYER_TUTORIAL_CMD, OnPlayerTutorialCmd) do
    getter_initializer active_char: L2PcInstance, command: String
  end
  def_event(ON_PLAYER_TUTORIAL_CLIENT_EVENT, OnPlayerTutorialClientEvent) do
    getter_initializer active_char: L2PcInstance, event: Int32
  end
  def_event(ON_PLAYER_TUTORIAL_QUESTION_MARK, OnPlayerTutorialQuestionMark) do
    getter_initializer active_char: L2PcInstance, number: Int32
  end

  # Clan events
  def_event(ON_PLAYER_CLAN_CREATE, OnPlayerClanCreate) do
    getter_initializer active_char: L2PcInstance, clan: L2Clan
  end
  def_event(ON_PLAYER_CLAN_DESTROY, OnPlayerClanDestroy) do
    getter_initializer active_char: L2ClanMember?, clan: L2Clan
  end
  def_event(ON_PLAYER_CLAN_JOIN, OnPlayerClanJoin) do
    getter_initializer active_char: L2PcInstance, clan: L2Clan
  end
  def_event(ON_PLAYER_CLAN_LEADER_CHANGE, OnPlayerClanLeaderChange) do
    getter_initializer old_leader: L2ClanMember, new_leader: L2ClanMember,
      clan: L2Clan
  end
  def_event(ON_PLAYER_CLAN_LEFT, OnPlayerClanLeft) do
    getter_initializer active_char: L2ClanMember, clan: L2Clan
  end
   # L2J takes {active_char: L2PcInstance, :clan] but only uses :clan}
  def_event(ON_PLAYER_CLAN_LVLUP, OnPlayerClanLvlUp) do
    getter_initializer clan: L2Clan
  end

  # Clan warehouse events
  def_event(ON_PLAYER_CLAN_WH_ITEM_ADD, OnPlayerClanWHItemAdd) do
    getter_initializer process: String?, active_char: L2PcInstance,
      item: L2ItemInstance, container: ItemContainer
  end
  def_event(ON_PLAYER_CLAN_WH_ITEM_DESTROY, OnPlayerClanWHItemDestroy) do
    getter_initializer process: String?, active_char: L2PcInstance,
      item: L2ItemInstance, count: Int64, container: ItemContainer
  end
  def_event(ON_PLAYER_CLAN_WH_ITEM_TRANSFER, OnPlayerClanWHItemTransfer) do
    getter_initializer process: String?, active_char: L2PcInstance,
      item: L2ItemInstance, count: Int64, container: ItemContainer
  end
  def_event(ON_PLAYER_CREATE, OnPlayerCreate) do
    getter_initializer active_char: L2PcInstance, l2id: Int32, name: String,
      client: GameClient
  end
  def_event(ON_PLAYER_DELETE, OnPlayerDelete) do
    getter_initializer l2id: Int32, name: String, client: GameClient
  end
  def_event(ON_PLAYER_DLG_ANSWER, OnPlayerDlgAnswer, TerminateReturn) do
    getter_initializer active_char: L2PcInstance, message_id: Int32,
      answer: Int32, requester_id: Int32
  end
  def_event(ON_PLAYER_EQUIP_ITEM, OnPlayerEquipItem) do
    getter_initializer active_char: L2PcInstance, item: L2ItemInstance
  end
  def_event(ON_PLAYER_FAME_CHANGED, OnPlayerFameChanged) do
    getter_initializer active_char: L2PcInstance, old_fame: Int32,
      new_fame: Int32
  end

  # Henna events
  def_event(ON_PLAYER_HENNA_ADD, OnPlayerHennaAdd) do
    getter_initializer active_char: L2PcInstance, henna: L2Henna
  end
  def_event(ON_PLAYER_HENNA_REMOVE, OnPlayerHennaRemove) do
    getter_initializer active_char: L2PcInstance, henna: L2Henna
  end

  # Inventory events
  def_event(ON_PLAYER_ITEM_ADD, OnPlayerItemAdd) do
    getter_initializer active_char: L2PcInstance, item: L2ItemInstance
  end
  def_event(ON_PLAYER_ITEM_DESTROY, OnPlayerItemDestroy) do
    getter_initializer active_char: L2PcInstance, item: L2ItemInstance
  end
  def_event(ON_PLAYER_ITEM_DROP, OnPlayerItemDrop) do
    getter_initializer active_char: L2PcInstance, item: L2ItemInstance,
      location: Location
  end
  def_event(ON_PLAYER_ITEM_PICKUP, OnPlayerItemPickup) do
    getter_initializer active_char: L2PcInstance, item: L2ItemInstance
  end
  def_event(ON_PLAYER_ITEM_TRANSFER, OnPlayerItemTransfer) do
    getter_initializer active_char: L2PcInstance, item: L2ItemInstance,
      container: ItemContainer
  end

  # Other player events
  def_event(ON_PLAYER_KARMA_CHANGED, OnPlayerKarmaChanged) do
    getter_initializer active_char: L2PcInstance, old_karma: Int32,
      new_karma: Int32
  end
  def_event(ON_PLAYER_LEVEL_CHANGED, OnPlayerLevelChanged) do
    getter_initializer active_char: L2PcInstance, old_level: Int8,
      new_level: Int8
  end
  def_event(ON_PLAYER_LOGIN, OnPlayerLogin) do
    getter_initializer active_char: L2PcInstance
  end
  def_event(ON_PLAYER_LOGOUT, OnPlayerLogout) do
    getter_initializer active_char: L2PcInstance
  end
  def_event(ON_PLAYER_PK_CHANGED, OnPlayerPKChanged) do
    getter_initializer active_char: L2PcInstance, old_points: Int32,
      new_points: Int32
  end
  def_event(ON_PLAYER_PROFESSION_CHANGE, OnPlayerProfessionChange) do
    getter active_char, template
    getter? subclass
    initializer active_char: L2PcInstance, template: L2PcTemplate,
      subclass: Bool
  end
  def_event(ON_PLAYER_PROFESSION_CANCEL, OnPlayerProfessionCancel) do
    getter_initializer active_char: L2PcInstance, class_id: Int32
  end
  def_event(ON_PLAYER_PVP_CHANGED, OnPlayerPvPChanged) do
    getter_initializer active_char: L2PcInstance, old_points: Int32,
      new_points: Int32
  end
  def_event(ON_PLAYER_PVP_KILL, OnPlayerPvPKill) do
    getter_initializer active_char: L2PcInstance, target: L2PcInstance
  end
  def_event(ON_PLAYER_RESTORE, OnPlayerRestore) do
    getter_initializer l2id: Int32, name: String, client: GameClient
  end
  def_event(ON_PLAYER_SELECT, OnPlayerSelect, TerminateReturn) do
    getter_initializer active_char: L2PcInstance, l2id: Int32, name: String,
      client: GameClient
  end
  def_event(ON_PLAYER_SKILL_LEARN, OnPlayerSkillLearn) do
    getter_initializer trainer: L2Npc, active_char: L2PcInstance, skill: Skill,
      acquire_type: AcquireSkillType
  end
  def_event(ON_PLAYER_SUMMON_SPAWN, OnPlayerSummonSpawn) do
    getter_initializer summon: L2Summon
  end
  def_event(ON_PLAYER_SUMMON_TALK, OnPlayerSummonTalk) do
    getter_initializer summon: L2Summon
  end
  def_event(ON_PLAYER_TRANSFORM, OnPlayerTransform) do
    getter_initializer active_char: L2PcInstance, transform_id: Int32
  end
  def_event(ON_PLAYER_SIT, OnPlayerSit, TerminateReturn) do
    getter_initializer active_char: L2PcInstance
  end
  def_event(ON_PLAYER_STAND, OnPlayerStand, TerminateReturn) do
    getter_initializer active_char: L2PcInstance
  end

  # Trap events
  def_event(ON_TRAP_ACTION, OnTrapAction) do
    getter_initializer trap: L2TrapInstance, trigger: L2Character,
      action: TrapAction
  end

  # TvT events.
  def_event(ON_TVT_EVENT_FINISH, OnTvTEventFinish)
  def_event(ON_TVT_EVENT_KILL, OnTvTEventKill) do
    getter_initializer killer: L2PcInstance, victim: L2PcInstance,
      killer_team: TvTEventTeam
  end
  def_event(ON_TVT_EVENT_REGISTRATION_START, OnTvTEventRegistrationStart)
  def_event(ON_TVT_EVENT_START, OnTvTEventStart)
end
