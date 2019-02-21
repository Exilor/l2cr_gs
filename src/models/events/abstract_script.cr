require "../../enums/listener_register_type"
require "./listeners/*"

abstract class AbstractScript
  include Synchronizable
  include Packets::Outgoing
  include Loggable
  extend Loggable

  private alias Say2 = Packets::Incoming::Say2

  property? active : Bool = false
  getter listeners = [] of AbstractEventListener
  @registered_ids = EnumMap(ListenerRegisterType, Set(Int32)).new

  def initialize
    initialize_annotation_listeners
  end

  private def set_attackable_kill_id(*id, &b : OnAttackableKill ->)
    register_consumer(EventType::ON_ATTACKABLE_KILL, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_attackable_attack_id(*id, &b : OnAttackableAttack ->)
    register_consumer(EventType::ON_ATTACKABLE_ATTACK, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def add_creature_kill_id(*id, &b : OnCreatureKill ->)
    register_function(EventType::ON_CREATURE_KILL, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_creature_kill_id(*id, &b : OnCreatureKill ->)
    register_consumer(EventType::ON_CREATURE_KILL, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_npc_first_talk_id(*id, &b : OnNpcFirstTalk ->)
    register_consumer(EventType::ON_NPC_FIRST_TALK, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_npc_talk_id(*id)
    register_dummy(EventType::ON_NPC_TALK, ListenerRegisterType::NPC, *id)
  end

  private def set_npc_teleport_id(*id, &b : OnNpcTeleport ->)
    register_consumer(EventType::ON_NPC_TELEPORT, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_npc_quest_start_id(*id)
    register_dummy(EventType::ON_NPC_QUEST_START, ListenerRegisterType::NPC, *id)
  end

  private def set_npc_skill_see_id(*id, &b : OnNpcSkillSee ->)
    register_consumer(EventType::ON_NPC_SKILL_SEE, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_npc_skill_finished_id(*id, &b : OnNpcSkillFinished ->)
    register_consumer(EventType::ON_NPC_SKILL_FINISHED, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_npc_spawn_id(*id, &b : OnNpcSpawn ->)
    register_consumer(EventType::ON_NPC_SPAWN, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_npc_event_received_id(*id, &b : OnNpcEventReceived ->)
    register_consumer(EventType::ON_NPC_EVENT_RECEIVED, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_npc_move_finished_id(*id, &b : OnNpcMoveFinished ->)
    register_consumer(EventType::ON_NPC_MOVE_FINISHED, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_npc_move_node_arrived_id(*id, &b : OnNpcMoveNodeArrived ->)
    register_consumer(EventType::ON_NPC_MOVE_NODE_ARRIVED, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_npc_move_route_finished_id(*id, &b : OnNpcMoveRouteFinished ->)
    register_consumer(EventType::ON_NPC_MOVE_ROUTE_FINISHED, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_npc_hate_id(*id, &b : OnAttackableHate ->)
    register_consumer(EventType::ON_NPC_HATE, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def add_npc_hate_id(*id, &b : OnAttackableHate -> TerminateReturn)
    register_function(EventType::ON_NPC_HATE, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, TerminateReturn)))
  end

  private def set_npc_can_be_seen_id(*id, &b : OnNpcCanBeSeen ->) # TerminateReturn! check them all
    register_function(EventType::ON_NPC_CAN_BE_SEEN, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, TerminateReturn)))
  end

  private def set_npc_creature_see_id(*id, &b : OnNpcCreatureSee ->)
    register_consumer(EventType::ON_NPC_CREATURE_SEE, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_attackable_faction_id_id(*id, &b : OnAttackableFactionCall ->)
    register_consumer(EventType::ON_ATTACKABLE_FACTION_CALL, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_attackable_aggro_range_enter_id(*id, &b : OnAttackableAggroRangeEnter ->)
    register_consumer(EventType::ON_ATTACKABLE_AGGRO_RANGE_ENTER, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_player_skill_learn_id(*id, &b : OnPlayerSkillLearn ->)
    register_consumer(EventType::ON_PLAYER_SKILL_LEARN, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_player_summon_spawn_id(*id, &b : OnPlayerSummonSpawn ->)
    register_consumer(EventType::ON_PLAYER_SUMMON_SPAWN, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_player_summon_talk_id(*id, &b : OnPlayerSummonTalk ->)
    register_consumer(EventType::ON_PLAYER_SUMMON_TALK, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_player_login_id(&b : OnPlayerLogin ->)
    register_consumer(EventType::ON_PLAYER_LOGIN, ListenerRegisterType::GLOBAL, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_player_logout_id(&b : OnPlayerLogout ->)
    register_consumer(EventType::ON_PLAYER_LOGOUT, ListenerRegisterType::GLOBAL, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_creature_zone_enter_id(*id, &b : OnCreatureZoneEnter ->)
    register_consumer(EventType::ON_CREATURE_ZONE_ENTER, ListenerRegisterType::ZONE, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_creature_zone_exit_id(*id, &b : OnCreatureZoneExit ->)
    register_consumer(EventType::ON_CREATURE_ZONE_EXIT, ListenerRegisterType::ZONE, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_trap_action_id(*id, &b : OnTrapAction ->)
    register_consumer(EventType::ON_TRAP_ACTION, ListenerRegisterType::NPC, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_item_bypass_event_id(*id, &b : OnItemBypassEvent ->)
    register_consumer(EventType::ON_ITEM_BYPASS_EVENT, ListenerRegisterType::ITEM, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_item_talk_id(*id, &b : OnItemTalk ->)
    register_consumer(EventType::ON_ITEM_TALK, ListenerRegisterType::ITEM, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_olympiad_match_result(&b : OnOlympiadMatchResult ->)
    register_consumer(EventType::ON_OLYMPIAD_MATCH_RESULT, ListenerRegisterType::OLYMPIAD, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_castle_siege_start_id(*id, &b : OnCastleSiegeStart ->)
    register_consumer(EventType::ON_CASTLE_SIEGE_START, ListenerRegisterType::CASTLE, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_castle_siege_owner_change_id(*id, &b : OnCastleSiegeOwnerChange ->)
    register_consumer(EventType::ON_CASTLE_SIEGE_OWNER_CHANGE, ListenerRegisterType::CASTLE, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_castle_siege_finish_id(*id, &b : OnCastleSiegeFinish ->)
    register_consumer(EventType::ON_CASTLE_SIEGE_FINISH, ListenerRegisterType::CASTLE, *id, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_player_profession_change_id(&b : OnPlayerProfessionChange ->)
    register_consumer(EventType::ON_PLAYER_PROFESSION_CHANGE, ListenerRegisterType::GLOBAL, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_player_profession_cancel_id(&b : OnPlayerProfessionCancel ->)
    register_consumer(EventType::ON_PLAYER_PROFESSION_CANCEL, ListenerRegisterType::GLOBAL, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  #

  private def set_player_tutorial_event(&b : OnPlayerTutorialEvent ->)
    register_consumer(EventType::ON_PLAYER_TUTORIAL_EVENT, ListenerRegisterType::GLOBAL, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_player_tutorial_client_event(&b : OnPlayerTutorialClientEvent ->)
    register_consumer(EventType::ON_PLAYER_TUTORIAL_CLIENT_EVENT, ListenerRegisterType::GLOBAL, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_player_tutorial_question_mark(&b : OnPlayerTutorialQuestionMark ->)
    register_consumer(EventType::ON_PLAYER_TUTORIAL_QUESTION_MARK, ListenerRegisterType::GLOBAL, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  private def set_player_tutorial_cmd(&b : OnPlayerTutorialCmd ->)
    register_consumer(EventType::ON_PLAYER_TUTORIAL_CMD, ListenerRegisterType::GLOBAL, &b.unsafe_as(Proc(BaseEvent, Nil)))
  end

  #

  private def register_consumer(event_type, register_type, *id, &b : BaseEvent ->)
    register_listener(register_type, *id) do |container|
      ConsumerEventListener.new(container, event_type, self, &b)
    end
  end

  private def register_function(event_type, register_type, *id, &b : BaseEvent -> AbstractEventReturn?)
    register_listener(register_type, *id) do |container|
      FunctionEventListener.new(container, event_type, self, &b.unsafe_as(Proc(BaseEvent, AbstractEventReturn?)))
    end
  end

  private def register_runnable(event_type, register_type, *id, &b)
    register_listener(register_type, *id) do |container|
      RunnableEventListener.new(container, event_type, self, &b)
    end
  end

  private def register_annotation(event_type, register_type, callback, priority, *id)
    # debug "Registering annotation #{event_type}."
    register_listener(register_type, *id) do |container|
      # debug "Registering annotation #{event_type} to #{container}."
      AnnotationEventListener.new(container, event_type, callback, self, priority)
    end
  end

  private def register_dummy(event_type, register_type, *id)
    register_listener(register_type, *id) do |container|
      DummyEventListener.new(container, event_type, self)
    end
  end

  private def register_listener(register_type : ListenerRegisterType, &block : ListenersContainer -> AbstractEventListener)
    register_listener(register_type, Slice(Int32).empty, &block)
  end

  private def register_listener(register_type : ListenerRegisterType, *ids : Int32, &block : ListenersContainer -> AbstractEventListener)
    register_listener(register_type, ids, &block)
  end

  private def register_listener(register_type : ListenerRegisterType, ids : Enumerable(Int32), &block : ListenersContainer -> AbstractEventListener)
    listeners = [] of AbstractEventListener

    if !ids.empty?
      ids.each do |id|
        case register_type
        when ListenerRegisterType::NPC
          if temp = NpcData[id]?
            listeners << temp.add_listener(block.call(temp))
          end
        when ListenerRegisterType::ZONE
          if temp = ZoneManager.get_zone_by_id(id)
            listeners << temp.add_listener(block.call(temp))
          end
        when ListenerRegisterType::ITEM
          if temp = ItemTable[id]?
            listeners << temp.add_listener(block.call(temp))
          end
        when ListenerRegisterType::CASTLE
          if temp = CastleManager.get_castle_by_id(id)
            listeners << temp.add_listener(block.call(temp))
          end
        when ListenerRegisterType::FORTRESS
          if temp = FortManager.get_fort_by_id(id)
            listeners << temp.add_listener(block.call(temp))
          end
        else
          warn "Unhandled register type #{register_type}."
        end

        set = @registered_ids[register_type] ||= Set(Int32).new
        set << id
      end
    else
      case register_type
      when ListenerRegisterType::OLYMPIAD
        warn "(AbstractScript) TODO: Register olympiad listener at line #{__LINE__}."
        # listeners << Olympiad.add_listener(block.call(Olympiad))
      when ListenerRegisterType::GLOBAL
        listeners << Containers::GLOBAL.add_listener(block.call(Containers::GLOBAL))
      when ListenerRegisterType::GLOBAL_NPCS
        listeners << Containers::NPCS.add_listener(block.call(Containers::NPCS))
      when ListenerRegisterType::GLOBAL_MONSTERS
        listeners << Containers::MONSTERS.add_listener(block.call(Containers::MONSTERS))
      when ListenerRegisterType::GLOBAL_PLAYERS
        listeners << Containers::PLAYERS.add_listener(block.call(Containers::PLAYERS))
      end
    end

    @listeners.concat(listeners)

    listeners
  end

  def get_registered_ids(reg_type : ListenerRegisterType)
    @registered_ids.fetch(reg_type, Slice(Int32).empty)
  end

  def self.show_on_screen_msg(pc : L2PcInstance, *args)
    pc.send_packet(ExShowScreenMessage.new(*args))
  end

  def show_on_screen_msg(*args)
    AbstractScript.show_on_screen_msg(*args)
  end

  def self.play_sound(pc : L2PcInstance, sound : IAudio) # Audio
    pc.send_packet(sound.packet)
  end

  def play_sound(*args)
    AbstractScript.play_sound(*args)
  end

  def self.give_items(pc : L2PcInstance, item_id : Int32, count : Int)
    give_items(pc, item_id, count.to_i64, 0)
  end

  def self.give_items(pc : L2PcInstance, holder : ItemHolder)
    give_items(pc, holder.id, holder.count)
  end

  def self.give_items(pc : L2PcInstance, item_id : Int32, count : Int, enchant_level : Int32)
    return if count <= 0

    item = pc.inventory.add_item("Quest", item_id, count, pc, pc.target)
    return unless item

    if enchant_level > 0 && item_id != Inventory::ADENA_ID
      item.enchant_level = enchant_level
    end

    send_item_get_message(pc, item, count)
  end

  def self.give_items(pc : L2PcInstance, item_id : Int32, count : Int, attribute_id : Int32, attribute_level : Int32)
    return if count <= 0

    item = pc.inventory.add_item("Quest", item_id, count, pc, pc.target)
    return unless item

    if attribute_id >= 0 && attribute_level > 0
      item.set_element_attr(attribute_id, attribute_level)
      if item.equipped?
        item.update_element_attr_bonus(pc)
      end
      pc.send_packet(InventoryUpdate.modified(item))
    end

    send_item_get_message(pc, item, count)
  end

  def self.give_items(pc : L2PcInstance, item : IDropItem, victim : L2Character)
    items = item.calculate_drops(victim, pc)
    if !items || items.empty?
      false
    else
      give_items pc, items
      true
    end
  end

  def self.give_items(pc : L2PcInstance, items : Enumerable(ItemHolder))
    items.each { |item| give_items(pc, item) }
  end

  def self.give_items(pc : L2PcInstance, item : ItemHolder, limit : Int) : Bool
    max_to_give = limit - pc.inventory.get_inventory_item_count(item.id, -1)
    if max_to_give <= 0
      false
    else
      give_items(pc, item.id, Math.min(max_to_give, item.count))
      true
    end
  end

  def self.give_items(pc : L2PcInstance, item : ItemHolder, limit : Int, play_sound : Bool)
    drop = give_items(pc, item, limit)

    if drop && play_sound
      play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    drop
  end

  def self.give_items(pc : L2PcInstance, items : Enumerable(ItemHolder), limit : Int)
    result = false
    items.each { |item| result |= give_items(pc, item, limit) }
    result
  end

  def self.give_items(pc : L2PcInstance, items : Enumerable(ItemHolder), limit : Int, play_sound : Bool)
    drop = give_items(pc, items, limit)

    if drop && play_sound
      play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    drop
  end

  def self.give_items(pc : L2PcInstance, item : IDropItem, victim : L2Character, limit : Int)
    give_items(pc, item.calculate_drops(victim, pc), limit)
  end

  def self.give_items(pc : L2PcInstance, item : IDropItem, victim : L2Character, limit : Int, play_sound : Bool)
    drop = give_items(pc, item, victim, limit)

    if drop && play_sound
      play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    drop
  end

  def give_items(*args)
    AbstractScript.give_items(*args)
  end

  def self.send_item_get_message(pc : L2PcInstance, item : L2ItemInstance, count : Int)
    if item.id == Inventory::ADENA_ID
      sm = SystemMessage.earned_s1_adena
      sm.add_long(count)
      pc.send_packet(sm)
    else
      if count > 1
        sm = SystemMessage.earned_s2_s1_s
        sm.add_item_name(item)
        sm.add_long(count)
        pc.send_packet(sm)
      else
        sm = SystemMessage.earned_item_s1
        sm.add_item_name(item)
        pc.send_packet(sm)
      end
    end

    pc.send_packet(StatusUpdate.current_load(pc))
  end

  def self.get_quest_items_count(pc : L2PcInstance, *item_id : Int32) : Int64
    get_quest_items_count(pc, item_id)
  end

  def self.get_quest_items_count(pc : L2PcInstance, item_id : Indexable(Int32)) : Int64
    if item_id.size > 1
      count = 0i64

      pc.inventory.items.each do |item|
        item_id.each do |id|
          if item.id == id
            if count + item.count > Int64::MAX
              return Int64::MAX
            end
            count += item.count
          end
        end
      end

      count
    else
      pc.inventory.get_inventory_item_count(item_id[0], -1).to_i64
    end
  end

  def get_quest_items_count(*args)
    AbstractScript.get_quest_items_count(*args)
  end

  def self.take_items(pc : L2PcInstance, item_id : Int32, amount : Int) : Bool
    items = pc.inventory.get_items_by_item_id(item_id)
    if amount < 0
      items.each { |i| take_item(pc, i, i.count) }
    else
      amount = amount.to_i64
      current_count = 0
      items.each do |i|
        to_delete = i.count
        if current_count + to_delete > amount
          to_delete = amount - current_count
        end
        take_item(pc, i, to_delete)
        current_count += to_delete
      end
    end

    true
  end

  def self.take_items(pc : L2PcInstance, holder : ItemHolder?) : Bool
    return false unless holder
    take_items(pc, holder.item_id, holder.count)
  end

  def self.take_items(pc : L2PcInstance, amount : Int, item_ids : Enumerable(Int32))
    check = true
    item_ids.each { |id| check &= take_items(pc, id, amount) }
    check
  end

  def take_items(*args)
    AbstractScript.take_items(*args)
  end

  def self.take_item(pc : L2PcInstance, item : L2ItemInstance, to_delete : Int64)
    if item.equipped?
      unequipped = pc.inventory.unequip_item_in_body_slot_and_record(item.template.body_part)
      iu = InventoryUpdate.new
      unequipped.each { |itm| iu.add_modified_item(itm) }
      pc.send_packet(iu)
      pc.broadcast_user_info
    end

    pc.destroy_item_by_item_id("Quest", item.id, to_delete, pc, true)
  end

  def self.take_item(pc : L2PcInstance, holder : ItemHolder?) : Bool
    return false unless holder
    take_items(pc, holder.id, holder.count)
  end

  def take_item(*args)
    AbstractScript.take_item(*args)
  end

  def self.take_all_items(pc : L2PcInstance, *item_list : ItemHolder) : Bool
    take_all_items(pc, item_list)
  end

  def self.take_all_items(pc : L2PcInstance, item_list : Enumerable(ItemHolder)) : Bool
    return false if !item_list || item_list.empty?

    return false if !has_all_items?(pc, true, item_list)
    item_list.each { |item| return false unless take_item(pc, item) }
    true
  end

  def take_all_items(*args)
    AbstractScript.take_all_items(*args)
  end

  def self.has_all_items?(pc : L2PcInstance, check_count : Bool, *items : ItemHolder) : Bool
    has_all_items?(pc, check_count, items)
  end

  def self.has_all_items?(pc : L2PcInstance, check_count : Bool, item_list : Enumerable(ItemHolder)) : Bool
    return false if !item_list || item_list.empty?
    item_list.all? { |item| has_item?(pc, item, check_count) }
  end

  def has_all_items?(*args)
    AbstractScript.has_all_items?(*args)
  end

  def self.has_item?(pc : L2PcInstance, item : ItemHolder?) : Bool
    has_item?(pc, item, true)
  end

  def self.has_item?(pc : L2PcInstance, item : ItemHolder?, check_count : Bool) : Bool
    return false unless item
    if check_count
      get_quest_items_count(pc, item.id) >= item.count
    else
      has_quest_items?(pc, item.id)
    end
  end

  def has_item?(*args)
    AbstractScript.has_item?(*args)
  end

  def self.has_quest_items?(pc : L2PcInstance, *item_ids : Int32) : Bool
    has_quest_items?(pc, item_ids)
  end

  def self.has_quest_items?(pc : L2PcInstance, item_ids : Enumerable(Int32)) : Bool
    if item_ids.empty?
      warn "#{__FILE__} #{__LINE__} empty item_id list."
      false
    end

    inv = pc.inventory
    item_ids.all? { |id| inv.get_item_by_item_id(id) }
  end

  def has_quest_items?(*args)
    AbstractScript.has_quest_items?(*args)
  end

  def self.add_exp_and_sp(pc : L2PcInstance, exp : Int, sp : Int)
    exp = (exp * Config.rate_quest_reward_xp).to_i64
    sp = (sp * Config.rate_quest_reward_sp).to_i32
    pc.add_exp_and_sp_quest(exp, sp)
  end

  def add_exp_and_sp(pc : L2PcInstance, exp : Int, sp : Int)
    AbstractScript.add_exp_and_sp(pc, exp, sp)
  end

  def self.has_at_least_one_quest_item?(pc : L2PcInstance, *item_ids : Int32) : Bool
    has_at_least_one_quest_item?(pc, item_ids)
  end

  def self.has_at_least_one_quest_item?(pc : L2PcInstance, item_ids : Enumerable(Int32)) : Bool
    inv = pc.inventory
    item_ids.any? { |id| inv.get_item_by_item_id(id) }
  end

  def has_at_least_one_quest_item?(*args)
    AbstractScript.has_at_least_one_quest_item?(*args)
  end

  def self.add_minion(master : L2MonsterInstance, minion_id : Int32) : L2Npc?
    MinionList.spawn_minion(master, minion_id)
  end

  def add_minion(master : L2MonsterInstance, minion_id : Int32) : L2Npc?
    AbstractScript.add_minion(master, minion_id)
  end

  def self.give_adena(pc : L2PcInstance, count : Int64, apply_rates : Bool)
    if apply_rates
      reward_items(pc, Inventory::ADENA_ID, count)
    else
      give_items(pc, Inventory::ADENA_ID, count)
    end
  end

  def give_adena(pc : L2PcInstance, count : Int64, apply_rates : Bool)
    AbstractScript.give_adena(pc, count, apply_rates)
  end

  def self.reward_items(pc : L2PcInstance, holder : ItemHolder)
    reward_items(pc, holder.id, holder.count)
  end

  def self.reward_items(pc : L2PcInstance, item_id : Int32, count : Int)
    return if count <= 0

    return unless item = ItemTable[item_id]?

    if item_id == Inventory::ADENA_ID
      count *= Config.rate_quest_reward_adena
    elsif Config.rate_quest_reward_use_multipliers
      if item.is_a?(L2EtcItem)
        case item.item_type
        when EtcItemType::POTION
          count *= Config.rate_quest_reward_potion
        when EtcItemType::SCRL_ENCHANT_WP, EtcItemType::SCRL_ENCHANT_AM, EtcItemType::SCROLL
          count *= Config.rate_quest_reward_scroll
        when EtcItemType::RECIPE
          count *= Config.rate_quest_reward_recipe
        when EtcItemType::MATERIAL
          count *= Config.rate_quest_reward_material
        else
          count *= Config.rate_quest_reward
        end
      end
    else
      count *= Config.rate_quest_reward
    end

    # Multiplying by the rates results in a Float and we need an Integer.
    count = count.to_i64

    inst = pc.inventory.add_item("Quest", item_id, count, pc, pc.target)
    send_item_get_message(pc, inst.not_nil!, count)
  end

  def reward_items(*args)
    AbstractScript.reward_items(*args)
  end

  def self.add_attack_desire(npc : L2Npc, target : L2Character)
    add_attack_desire(npc, target, 999i64)
  end

  def self.add_attack_desire(npc : L2Npc, target : L2Character, desire : Int)
    if npc.is_a?(L2Attackable)
      npc.add_damage_hate(target, 0, desire.to_i64)
    end

    npc.running = true
    npc.set_intention(AI::ATTACK, target)
  end

  def add_attack_desire(*args)
    AbstractScript.add_attack_desire(*args)
  end

  def self.add_move_to_desire(npc : L2Npc, loc : Location, desire : Int32) # desire unused
    npc.set_intention(AI::MOVE_TO, loc)
  end

  def self.add_skill_cast_desire(npc : L2Npc, target : L2Character, sh : SkillHolder, desire : Int)
    add_skill_cast_desire(npc, target, sh.skill, desire)
  end

  def self.add_skill_cast_desire(npc : L2Npc, target : L2Character, skill : Skill, desire : Int)
    if npc.is_a?(L2Attackable)
      npc.add_damage_hate(target, 0, desire.to_i64)
    end

    npc.target = target
    npc.set_intention(AI::CAST, skill, target)
  end

  def add_skill_cast_desire(*args)
    AbstractScript.add_skill_cast_desire(*args)
  end

  def self.cast_skill(npc : L2Npc, target : L2Playable, sh : SkillHolder)
    npc.target = target
    npc.do_cast(sh.skill)
  end

  def self.cast_skill(npc : L2Npc, target : L2Playable, skill : Skill)
    npc.target = target
    npc.do_cast(skill)
  end

  def cast_skill(*args)
    AbstractScript.cast_skill(*args)
  end

  def self.give_item_randomly(pc : L2PcInstance, item_id : Int, amount : Int, limit : Int, drop_chance : Float64, play_sound : Bool) : Bool
    give_item_randomly(pc, nil, item_id, amount, limit, drop_chance, play_sound)
  end

  def self.give_item_randomly(pc : L2PcInstance, npc : L2Npc?, item_id : Int, amount : Int, limit : Int, drop_chance : Float64, play_sound : Bool) : Bool
    give_item_randomly(pc, npc, item_id, amount, amount, limit, drop_chance, play_sound)
  end

  def self.give_item_randomly(pc : L2PcInstance, npc : L2Npc?, item_id : Int, min_amount : Int, max_amount : Int, limit : Int, drop_chance : Float64, play_sound : Bool) : Bool
    current_count = get_quest_items_count(pc, item_id)

    return true if limit > 0 && current_count >= limit

    min_amount *= Config.rate_quest_drop
    max_amount *= Config.rate_quest_drop
    drop_chance *= Config.rate_quest_drop
    if npc && Config.champion_enable && npc.champion?
      if item_id == Inventory::ADENA_ID || item_id == Inventory::ANCIENT_ADENA_ID
        drop_chance *= Config.champion_adenas_rewards_chance
        min_amount *= Config.champion_adenas_rewards_amount
        max_amount *= Config.champion_adenas_rewards_amount
      else
        drop_chance *= Config.champion_rewards_chance
        min_amount *= Config.champion_rewards_amount
        max_amount *= Config.champion_rewards_amount
      end
    end

    amount_to_give = min_amount == max_amount ? min_amount : Rnd.rand(min_amount.to_i64..max_amount.to_i64)
    amount_to_give = amount_to_give.to_i64

    # debug "#give_item_randomly amount to give: #{amount_to_give}"

    random = Rnd.rand
    # Inventory slot check (almost useless for non-stacking items)
    if drop_chance >= random && amount_to_give > 0 && pc.inventory.validate_capacity_by_item_id(item_id)
      if limit > 0 && current_count + amount_to_give > limit
        amount_to_give = limit - current_count
      end

      # Give the item to player
      if item = pc.add_item("Quest", item_id, amount_to_give.to_i64, npc, true)
        # limit reached (if there is no limit, this block doesn't execute)
        if current_count + amount_to_give == limit
          if play_sound
            play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
          end

          return true
        end

        if play_sound
          play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
        # if there is no limit, return true every time an item is given
        if limit <= 0
          return true
        end
      end
    end

    false
  end

  def give_item_randomly(pc : L2PcInstance, item_id : Int, amount : Int, limit : Int, drop_chance : Float64, play_sound : Bool) : Bool
    AbstractScript.give_item_randomly(pc, item_id, amount, limit, drop_chance, play_sound)
  end

  def give_item_randomly(pc : L2PcInstance, npc : L2Npc?, item_id : Int, amount : Int, limit : Int, drop_chance : Float64, play_sound : Bool) : Bool
    AbstractScript.give_item_randomly(pc, npc, item_id, amount, limit, drop_chance, play_sound)
  end

  def give_item_randomly(pc : L2PcInstance, npc : L2Npc?, item_id : Int, min_amount : Int, max_amount : Int, limit : Int, drop_chance : Float64, play_sound : Bool) : Bool
    AbstractScript.give_item_randomly(pc, npc, item_id, min_amount, max_amount, limit, drop_chance, play_sound)
  end

  def self.add_spawn(npc_id : Int, pos : Positionable) : L2Npc
    add_spawn(npc_id, *pos.xyz, pos.heading, false, 0, false, 0)
  end

  def self.add_spawn(summoner : L2Npc?, npc_id : Int, pos : Positionable, random_offset : Bool, despawn_delay : Int)
    add_spawn(summoner, npc_id, *pos.xyz, pos.heading, random_offset, despawn_delay, false, 0)
  end

  def self.add_spawn(npc_id : Int, pos : Positionable, is_summon_spawn : Bool) : L2Npc
    add_spawn(npc_id, *pos.xyz, pos.heading, false, 0, is_summon_spawn, 0)
  end

  def self.add_spawn(npc_id : Int, pos : Positionable, random_offset : Bool, despawn_delay : Int) : L2Npc
    add_spawn(npc_id, *pos.xyz, pos.heading, random_offset, despawn_delay, false, 0)
  end

  def self.add_spawn(npc_id : Int, pos : Positionable, random_offset : Bool, despawn_delay : Int, is_summon_spawn : Bool) : L2Npc
    add_spawn(npc_id, *pos.xyz, pos.heading, random_offset, despawn_delay, is_summon_spawn, 0)
  end

  def self.add_spawn(npc_id : Int, pos : Positionable, random_offset : Bool, despawn_delay : Int, is_summon_spawn : Bool, instance_id : Int) : L2Npc
    add_spawn(npc_id, *pos.xyz, pos.heading, random_offset, despawn_delay, is_summon_spawn, instance_id)
  end

  def self.add_spawn(npc_id : Int, x : Int, y : Int, z : Int, heading : Int, random_offset : Bool, despawn_delay : Int) : L2Npc
    add_spawn(npc_id, x, y, z, heading, random_offset, despawn_delay, false, 0)
  end

  def self.add_spawn(npc_id : Int, x : Int, y : Int, z : Int, heading : Int, random_offset : Bool, despawn_delay : Int, is_summon_spawn : Bool) : L2Npc
    add_spawn(npc_id, x, y, z, heading, random_offset, despawn_delay, is_summon_spawn, 0)
  end

  def self.add_spawn(npc_id : Int, x : Int, y : Int, z : Int, heading : Int, random_offset : Bool, despawn_delay : Int, is_summon_spawn : Bool, instance_id : Int) : L2Npc
    add_spawn(nil, npc_id, x, y, z, heading, random_offset, despawn_delay, is_summon_spawn, instance_id)
  end

  def self.add_spawn(summoner : L2Npc?, npc_id : Int, x : Int, y : Int, z : Int, heading : Int, random_offset : Bool, despawn_delay : Int, is_summon_spawn : Bool, instance_id : Int) : L2Npc
    if x == 0 && y == 0
      raise "Invalid spawn coordinates for NPC #{npc_id}."
    end

    if random_offset
      offset = Rnd.rand(50..100)
      if Rnd.bool
        offset *= -1
      end
      x += offset
      offset = Rnd.rand(50..100)
      if Rnd.bool
        offset *= -1
      end
      y += offset
    end

    spawn = L2Spawn.new(npc_id)
    spawn.instance_id = instance_id
    spawn.heading = heading
    spawn.x, spawn.y, spawn.z = x, y, z
    spawn.stop_respawn

    unless npc = spawn.spawn_one(is_summon_spawn)
      raise "Npc wasn't spawned"
    end

    if despawn_delay > 0
      npc.schedule_despawn(despawn_delay.to_i64)
    end

    summoner.try &.add_summoned_npc(npc)

    npc
  end

  def add_spawn(*args)
    AbstractScript.add_spawn(*args)
  end

  def add_trap(trap_id : Int32, x : Int32, y : Int32, z : Int32, heading : Int32, skill : Skill?, instance_id : Int32) : L2TrapInstance
    template = NpcData[trap_id]
    trap = L2TrapInstance.new(template, instance_id, -1)
    trap.heal!
    trap.invul = true
    trap.heading = heading
    trap.spawn_me(x, y, z)
    trap
  end

  def self.add_radar(pc : L2PcInstance, x : Int32, y : Int32, z : Int32)
    pc.radar.add_marker(x, y, z)
  end

  def add_radar(*args)
    AbstractScript.add_radar(*args)
  end

  def self.remove_radar(pc : L2PcInstance, x : Int32, y : Int32, z : Int32)
    pc.radar.remove_marker(x, y, z)
  end

  def self.teleport_player(pc : L2PcInstance, loc : Location, instance_id : Int32)
    teleport_player(pc, loc, instance_id, true)
  end

  def self.teleport_player(pc : L2PcInstance, loc : Location, instance_id : Int32, allow_random_offset : Bool)
    pc.tele_to_location(
      loc,
      instance_id,
      allow_random_offset ? Config.max_offset_on_teleport : 0
    )
  end

  def teleport_player(*args)
    AbstractScript.teleport_player(*args)
  end

  def execute_for_each_player(pc : L2PcInstance, npc : L2Npc, is_summon : Bool, include_party : Bool, include_cc : Bool)
    if (include_party || include_cc) && pc.in_party?
      if include_cc && pc.party.in_command_channel?
        pc.party.command_channel.each do |m|
          action_for_each_player(m, npc, is_summon)
        end
      elsif include_party
        pc.party.each do |m|
          action_for_each_player(m, npc, is_summon)
        end
      end
    else
      action_for_each_player(pc, npc, is_summon)
    end
  end

  def action_for_each_player(pc : L2PcInstance, npc : L2Npc, is_summon : Bool)
    # no-op
  end

  def open_door(door_id : Int32, instance_id : Int32)
    if door = get_door(door_id, instance_id)
      if door.closed?
        door.open_me
      end
    else
      warn "No door with id #{door_id} at instance id #{instance_id}."
    end
  end

  def close_door(door_id : Int32, instance_id : Int32)
    if door = get_door(door_id, instance_id)
      if door.open?
        door.close_me
      end
    else
      warn "No door with id #{door_id} at instance id #{instance_id}."
    end
  end

  def get_door(door_id : Int32, instance_id : Int32) : L2DoorInstance?
    if instance_id <= 0
      DoorData.get_door(door_id)
    else
      if inst = InstanceManager.get_instance(instance_id)
        inst.get_door(door_id)
      end
    end
  end

  annotation Register; end

  private def initialize_annotation_listeners
    ids = Set(Int32).new

    {% for m in @type.methods %}
      {% if ann = m.annotation(Register) %}
        # debug "{{m.name}} has an annotation."
        # method = ->{{m.name}}({{m.args.first.restriction}})
        method = ->(evt : BaseEvent) do
          {{m.name}}(evt.as({{m.args.first.restriction || "BaseEvent".id}}))
        end

        event_type = EventType::{{ann[:event]}}
        register_type = ListenerRegisterType::{{ann[:register]}}

        if npc = {{ann[:id]}}
          if npc.is_a?(Enumerable)
            ids.concat(npc)
          else
            ids << npc
          end
        end

        if npcs = {{ann[:ids]}}
          if npcs.is_a?(Enumerable)
            ids.concat(npcs)
          else
            ids << npcs
          end
        end

        if range = {{ann[:range]}}
          if range.is_a?(Enumerable)
            ids.concat(range)
          else
            ids << range
          end
        end

        if ranges = {{ann[:ranges]}}
          ranges.each { |r| ids.concat(r) }
        end

        if range = {{ann[:level_range]}}
          range.each do |lvl|
            templates = NpcData.get_all_of_level(lvl)
            templates.each do |template|
              ids << template.id
            end
          end
        end

        if ranges = {{ann[:level_ranges]}}
          ranges.each do |range|
            range.each do |lvl|
              templates = NpcData.get_all_of_level(lvl)
              templates.each do |template|
                ids << template.id
              end
            end
          end
        end

        priority = {{ann[:priority]}} || 0

        unless ids.empty?
          @registered_ids[register_type] ||= ids
        end

        register_annotation(event_type, register_type, method, priority, ids)
      {% end %}
    {% end %}
  end
end
