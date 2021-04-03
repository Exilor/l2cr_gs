require "../events/abstract_script"
require "./quest_timer"
require "./state"

class Quest < AbstractScript
  private DEFAULT_NO_QUEST_MSG = "<html><body>You are either not on a quest that involves this NPC, or you don't meet this NPC's minimum quest requirements.</body></html>"
  private DEFAULT_ALREADY_COMPLETED_MSG = "<html><body>This quest has already been completed.</body></html>"

  private QUEST_DELETE_FROM_CHAR_QUERY = "DELETE FROM character_quests WHERE charId=? AND name=?"
  private QUEST_DELETE_FROM_CHAR_QUERY_NON_REPEATABLE_QUERY = "DELETE FROM character_quests WHERE charId=? AND name=? AND var!=?"

  private RESET_HOUR = 6
  private RESET_MINUTES = 30

  @rw_lock = Mutex.new(:Reentrant) # should be a "reentrant read write lock"
  @on_enter_world = false
  @quest_item_ids = [] of Int32
  @quest_timers : Concurrent::Map(String, Array(QuestTimer))?
  @start_condition : Hash(Proc(L2PcInstance, Bool), String)?

  getter name, description
  getter initial_state = State::CREATED
  property? custom : Bool = false

  def initialize(quest_id : Int32, name : String, description : String)
    @quest_id = quest_id
    @name = name
    @description = description

    super()

    if quest_id > 0
      QuestManager.add_quest(self)
    else
      QuestManager.add_script(self)
    end
  end

  def id : Int32
    @quest_id
  end

  def reset_hour : Int32
    RESET_HOUR
  end

  def reset_minutes : Int32
    RESET_MINUTES
  end

  def load_global_data
    # no-op
  end

  def save_global_data
    # no-op
  end

  def new_quest_state(pc : L2PcInstance)
    QuestState.new(self, pc, @initial_state)
  end

  def get_quest_state(pc : L2PcInstance, init_if_none : Bool) : QuestState?
    pc.get_quest_state(@name) || (new_quest_state(pc) if init_if_none)
  end

  def get_quest_state!(pc : L2PcInstance, init_if_none : Bool) : QuestState
    unless qs = get_quest_state(pc, init_if_none)
      raise "QuestState for quest #{name} and player #{pc} not found"
    end

    qs
  end

  def get_quest_state!(pc : L2PcInstance) : QuestState
    get_quest_state(pc, true).not_nil!
  end

  def quest_timers : Concurrent::Map(String, Array(QuestTimer))
    @quest_timers || sync do
      @quest_timers ||= Concurrent::Map(String, Array(QuestTimer)).new
    end
  end

  def start_quest_timer(name : String, time : Int, npc : L2Npc?, pc : L2PcInstance?)
    start_quest_timer(name, time, npc, pc, false)
  end

  def start_quest_timer(name : String, time : Int, npc : L2Npc?, pc : L2PcInstance?, repeating : Bool)
    unless get_quest_timer(name, npc, pc)
      timers = quest_timers.store_if_absent(name) { [] of QuestTimer }
      @rw_lock.synchronize do
        timers << QuestTimer.new(self, name, time.to_i64, npc, pc, repeating)
      end
    end
  end

  def get_quest_timer(name : String, npc : L2Npc?, pc : L2PcInstance?) : QuestTimer?
    return unless @quest_timers

    if timers = quest_timers[name]?
      @rw_lock.synchronize do
        timers.find &.match?(self, name, npc, pc)
      end
    end
  end

  def cancel_quest_timer(name : String, npc : L2Npc?, pc : L2PcInstance?)
    get_quest_timer(name, npc, pc).try &.cancel_and_remove
  end

  def cancel_quest_timers(name : String)
    return unless @quest_timers

    if timers = quest_timers[name]?
      @rw_lock.synchronize do
        timers.safe_each &.cancel
        timers.clear
      end
    end
  end

  def remove_quest_timer(timer : QuestTimer?)
    if timer && @quest_timers
      if timers = quest_timers[timer.name]?
        @rw_lock.synchronize { timers.delete_first(timer) }
      end
    end
  end

  def notify_attack(npc, attacker, damage, is_summon, skill)
    res : String? = on_attack(npc, attacker, damage, is_summon, skill) ||
      on_attack(npc, attacker, damage, is_summon)
  rescue e
    show_error(attacker, e)
  else
    show_result(attacker, res)
  end

  def notify_death(killer, victim, quest_state)
    res : String? = on_death(killer, victim, quest_state)
  rescue e
    show_error(quest_state.player, e)
  else
    show_result(quest_state.player, res)
  end

  def notify_item_use(item, pc)
    res : String? = on_item_use(item, pc)
  rescue e
    show_error(pc, e)
  else
    show_result(pc, res)
  end

  def notify_spell_finished(npc, pc, skill)
    res : String? = on_spell_finished(npc, pc, skill)
  rescue e
    show_error(pc, e)
  else
    show_result(pc, res)
  end

  def notify_trap_action(trap, trigger, action)
    res : String? = on_trap_action(trap, trigger, action)
  rescue e
    if pc = trigger.acting_player
      show_error(pc, e)
    end
  else
    if pc = trigger.acting_player
      show_result(pc, res)
    end
  end

  def notify_spawn(npc)
    on_spawn(npc)
  rescue e
    warn e
  end

  def notify_teleport(npc)
    on_teleport(npc)
  rescue e
    warn e
  end

  def notify_event(event : String, npc : L2Npc?, pc : L2PcInstance?)
    res : String? = on_adv_event(event, npc, pc)
  rescue e
    show_error(pc, e)
  else
    show_result(pc, res, npc)
  end

  def notify_enter_world(pc)
    res : String? = on_enter_world(pc)
  rescue e
    show_error(pc, e)
  else
    show_result(pc, res)
  end

  def notify_tutorial_event(pc, command)
    on_tutorial_event(pc, command)
  rescue e
    show_error(pc, e)
  end

  def notify_tutorial_client_event(pc, event)
    on_tutorial_client_event(pc, event)
  rescue e
    show_error(pc, e)
  end

  def notify_tutorial_question_mark(pc, number)
    res : String? = on_tutorial_question_mark(pc, number)
  rescue e
    show_error(pc, e)
  else
    show_result(pc, res)
  end

  def notify_tutorial_cmd(pc, command)
    res : String? = on_tutorial_cmd(pc, command)
  rescue e
    show_error(pc, e)
  else
    show_result(pc, res)
  end

  def notify_kill(npc, killer, is_summon)
    res : String? = on_kill(npc, killer, is_summon)
  rescue e
    show_error(killer, e)
  else
    show_result(killer, res)
  end

  def notify_talk(npc, pc)
    start_condition_html = get_start_condition_html(pc)
    res : String?
    if !pc.has_quest_state?(@name) && start_condition_html
      res = start_condition_html
    else
      res = on_talk(npc, pc)
    end
  rescue e
    show_error(pc, e)
  else
    pc.last_quest_npc_l2id = npc.l2id
    show_result(pc, res, npc)
  end

  def notify_first_talk(npc, pc)
    res : String? = on_first_talk(npc, pc)
  rescue e
    show_error(pc, e)
  else
    show_result(pc, res, npc)
  end

  def notify_acquire_skill(npc, pc, skill, type)
    res : String? = on_acquire_skill(npc, pc, skill, type)
  rescue e
    show_error(pc, e)
  else
    show_result(pc, res)
  end

  def notify_item_talk(item, pc)
    res : String? = on_item_talk(item, pc)
  rescue e
    show_error(pc, e)
  else
    show_result(pc, res)
  end

  def on_item_talk(item, pc)
    # no-op
  end

  def notify_item_event(item, pc, event)
    begin
      res : String? = on_item_event(item, pc, event)
      if res && (res.casecmp?("true") || res.casecmp?("false"))
        return
      end
    rescue e
      show_error(pc, e)
      return
    end

    show_result(pc, res)
  end

  def notify_skill_see(npc, caster, skill, targets, is_summon)
    res : String? = on_skill_see(npc, caster, skill, targets, is_summon)
  rescue e
    show_error(caster, e)
  else
    show_result(caster, res)
  end

  def notify_faction_call(npc, caller, attacker, is_summon)
    res : String? = on_faction_call(npc, caller, attacker, is_summon)
  rescue e
    show_error(attacker, e)
  else
    show_result(attacker, res)
  end

  def notify_aggro_range_enter(npc, pc, is_summon)
    res : String? = on_aggro_range_enter(npc, pc, is_summon)
  rescue e
    show_error(pc, e)
  else
    show_result(pc, res)
  end

  def notify_see_creature(npc, creature, is_summon)
    if is_summon || creature.player?
      pc = creature.acting_player
    end
    res : String? = on_see_creature(npc, creature, is_summon)
  rescue e
    show_error(pc, e) if pc
  else
    show_result(pc, res) if pc
  end

  def notify_event_received(event_name, sender, receiver, reference)
    on_event_received(event_name, sender, receiver, reference)
  rescue e
    warn e
  end

  def notify_enter_zone(char, zone)
    pc = char.acting_player
    res : String? = on_enter_zone(char, zone)
  rescue e
    show_error(pc, e) if pc
  else
    show_result(pc, res) if pc
  end

  def notify_exit_zone(char, zone)
    pc = char.acting_player
    res : String? = on_exit_zone(char, zone)
  rescue e
    show_error(pc, e) if pc
  else
    show_result(pc, res) if pc
  end

  def notify_olympiad_match(winner, loser, type)
    on_olympiad_match_finish(winner, loser, type)
  rescue e
    warn e
  end

  def notify_move_finished(npc)
    on_move_finished(npc)
  rescue e
    warn e
  end

  def notify_node_arrived(npc)
    on_node_arrived(npc)
  rescue e
    warn e
  end

  def notify_route_finished(npc)
    on_route_finished(npc)
  rescue e
    warn e
  end

  def notify_on_can_see_me(npc, pc) : Bool
    on_can_see_me(npc, pc)
  rescue e
    warn e
    false
  end

  # Having this method call the other which would be overriden results in the
  # no-op method being called instead of the overriden method.
  def on_attack(npc, attacker, damage, is_summon)
    # on_attack(npc, attacker, damage, is_summon, nil)
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    # no-op
  end

  def on_death(killer, victim, qs)
    on_adv_event("", killer.as?(L2Npc), qs.player)
  end

  def on_adv_event(event, npc, pc) : String?
    if pc && (qs = pc.get_quest_state(name))
      return on_event(event, qs)
    end

    nil
  end

  def on_event(event, qs)
    # no-op
  end

  def on_kill(npc, killer, is_summon)
    # no-op
  end

  def on_talk(npc, pc)
    # no-op
  end

  def on_first_talk(npc, pc)
    # no-op
  end

  def on_item_event(item, pc, event)
    # no-op
  end

  def on_acquire_skill_list(npc, pc)
    # no-op
  end

  def on_acquire_skill_info(npc, pc, skill)
    # no-op
  end

  def on_acquire_skill(npc, pc, skill, type)
    # no-op
  end

  def on_item_use(item, pc)
    # no-op
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    # return nil
  end

  def on_spell_finished(npc, pc, skill)
    # no-op
  end

  def on_trap_action(trap, trigger, action)
    # no-op
  end

  def on_spawn(npc)
    # no-op
  end

  def on_teleport(npc)
    # no-op
  end

  def on_faction_call(npc, caller, attacker, is_summon)
    # no-op
  end

  def on_aggro_range_enter(npc, pc, is_summon)
    # no-op
  end

  def on_see_creature(npc, creature, is_summon)
    # no-op
  end

  def on_enter_world(pc)
    # no-op
  end

  def on_tutorial_event(pc, command)
    # no-op
  end

  def on_tutorial_client_event(pc, event)
    # no-op
  end

  def on_tutorial_question_mark(pc, number)
    # return nil
  end

  def on_tutorial_cmd(pc, command)
    # return nil
  end

  def on_enter_zone(char, zone)
    # no-op
  end

  def on_exit_zone(char, zone)
    # no-op
  end

  def on_event_received(event_name, sender, receiver, reference)
    # no-op
  end

  def on_olympiad_match_finish(winner, loser, type)
    # no-op
  end

  def on_olympiad_lose(loser, type)
    # no-op
  end

  def on_move_finished(npc)
    # no-op
  end

  def on_node_arrived(npc)
    # no-op
  end

  def on_route_finished(npc)
    # no-op
  end

  def on_npc_hate(mob, pc, is_summon)
    true
  end

  def on_summon_spawn(summon)
    # no-op
  end

  def on_summon_talk(summon)
    # no-op
  end

  def on_can_see_me(npc, pc)
    false
  end

  def show_error(pc : L2PcInstance?, e : Exception) : Bool
    warn e

    if pc && pc.gm?
      trace = e.backtrace.join("<br>")
      res = "<html><body><title>Script error</title>#{trace}</body></html>"
      return show_result(pc, res)
    end

    false
  end

  def show_result(pc : L2PcInstance?, res : String?, npc : L2Npc? = nil) : Bool
    return true unless pc && res && !res.empty?

    if res.ends_with?(".htm", ".html")
      show_html_file(pc, res, npc)
    elsif res.starts_with?("<html")
      reply = NpcHtmlMessage.new(npc ? npc.l2id : 0, res)
      reply["%playername%"] = pc.name
      pc.send_packet(reply)
      pc.action_failed
    else
      pc.send_message(res)
    end

    false
  end

  def save_global_quest_var(var : String, value : String)
    sql = "REPLACE INTO quest_global_data (quest_name,var,value) VALUES (?,?,?)"
    GameDB.exec(sql, name, var, value)
  rescue e
    error e
  end

  def load_global_quest_var(var : String) : String
    begin
      sql = "SELECT value FROM quest_global_data WHERE quest_name = ? AND var = ?"
      GameDB.query_each(sql, name, var) do |rs|
        return rs.read(String)
      end
    rescue e
      error e
    end

    ""
  end

  def delete_global_quest_var(var : String)
    sql = "DELETE FROM quest_global_data WHERE quest_name = ? AND var = ?"
    GameDB.exec(sql, name, var)
  rescue e
    error e
  end

  def delete_all_global_quest_var(var : String)
    sql = "DELETE FROM quest_global_data WHERE quest_name = ?"
    GameDB.exec(sql, name)
  rescue e
    error e
  end

  private module InstanceAndClassMethods
    def create_quest_var_in_db(qs : QuestState, var : String, value : String)
      sql = "INSERT INTO character_quests (charId,name,var,value) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE value=?"
      GameDB.exec(sql, qs.player.l2id, qs.quest_name, var, value, value)
    rescue e
      error e
    end

    def update_quest_var_in_db(qs : QuestState, var : String, value : String)
      sql = "UPDATE character_quests SET value=? WHERE charId=? AND name=? AND var = ?"
      GameDB.exec(sql, value, qs.player.l2id, qs.quest_name, var)
    rescue e
      error e
    end

    def delete_quest_var_in_db(qs : QuestState, var : String)
      sql = "DELETE FROM character_quests WHERE charId=? AND name=? AND var=?"
      GameDB.exec(sql, qs.player.l2id, qs.quest_name, var)
    rescue e
      error e
    end

    def delete_quest_in_db(qs : QuestState, repeatable : Bool)
      if repeatable
        sql = QUEST_DELETE_FROM_CHAR_QUERY
        GameDB.exec(sql, qs.player.l2id, qs.quest_name)
      else
        sql = QUEST_DELETE_FROM_CHAR_QUERY_NON_REPEATABLE_QUERY
        GameDB.exec(sql, qs.player.l2id, qs.quest_name, "<state>")
      end
    rescue e
      error e
    end

    def create_quest_in_db(qs : QuestState)
      create_quest_var_in_db(qs, "<state>", qs.state.name)
    end

    def update_quest_in_db(qs : QuestState)
      update_quest_var_in_db(qs, "<state>", qs.state.name)
    end

    def get_no_quest_msg(pc : L2PcInstance) : String
      result = HtmCache.get_htm(pc, "data/html/noquest.htm")
      if result && !result.empty?
        return result
      end

      DEFAULT_NO_QUEST_MSG
    end

    def player_enter(pc : L2PcInstance)
      begin
        sql = "SELECT name, value FROM character_quests WHERE charId = ? AND var = ?"
        GameDB.each(sql, pc.l2id, "<state>") do |rs|
          id = rs.get_string(:"name")
          state_name = rs.get_string(:"value")

          unless q = QuestManager.get_quest(id)
            warn { "Missing quest '#{id}' for player #{pc}." }
            if Config.autodelete_invalid_quest_data
              warn { "Deleting invalid quest data for '#{id}'." }
              sql = "DELETE FROM character_quests WHERE charId = ? AND name = ?"
              GameDB.exec(sql, pc.l2id, id)
            end

            next
          end

          QuestState.new(q, pc, State.parse(state_name))
        end
      rescue e
        error e
      end

      begin
        sql = "SELECT name, var, value FROM character_quests WHERE charId = ? AND var <> ?"
        GameDB.each(sql, pc.l2id, "<state>") do |rs|
          id = rs.get_string(:"name")
          var = rs.get_string(:"var")
          value = rs.get_string(:"value")

          unless qs = pc.get_quest_state(id)
            warn { "Missing variable '#{var}' in quest '#{id}' for player #{pc}." }
            if Config.autodelete_invalid_quest_data
              warn { "Deleting invalid variable '#{var}' for quest '#{id}'." }
              sql = "DELETE FROM character_quests WHERE charId = ? AND name = ? AND var = ?"
              GameDB.exec(sql, pc.l2id, id, var)
            end

            next
          end

          qs.set_internal(var, value)
        end
      rescue e
        error e
      end

      QuestManager.quests.each_key do |name|
        pc.process_quest_event(name, "enter")
      end
    end
  end

  include InstanceAndClassMethods
  extend InstanceAndClassMethods

  def add_start_npc(*id)
    set_npc_quest_start_id(*id)
  end

  def add_first_talk_id(*id)
    set_npc_first_talk_id(*id) do |e|
      notify_first_talk(e.npc, e.active_char)
    end
  end

  def add_acquire_skill_id(*id)
    set_player_skill_learn_id(*id) do |e|
      notify_acquire_skill(e.trainer, e.active_char, e.skill, e.acquire_type)
    end
  end

  def add_item_bypass_event_id(*id)
    set_item_bypass_event_id(*id) do |e|
      notify_item_event(e.item, e.active_char, e.event)
    end
  end

  def add_item_talk_id(*id)
    set_item_talk_id(*id) do |e|
      notify_item_talk(e.item, e.active_char)
    end
  end

  def add_talk_id(*id)
    set_npc_talk_id(*id)
  end

  def add_kill_id(*id)
    set_attackable_kill_id(*id) do |e|
      notify_kill(e.target, e.attacker, e.summon?)
    end
  end

  def add_attack_id(*id)
    set_attackable_attack_id(*id) do |e|
      notify_attack(e.target, e.attacker, e.damage, e.summon?, e.skill)
    end
  end

  def add_teleport_id(*id)
    set_npc_teleport_id(*id) { |e| notify_teleport(e.npc) }
  end

  def add_spawn_id(*id)
    set_npc_spawn_id(*id) { |e| notify_spawn(e.npc) }
  end

  def add_skill_see_id(*id)
    set_npc_skill_see_id(*id) do |e|
      notify_skill_see(e.target, e.caster, e.skill, e.targets, e.summon?)
    end
  end

  def add_spell_finished_id(*id)
    set_npc_skill_finished_id(*id) do |e|
      notify_spell_finished(e.caster, e.target, e.skill)
    end
  end

  def add_trap_action_id(*id)
    set_trap_action_id(*id) do |e|
      notify_trap_action(e.trap, e.trigger, e.action)
    end
  end

  def add_faction_call_id(*id)
    set_attackable_faction_id_id(*id) do |e|
      notify_faction_call(e.npc, e.caller, e.attacker, e.summon?)
    end
  end

  def add_aggro_range_enter_id(*id)
    set_attackable_aggro_range_enter_id(*id) do |e|
      notify_aggro_range_enter(e.npc, e.active_char, e.summon?)
    end
  end

  def add_see_creature_id(*id)
    set_npc_creature_see_id(*id) do |e|
      notify_see_creature(e.npc, e.creature, e.summon?)
    end
  end

  def add_enter_zone_id(*id)
    set_creature_zone_enter_id(*id) do |e|
      notify_enter_zone(e.creature, e.zone)
    end
  end

  def add_exit_zone_id(*id)
    set_creature_zone_exit_id(*id) do |e|
      notify_exit_zone(e.creature, e.zone)
    end
  end

  def add_event_received_id(*id)
    set_npc_event_received_id(*id) do |e|
      notify_event_received(e.event_name, e.sender, e.receiver, e.reference)
    end
  end

  def add_move_finished_id(*id)
    set_npc_move_finished_id(*id) { |e| notify_move_finished(e.npc) }
  end

  def add_node_arrived_id(*id)
    set_npc_move_node_arrived_id(*id) { |e| notify_node_arrived(e.npc) }
  end

  def add_route_finished_id(*id)
    set_npc_move_route_finished_id(*id) { |e| notify_route_finished(e.npc) }
  end

  def add_npc_hate_id(*id)
    add_npc_hate_id(*id) do |e|
      ret = !on_npc_hate(e.npc, e.active_char, e.summon?)
      TerminateReturn.new(ret, false, false)
    end
  end

  def add_summon_spawn_id(*id)
    set_player_summon_spawn_id(*id) { |e| on_summon_spawn(e.summon) }
  end

  def add_summon_talk_id(*id)
    set_player_summon_talk_id(*id) { |e| on_summon_talk(e.summon) }
  end

  def add_can_see_me_id(*id)
    add_npc_hate_id(*id) do |e|
      ret = !notify_on_can_see_me(e.npc, e.active_char)
      TerminateReturn.new(ret, false, false)
    end
  end

  def add_olympiad_match_finish_id
    set_olympiad_match_result do |e|
      notify_olympiad_match(e.winner, e.loser, e.competition_type)
    end
  end

  def check_party_member(pc : L2PcInstance, npc : L2Npc) : Bool
    true
  end

  def check_party_member(qs : QuestState, npc : L2Npc) : Bool
    true
  end

  def check_party_member_conditions(qs : QuestState, cond : Int32, npc : L2Npc) : Bool
    return false unless qs

    if cond == -1
      qs.started?
    else
      qs.cond?(cond) && check_party_member(qs, npc)
    end
  end

  def show_page(pc : L2PcInstance, file_name : String, has_quest : Bool = false)
    if content = get_htm(pc, file_name)
      if has_quest && (npc = pc.last_folk_npc)
        content = content.gsub("%objectId%") { npc.l2id }
      end
      reply = NpcHtmlMessage.new(npc ? npc.l2id : 0, content)
      pc.send_packet(reply)
    else
      warn { "Quest#show_page: Missing content for '#{file_name}'." }
    end
  end

  def show_quest_page(pc : L2PcInstance, file_name : String, quest_id : Int32)
    if content = get_htm(pc, file_name)
      npc = pc.last_folk_npc
      reply = NpcQuestHtmlMessage.new(npc ? npc.l2id : 0, quest_id)
      reply.html = content
      pc.send_packet(reply)
    else
      warn { "Quest#show_quest_page: Missing content for '#{file_name}'." }
    end
  end

  def check_distance_to_target(pc : L2PcInstance, target : L2Character) : Bool
    Util.in_range?(1500, pc, target, true)
  end

  def show_html_file(pc : L2PcInstance, file_name : String) : String
    show_html_file(pc, file_name, nil)
  end

  def show_html_file(pc : L2PcInstance, file_name : String, npc : L2Npc?) : String
    quest_window = !file_name.ends_with?(".html")
    quest_id = id
    content = get_htm(pc, file_name)

    if content
      if npc
        content = content.gsub("%objectId%") { npc.l2id }
      end

      if quest_window && quest_id > 0 && quest_id < 20_000 && quest_id != 999
        reply = NpcQuestHtmlMessage.new(npc ? npc.l2id : 0, quest_id)
        reply.html = content
        reply["%playername%"] = pc.name
        pc.send_packet(reply)
      else
        reply = NpcHtmlMessage.new(npc ? npc.l2id : 0, content)
        reply["%playername%"] = pc.name
        pc.send_packet(reply)
      end

      pc.action_failed
    end

    content
  end

  def get_htm(pc : L2PcInstance, file_name : String) : String
    get_htm(pc.html_prefix, file_name)
  end

  def get_htm(prefix : String?, file_name : String) : String
    if file_name.starts_with?("data/")
      path = file_name
    else
      path = "data/scripts/#{description.downcase}/#{name}/#{file_name}"
    end
    # debug "First try: #{path.inspect}."

    unless content = HtmCache.get_htm(path)
      path = "data/scripts/#{description}/#{name}/#{file_name}"
      # debug "Second try: #{path.inspect}."
      unless content = HtmCache.get_htm(path)
        path = "data/scripts/quests/#{name}/#{file_name}"
        # debug "Third try: #{path.inspect}."
        content = HtmCache.get_htm_force(path)
      end
    end

    content
  end

  def registered_item_ids : Array(Int32)
    @quest_item_ids
  end

  def register_quest_items(*items : Int32)
    register_quest_items(items)
  end

  def register_quest_items(items : Enumerable(Int32))
    @quest_item_ids.clear.concat(items)
  end

  def remove_registered_quest_items(pc : L2PcInstance)
    take_items(pc, -1, @quest_item_ids)
  end

  def active=(status : Bool)
    # L2J TODO
  end

  def on_enter_world=(state : Bool)
    if state
      set_player_login_id { |e| notify_enter_world(e.active_char) }
    else
      listeners.safe_each do |l|
        if l.type == EventType::ON_PLAYER_LOGIN
          l.unregister_me
        end
      end
    end
  end

  def start_conditions : Hash(Proc(L2PcInstance, Bool), String)
    @start_condition || sync do
      @start_condition ||= {} of L2PcInstance -> Bool => String
    end
  end

  def can_start_quest?(pc : L2PcInstance) : Bool
    conds = @start_condition
    conds.nil? || conds.local_each_key.all? &.call(pc)
  end

  def get_start_condition_html(pc : L2PcInstance) : String?
    return unless conds = @start_condition
    conds.each do |cond, value|
      return value unless cond.call(pc)
    end
    nil
  end

  def add_cond_start(html : String, &block : L2PcInstance -> Bool)
    start_conditions[block] = html
  end

  def add_cond_level(min : Int32, max : Int32, html : String)
    add_cond_start(html) { |pc| pc.level.between?(min, max) }
  end

  def add_cond_min_level(min : Int32, html : String)
    add_cond_start(html) { |pc| pc.level >= min }
  end

  def add_cond_max_level(max : Int32, html : String)
    add_cond_start(html) { |pc| pc.level <= max }
  end

  def add_cond_race(race : Race, html : String)
    add_cond_start(html) { |pc| pc.race == race }
  end

  def add_cond_not_race(race : Race, html : String)
    add_cond_start(html) { |pc| pc.race != race }
  end

  def add_cond_completed_quest(name : String, html : String)
    add_cond_start(html) do |pc|
      pc.has_quest_state?(name) && pc.get_quest_state(name).completed?
    end
  end

  def add_cond_class_id(class_id : ClassId, html : String)
    add_cond_start(html) { |pc| pc.class_id == class_id }
  end

  def add_cond_not_class_id(class_id : ClassId, html : String)
    add_cond_start(html) { |pc| pc.class_id != class_id }
  end

  def add_cond_is_subclass_active(html : String)
    add_cond_start(html, &.subclass_active?)
  end

  def add_cond_is_not_subclass_active(html : String)
    add_cond_start(html) { |pc| !pc.subclass_active? }
  end

  def add_cond_in_category(type : CategoryType, html : String)
    add_cond_start(html) { |pc| pc.in_category?(type) }
  end

  def get_already_completed_msg(pc : L2PcInstance) : String
    HtmCache.get_htm(pc, "data/html/alreadycompleted.htm") ||
      DEFAULT_ALREADY_COMPLETED_MSG
  end

  def get_random_party_member(pc : L2PcInstance) : L2PcInstance?
    pc.party.try &.members.sample?(random: Rnd) || pc
  end

  def get_random_party_member(pc : L2PcInstance, cond : Int32) : L2PcInstance?
    get_random_party_member(pc, "cond", cond.to_s)
  end

  def get_random_party_member(pc : L2PcInstance, var : String?, value : String) : L2PcInstance?
    return unless pc
    unless var
      return get_random_party_member(pc)
    end

    party = pc.party

    if party.nil? || party.members.empty?
      temp = pc.get_quest_state(name)
      if temp && temp.set?(var) && temp.get(var).not_nil!.casecmp?(value)
        return pc
      end
      return
    end

    target = pc.target || pc

    party.members.select do |m|
      (temp = m.get_quest_state(name)) &&
      (qs = temp.get(var)) &&
      qs.casecmp?(value) &&
      m.inside_radius?(target, 1500, true, false)
    end
    .sample?(random: Rnd)
  end

  def get_random_party_member(pc : L2PcInstance, npc : L2Npc) : L2PcInstance?
    return unless check_distance_to_target(pc, npc)

    party = pc.party

    if party.nil?
      if check_party_member(pc, npc)
        winner = pc
      end
    else
      highest_roll = 0
      party.members.each do |m|
        rnd = Rnd.rand(1000)
        if rnd > highest_roll && check_party_member(m, npc)
          highest_roll = rnd
          winner = m
        end
      end
    end

    winner if winner && check_distance_to_target(winner, npc)
  end

  def get_random_party_member_state(pc : L2PcInstance, state : State) : L2PcInstance?
    party = pc.party
    if party.nil? || party.members.empty?
      qs = pc.get_quest_state(name)
      if qs && qs.state == state
        return pc
      end

      return
    end

    candidates = [] of L2PcInstance

    target = pc.target || pc

    party.members.each do |m|
      qs = m.get_quest_state(name)
      if qs && qs.state == state
        if m.inside_radius?(target, 1500, true, false)
          candidates << m
        end
      end
    end

    candidates.sample?(random: Rnd)
  end

  def get_random_party_member_state(pc : L2PcInstance, condition : Int, chance : Int, target : L2Npc) : QuestState?
    return if chance < 1

    return unless qs = pc.get_quest_state(name)

    unless party = pc.party
      unless check_party_member_conditions(qs, condition, target)
        return
      end

      unless check_distance_to_target(pc, target)
        return
      end

      return qs
    end

    candidates = [] of QuestState
    if check_party_member_conditions(qs, condition, target)
      chance.times { candidates << qs }
    end

    party.members.each do |m|
      next if m == pc

      qs = m.get_quest_state(name)
      if qs && check_party_member_conditions(qs, condition, target)
        candidates << qs
      end
    end

    return if candidates.empty?

    qs = candidates.sample(random: Rnd)

    qs if check_distance_to_target(qs.player, target)
  end

  def register_tutorial_event
    set_player_tutorial_event do |event|
      notify_tutorial_event(event.active_char, event.command)
    end
  end

  def register_tutorial_client_event
    set_player_tutorial_client_event do |event|
      notify_tutorial_client_event(event.active_char, event.event)
    end
  end

  def register_tutorial_question_mark
    set_player_tutorial_question_mark do |event|
      notify_tutorial_question_mark(event.active_char, event.number)
    end
  end

  def register_tutorial_cmd
    set_player_tutorial_cmd do |event|
      notify_tutorial_cmd(event.active_char, event.command)
    end
  end

  def set_one_time_quest_flag(pc, quest_id, flag)
    if quest = QuestManager.get_quest(quest_id)
      state = flag == 1 ? State::COMPLETED : State::STARTED
      quest.get_quest_state!(pc).state = state
    end
  end

  def get_one_time_quest_flag(pc, quest_id)
    quest = QuestManager.get_quest(quest_id)
    (quest && quest.get_quest_state!(pc).completed?) ? 1 : 0
  end

  def show_radar(pc : L2PcInstance, x : Int32, y : Int32, z : Int32, type : Int32) # type is unused
    pc.radar.add_marker(x, y, z)
  end

  def visible_in_quest_window? : Bool
    true
  end

  def show_tutorial_html(pc : L2PcInstance, file_name : String)
    if content = get_htm(pc, file_name)
      pc.send_packet(TutorialShowHtml.new(content))
    else
      warn { "Quest#show_tutorial_html: '#{file_name}' not found." }
    end
  end

  def has_memo?(pc : L2PcInstance, quest_id : Int32) : Bool
    quest = QuestManager.get_quest(quest_id)
    !!quest && pc.has_quest_state?(quest.name)
  end
end
