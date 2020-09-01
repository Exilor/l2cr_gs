require "../../enums/music/sound"
require "../../enums/quest_type"

class QuestState
  include Packets::Outgoing
  include Loggable

  @vars : Hash(String, String)?

  getter state, player
  getter quest_name : String

  def initialize(quest : Quest, player : L2PcInstance, state : State)
    @player = player
    @state = state
    @quest_name = quest.name
    player.set_quest_state(self)
  end

  delegate created?, started?, completed?, to: @state

  def quest : Quest
    QuestManager.get_quest(@quest_name).not_nil!
  end

  def state=(state : State)
    set_state(state, true)
  end

  def set_state(state : State, save_in_db) : Bool
    return false if @state == state
    new_quest = created?
    @state = state
    if save_in_db
      if new_quest
        Quest.create_quest_in_db(self)
      else
        Quest.update_quest_in_db(self)
      end
    end

    @player.send_packet(QuestList.new)

    true
  end

  def set_internal(var : String, val : String?)
    (@vars ||= {} of String => String)[var] = val || ""
  end

  def set(var : String, val : Int) : String?
    set(var, val.to_s)
  end

  def set(var : String, val : String) : String
    _vars = (@vars ||= {} of String => String)

    old = _vars[var]?
    _vars[var] = val

    if old
      Quest.update_quest_var_in_db(self, var, val)
    else
      Quest.create_quest_var_in_db(self, var, val)
    end

    if var == "cond"
      previous_val = old && old.number? ? old.to_i : 0
      set_cond(val.to_i, previous_val)
    end

    val
  end

  def unset(var : String) : String?
    return unless _vars = @vars

    if old = _vars.delete(var)
      Quest.delete_quest_var_in_db(self, var)
    end

    old
  end

  def save_global_quest_var(var : String, val : String)
    sql = "REPLACE INTO character_quest_global_data (charId, var, value) VALUES (?, ?, ?)"
    GameDB.exec(sql, @player.l2id, var, val)
  rescue e
    error e
  end

  def get_global_quest_var(var : String) : String
    begin
      sql = "SELECT value FROM character_quest_global_data WHERE charId = ? AND var = ?"
      GameDB.query_each(sql, @player.l2id, var) do |rs|
        return rs.read(String)
      end
    rescue e
      error e
    end

    ""
  end

  def get(var : String) : String?
    if vars = @vars
      vars[var]?
    end
  end

  def get_int(var : String) : Int32
    return -1 unless _vars = @vars
    return -1 unless variable = _vars[var]?
    return -1 if variable.empty?
    begin
      variable.to_i
    rescue e
      error e
      -1
    end
  end

  def cond?(cond : Int) : Bool
    get_int("cond") == cond
  end

  def cond : Int32
    started? ? get_int("cond") : 0
  end

  def set?(var : String) : Bool
    !get(var).nil?
  end

  def cond=(cond : Int32)
    set_cond(cond)
  end

  def set_cond(value : Int32) : self
    if started?
      set("cond", value.to_s)
    end

    self
  end

  private def set_cond(cond : Int32, old : Int32)
    return if cond == old

    completed_state_flags = 0

    if cond < 3 || cond > 31
      unset("__compltdStateFlags")
    else
      completed_state_flags = get_int("__compltdStateFlags")
    end

    if completed_state_flags == 0
      if cond > old + 1
        completed_state_flags = 0x80000001
        completed_state_flags |= (1 << old) - 1
        completed_state_flags |= 1 << (cond - 1)
        set("__compltdStateFlags", completed_state_flags.to_s)
      end
    elsif cond < old
      completed_state_flags &= (1 << cond) - 1

      if completed_state_flags == (1 << cond) - 1
        unset("__compltdStateFlags")
      else
        completed_state_flags |= 0x80000001
        set("__compltdStateFlags", completed_state_flags.to_s)
      end
    else
      completed_state_flags |= 1 << (cond - 1)
      set("__compltdStateFlags", completed_state_flags.to_s)
    end

    @player.send_packet(QuestList.new)

    q = quest

    if !q.custom? && cond > 0
      @player.send_packet(ExShowQuestMark.new(q.id))
    end
  end

  def set_cond(value : Int32, play_quest_middle : Bool) : self
    return self unless started?
    set("cond", value.to_s)

    if play_quest_middle
      AbstractScript.play_sound(@player, Sound::ITEMSOUND_QUEST_MIDDLE)
    end

    self
  end

  def memo_state : Int32
    started? ? get_int("memoState") : -1
  end

  def memo_state=(value : Int32)
    set("memoState", value.to_s)
    self
  end

  def memo_state?(ms : Int32)
    get_int("memoState") == ms
  end

  def remove_memo : String
    unset("memoState")
  end

  def has_memo_state? : Bool
    memo_state > 0
  end

  def get_memo_state_ex(slot : Int32) : Int32
    started? ? get_int("memoStateEx#{slot}") : 0
  end

  def memo_state_ex?(slot : Int32, mse : Int32) : Bool
    get_memo_state_ex(slot) == mse
  end

  def set_memo_state_ex(slot : Int32, value : Int32) : self
    set("memoStateEx#{slot}", value.to_s)
    self
  end

  def add_notify_of_death(char : L2Character)
    if char.is_a?(L2PcInstance)
      char.add_notify_quest_of_death(self)
    end
  end

  def play_sound(audio : IAudio)
    AbstractScript.play_sound(@player, audio)
  end

  def start_quest_timer(name : String, time : Int)
    quest.start_quest_timer(name, time.to_i64, nil, @player, false)
  end

  def start_quest_timer(name : String, time : Int, npc : L2Npc?)
    quest.start_quest_timer(name, time.to_i64, npc, @player, false)
  end

  def start_repeating_quest_timer(name : String, time : Int)
    quest.start_quest_timer(name, time.to_i64, nil, @player, true)
  end

  def start_repeating_quest_timer(name : String, time : Int, npc : L2Npc?)
    quest.start_quest_timer(name, time.to_i64, npc, @player, true)
  end

  def show_question_mark(talker : L2PcInstance, number : Int32)
    talker.send_packet(TutorialShowQuestionMark.new(number))
  end

  def show_question_mark(number : Int32)
    @player.send_packet(TutorialShowQuestionMark.new(number))
  end

  def get_dominion_siege_id(pc : L2PcInstance) : Int32
    TerritoryWarManager.get_registered_territory_id(pc)
  end

  def get_dominion_war_state(castle_id : Int32) : Int32
    TerritoryWarManager.tw_in_progress? ? 5 : 0
  end

  def enable_tutorial_event(pc : L2PcInstance, state : Int32)
    pc.send_packet(TutorialEnableClientEvent.new(state))
  end

  def close_tutorial_html(pc : L2PcInstance)
    pc.send_packet(TutorialCloseHtml::STATIC_PACKET)
  end

  def add_radar(x : Int32, y : Int32, z : Int32)
    @player.radar.add_marker(x, y, z)
  end

  def remove_radar(x : Int32, y : Int32, z : Int32)
    @player.radar.remove_marker(x, y, z)
  end

  def clear_radar
    @player.radar.remove_all_markers
  end

  def take_items(item_id : Int, count : Int)
    AbstractScript.take_items(@player, item_id, count)
  end

  def give_items(item_id : Int32, count : Int)
    AbstractScript.give_items(@player, item_id, count.to_i64, 0)
  end

  def give_items(holder : ItemHolder)
    AbstractScript.give_items(@player, holder.id, holder.count, 0)
  end

  def give_items(item_id : Int32, count : Int, enchant_level : Int)
    AbstractScript.give_items(@player, item_id, count.to_i64, enchant_level)
  end

  def give_items(item_id : Int32, count : Int, attribute_id : Int, attribute_level : Int)
    AbstractScript.give_items(@player, item_id, count.to_i64, attribute_id, attribute_level)
  end

  def add_exp_and_sp(exp : Int, sp : Int)
    AbstractScript.add_exp_and_sp(@player, exp, sp)
  end

  def exit_quest(repeatable : Bool) : self
    @player.remove_notify_quest_of_death(self)

    return self unless started?

    quest.remove_registered_quest_items(@player)
    Quest.delete_quest_in_db(self, repeatable)

    if repeatable
      @player.delete_quest_state(quest_name)
      @player.send_packet(QuestList.new)
    else
      self.state = State::COMPLETED
    end

    @vars = nil
    self
  end

  def exit_quest(repeatable : Bool, play_exit_quest : Bool) : self
    exit_quest(repeatable)

    if play_exit_quest
      play_sound(Sound::ITEMSOUND_QUEST_FINISH)
    end

    self
  end

  def exit_quest(type : QuestType) : self
    if type.daily?
      exit_quest(false)
      set_restart_time
    else
      exit_quest(type.repeatable?)
    end

    self
  end

  def exit_quest(type : QuestType, play_exit_quest : Bool) : self
    exit_quest(type)

    if play_exit_quest
      play_sound(Sound::ITEMSOUND_QUEST_FINISH)
    end

    self
  end

  def start_quest(play_sound : Bool = true, cond : Int32 = 1) : self
    if created? && !quest.custom?
      set("cond", cond)
      self.state = State::STARTED
      if play_sound
        play_sound(Sound::ITEMSOUND_QUEST_ACCEPT)
      end
    end

    self
  end

  def give_adena(count : Int, apply_rates : Bool)
    if apply_rates
      count *= Config.rate_quest_reward_adena
    end

    give_items(Inventory::ADENA_ID, count.to_i64)
  end

  def get_item_equipped(slot : Int32) : Int32
    @player.inventory.get_paperdoll_item_id(slot)
  end

  def has_quest_items?(*item_ids : Int32) : Bool
    AbstractScript.has_quest_items?(@player, *item_ids)
  end

  def get_quest_items_count(item_id : Int) : Int64
    AbstractScript.get_quest_items_count(@player, item_id)
  end

  def get_enchant_level(item_id : Int) : Int32
    AbstractScript.get_enchant_level(@player, item_id)
  end

  def give_item_randomly(item_id : Int, amount : Int, limit : Int, chance : Float64, play_sound : Bool) : Bool
    AbstractScript.give_item_randomly(@player, nil, item_id, amount, amount, limit, chance, play_sound)
  end

  def give_item_randomly(npc : L2Npc?, item_id : Int, amount : Int, limit : Int, chance : Float64, play_sound : Bool) : Bool
    AbstractScript.give_item_randomly(@player, npc, item_id, amount, amount, limit, chance, play_sound)
  end

  def give_item_randomly(npc : L2Npc?, item_id : Int, min_amount : Int, max_amount : Int, limit : Int, chance : Float64, play_sound : Bool) : Bool
    AbstractScript.give_item_randomly(@player, npc, amount, limit, min_amount, max_amount, limit, chance, play_sound)
  end

  def reward_items(*args)
    AbstractScript.reward_items(@player, *args)
  end

  def add_spawn(npc_id : Int32) : L2Npc
    add_spawn(npc_id, *@player.xyz, 0, false, 0, false)
  end

  def add_spawn(npc_id : Int32, despawn_delay : Int32) : L2Npc
    add_spawn(npc_id, *@player.xyz, 0, false, despawn_delay, false)
  end

  def add_spawn(npc_id : Int32, x : Int32, y : Int32, z : Int32) : L2Npc
    add_spawn(npc_id, x, y, z, 0, false, 0, false)
  end

  def add_spawn(npc_id : Int32, x : Int32, y : Int32, z : Int32, despawn_delay : Int32) : L2Npc
    add_spawn(npc_id, x, y, z, 0, false, despawn_delay, false)
  end

  def add_spawn(npc_id : Int32, char : L2Character) : L2Npc
    add_spawn(npc_id, *char.xyz, char.heading, true, 0, false)
  end

  def add_spawn(npc_id : Int32, char : L2Character, despawn_delay : Int32) : L2Npc
    add_spawn(npc_id, *char.xyz, char.heading, true, despawn_delay, false)
  end

  def add_spawn(npc_id : Int32, char : L2Character, random_offset : Bool, despawn_delay : Int32) : L2Npc
    add_spawn(npc_id, *char.xyz, char.heading, random_offset, despawn_delay, false)
  end

  def add_spawn(npc_id : Int32, x : Int32, y : Int32, z : Int32, heading : Int32, random_offset : Bool, despawn_delay : Int32) : L2Npc
    add_spawn(npc_id, x, y, z, heading, random_offset, despawn_delay, false)
  end

  def add_spawn(npc_id : Int32, x : Int32, y : Int32, z : Int32, heading : Int32, random_offset : Bool, despawn_delay : Int32, summon_spawn : Bool) : L2Npc
    AbstractScript.add_spawn(npc_id, x, y, z, heading, random_offset, despawn_delay, summon_spawn)
  end

  def set_restart_time
    cal = Calendar.new
    if cal.hour >= quest.reset_hour
      cal.add(1.day)
    end
    cal.hour = quest.reset_hour
    cal.minute = quest.reset_minutes
    set("restartTime", cal.ms.to_s)
  end

  def now_available? : Bool
    val = get("restartTime")
    val.nil? || (!val.number? || val.to_i <= Time.ms)
  end

  def set_nr_memo(pc : L2PcInstance, value : Int32)
    set("NRmemo", value.to_s)
  end

  def remove_nr_memo(pc : L2PcInstance, value : Int32)
    unset("NRmemo")
  end

  def set_nr_memo_state(pc : L2PcInstance, slot : Int32, value : Int32)
    set("NRmemoState#{slot}", value.to_s)
  end

  def get_nr_memo_state(pc : L2PcInstance, slot : Int32) : Int32
    get_int("NRmemoState#{slot}")
  end

  def set_nr_memo_state_ex(pc : L2PcInstance, slot : Int32, unknown : Int32, value : Int32)
    set("NRmemoStateEx#{slot}", value.to_s)
  end

  def get_nr_memo_state_ex(pc : L2PcInstance, slot : Int32, unknown : Int32) : Int32
    get_int("NRmemoStateEx#{slot}")
  end

  def has_nr_memo?(pc : L2PcInstance, slot : Int32) : Bool
    get_int("NRmemo") == slot
  end

  def set_nr_flag_journal(pc : L2PcInstance, quest_id : Int32, flag_id : Int32)
    set("NRFlagJournal", flag_id.to_s)
  end

  def set_flag_journal(flag_id : Int32)
    set("FlagJournal", flag_id.to_s)
  end

  def reset_flag_journal(flag_id : Int32)
    unset("FlagJournal")
  end

  def to_log(io : IO)
    io.print("QuestState(", @quest_name, ')')
  end
end
