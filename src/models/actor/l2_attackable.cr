require "./l2_npc"
require "../aggro_info"
require "../absorber_info"
require "../l2_command_channel"
require "./ai/l2_attackable_ai"
require "./known_list/attackable_known_list"
require "./status/attackable_status"
require "../damage_done_info"
require "./tasks/attackable/*"

class L2Attackable < L2Npc
  @harvest_item = Atomic(ItemHolder?).new(nil.as(ItemHolder?))
  @sweep_items = Atomic(Array(ItemHolder)?).new(nil.as(Array(ItemHolder)?))

  getter aggro_list = Concurrent::Map(L2Character, AggroInfo).new
  getter overhit_attacker : L2Character?
  getter overhit_damage = 0.0
  getter absorbers_list = Concurrent::Map(Int32, AbsorberInfo).new
  getter seed : L2Seed?
  getter? seeded = false
  getter? raid_minion = false
  getter? absorbed = false
  property seeder_id : Int32 = 0
  property spoiler_l2id : Int32 = 0
  property command_channel_last_attack : Int64 = 0
  property on_kill_delay : Int32 = 5000
  property command_channel_timer : CommandChannelTimer?
  property first_command_channel_attacked : L2CommandChannel?
  property? overhit : Bool = false
  property? champion : Bool = false
  property? raid : Bool = false
  property? must_reward_exp_sp : Bool = true
  property? can_return_to_spawn_point : Bool = true
  property? returning_to_spawn_point : Bool = false
  property? can_see_through_silent_move : Bool = false

  def initialize(template : L2NpcTemplate)
    super(template)
    self.invul = false
  end

  def instance_type : InstanceType
    InstanceType::L2Attackable
  end

  private def init_ai : L2CharacterAI
    L2AttackableAI.new(self)
  end

  private def init_char_status
    @status = AttackableStatus.new(self)
  end

  def status : AttackableStatus
    super.as(AttackableStatus)
  end

  private def init_known_list
    @known_list = AttackableKnownList.new(self)
  end

  def known_list : AttackableKnownList
    super.as(AttackableKnownList)
  end

  def use_magic(skill : Skill)
    if looks_dead? || skill.passive? || casting_now? || skill_disabled?(skill)
      return
    end

    if current_mp < stat.get_mp_consume1(skill) &+ stat.get_mp_consume2(skill)
      return
    end

    if current_hp <= skill.hp_consume
      return
    end

    unless skill.static?
      if skill.magic?
        if muted?
          return
        end
      else
        if physical_muted?
          return
        end
      end
    end

    if target = skill.get_first_of_target_list(self)
      set_intention(AI::CAST, skill, target)
    end
  end

  def reduce_current_hp(damage : Float64, attacker : L2Character?, skill : Skill?)
    reduce_current_hp(damage, attacker, true, false, skill)
  end

  def reduce_current_hp(damage : Float64, attacker : L2Character?, awake : Bool, dot : Bool, skill : Skill?)
    cc = attacker.try &.party.try &.command_channel

    if raid? && !minion? && cc && cc.meets_raid_war_condition?(self)
      if @first_command_channel_attacked.nil?
        sync do
          unless @first_command_channel_attacked
            if cc = attacker.try &.party.try &.command_channel
              timer = CommandChannelTimer.new(self)
              @command_channel_timer = timer
              @command_channel_last_attack = Time.ms
              ThreadPoolManager.schedule_general(timer, 10_000)
              cs = CreatureSay.new(0, Packets::Incoming::Say2::PARTYROOM_ALL, "", "You have looting rights!") # L2J TODO: retail message
              cc.broadcast_packet(cs)
              @first_command_channel_attacked = cc
            end
          end
        end
      elsif cc == @first_command_channel_attacked
        @command_channel_last_attack = Time.ms
      end
    end

    if event_mob?
      return
    end

    if attacker
      add_damage(attacker, damage.to_i32, skill)
    end

    if monster?
      master = self
      unless master.is_a?(L2MonsterInstance)
        raise "Expected #{master}:#{master.class} to be a L2MonsterInstance"
      end
      if master.has_minions?
        master.minion_list.on_assist(self, attacker)
      end

      if (master = master.leader) && master.has_minions?
        master.minion_list.on_assist(self, attacker)
      end
    end

    super
  end

  def do_die(killer : L2Character?) : Bool
    return false unless super

    if killer && (pc = killer.acting_player)
      evt = OnAttackableKill.new(pc, self, killer.summon?)
      evt.delayed(self, @on_kill_delay.to_i64)
    end

    mob = self

    if mob.is_a?(L2MonsterInstance)
      if (leader = mob.leader) && leader.has_minions?
        respawn_time = Config.minions_respawn_time.fetch(id, -1)
        leader.minion_list.on_minion_die(mob, respawn_time)
      end

      if mob.has_minions?
        mob.minion_list.on_master_die(false)
      end
    end

    true
  end

  def calculate_rewards(last_attacker : L2Character?)
    return if @aggro_list.empty?

    rewards = {} of L2PcInstance => DamageDoneInfo

    max_dealer = nil
    max_damage = 0
    total_damage = 0i64

    @aggro_list.each_value do |info|
      if attacker = info.attacker.acting_player
        damage = info.damage
        if damage > 1
          unless Util.in_range?(Config.alt_party_range, self, attacker, true)
            next
          end

          total_damage += damage

          reward = rewards[attacker] ||= DamageDoneInfo.new(attacker)
          reward.add_damage(damage)

          if reward.damage > max_damage
            max_dealer = attacker
            max_damage = reward.damage
          end
        end
      end
    end

    if max_dealer && max_dealer.online?
      do_item_drop(max_dealer)
    else
      do_item_drop(last_attacker)
    end

    do_event_drop(last_attacker)

    return unless must_reward_exp_sp?

    unless rewards.empty?
      rewards.each_value do |reward|
        attacker = reward.attacker
        damage = reward.damage
        attacker_party = attacker.party
        if smn = attacker.summon.as?(L2ServitorInstance)
          penalty = smn.exp_multiplier
        end

        if attacker_party.nil?
          if attacker.known_list.knows_object?(self)
            lvl_diff = attacker.level &- level

            exp, sp = calculate_exp_and_sp(lvl_diff, damage, total_damage)

            if Config.champion_enable && champion?
              exp *= Config.champion_rewards_exp_sp
              sp  *= Config.champion_rewards_exp_sp
            end

            if penalty
              exp *= penalty
            end

            if overhit?
              if overhit_attacker = @overhit_attacker.try &.acting_player
                if attacker == overhit_attacker
                  attacker.send_packet(SystemMessageId::OVER_HIT)
                  exp += calculate_overhit_exp(exp.to_i64)
                end
              end
            end

            unless attacker.dead?
              add_exp = attacker.calc_stat(Stats::EXPSP_RATE, exp).round.to_i
              add_sp = attacker.calc_stat(Stats::EXPSP_RATE, sp).to_i

              attacker.add_exp_and_sp(add_exp.to_i64, add_sp, use_vitality_rate?)
              if add_exp > 0
                new_vit = get_vitality_points(damage)
                attacker.update_vitality_points(new_vit, true, false)
              end
            end
          end
        else
          party_dmg = 0
          party_mul = 1.0
          party_lvl = 0

          rewarded_members = [] of L2PcInstance
          if cc = attacker_party.command_channel
            group_members = cc.members
          else
            group_members = attacker_party.members
          end

          group_members.each do |party_player|
            next if party_player.dead?

            if reward2 = rewards[party_player]?
              if Util.in_range?(Config.alt_party_range, self, party_player, true)
                party_dmg += reward2.damage
                rewarded_members << party_player
                if party_player.level > party_lvl
                  if cc = attacker_party.command_channel
                    party_lvl = cc.level
                  else
                    party_lvl = party_player.level
                  end
                end
              end
              rewards.delete(party_player)
            else
              if Util.in_range?(Config.alt_party_range, self, party_player, true)
                rewarded_members << party_player
                if party_player.level > party_lvl
                  if cc = attacker_party.command_channel
                    party_lvl = cc.level
                  else
                    party_lvl = party_player.level
                  end
                end
              end
            end
          end

          if party_dmg < total_damage
            party_mul = party_dmg.fdiv(total_damage)
          end

          lvl_diff = party_lvl &- level

          exp, sp = calculate_exp_and_sp(lvl_diff, party_dmg, total_damage)

          if Config.champion_enable && champion?
            exp *= Config.champion_rewards_exp_sp
            sp *= Config.champion_rewards_exp_sp
          end

          exp *= party_mul
          sp *= party_mul

          if overhit?
            if overhit_attacker = overhit_attacker()
              if overhit_pc = overhit_attacker.acting_player
                if attacker == overhit_pc
                  attacker.send_packet(SystemMessageId::OVER_HIT)
                  exp += calculate_overhit_exp(exp.to_i64)
                end
              end
            end
          end

          if party_dmg > 0
            attacker_party.distribute_xp_and_sp(
              exp.to_i64,
              sp.to_i32,
              rewarded_members,
              party_lvl,
              party_dmg,
              self
            )
          end
        end
      end
    end
  end

  def add_attacker_to_attack_by_list(player : L2Character?)
    return unless player
    return if player == self
    attack_by_list << player
  end

  def add_damage(attacker : L2Character, damage : Int32, skill : Skill?)
    return if dead?

    if walker? && !core_ai_disabled? && WalkingManager.on_walk?(self)
      WalkingManager.stop_moving(self, false, true)
    end

    notify_event(AI::ATTACKED, attacker)

    add_damage_hate(attacker, damage, (damage.to_i64 * 100) // (level &+ 7))

    if pc = attacker.acting_player
      evt = OnAttackableAttack.new(pc, self, damage.to_i, skill, attacker.summon?)
      evt.async(self)
    end
  rescue e
    error e
  end

  def add_damage_hate(attacker : L2Character?, damage : Int, aggro : Int)
    return unless attacker

    damage = damage.to_i32
    aggro = aggro.to_i64

    info = @aggro_list[attacker] ||= AggroInfo.new(attacker)
    info.add_damage(damage)

    if target_player = attacker.acting_player
      if trap = target_player.trap
        unless trap.triggered?
          info.add_hate(aggro)
        end
      else
        info.add_hate(aggro)
      end
    else
      info.add_hate(aggro)
    end

    if target_player && aggro == 0
      add_damage_hate(attacker, 0, 1)

      if intention.idle?
        set_intention(AI::ACTIVE)
      end

      evt = OnAttackableAggroRangeEnter.new(self, target_player, attacker.summon?)
      evt.async(self)
    elsif target_player.nil? && aggro == 0
      aggro = 1
      info.add_hate(1)
    end

    if aggro != 0 && intention.idle?
      set_intention(AI::ACTIVE)
    end
  end

  def reduce_hate(target : L2Character?, amount : Int)
    amount = amount.to_i64
    if ai.is_a?(L2SiegeGuardAI) || ai.is_a?(L2FortSiegeGuardAI)
      stop_hating(target)
      self.target = nil
      set_intention(AI::IDLE)
      return
    end

    unless target
      unless most_hated = most_hated()
        ai.as(L2AttackableAI).global_aggro = -25
        return
      end

      @aggro_list.each_value &.add_hate(amount)

      amount = get_hating(most_hated)

      if amount >= 0
        ai.as(L2AttackableAI).global_aggro = -25
        clear_aggro_list
        set_intention(AI::ACTIVE)
        set_walking
      end

      return
    end

    unless info = @aggro_list[target]?
      debug { "Target #{target} not present in aggro list of #{self}" }
      return
    end

    info.add_hate(amount)

    if info.hate >= 0 && !most_hated()
      ai.as(L2AttackableAI).global_aggro = -25
      clear_aggro_list
      set_intention(AI::ACTIVE)
      set_walking
    end
  end

  def stop_hating(target : L2Character?)
    @aggro_list[target]?.try &.stop_hate if target
  end

  def most_hated : L2Character?
    return if @aggro_list.empty? || looks_dead?

    most_hated = nil
    max_hate = 0

    @aggro_list.each_value do |info|
      if info.check_hate(self) > max_hate
        most_hated = info.attacker
        max_hate = info.hate
      end
    end

    most_hated
  end

  def get_2_most_hated : {L2Character?, L2Character?}
    return {nil, nil} if @aggro_list.empty? || looks_dead?

    most_hated = nil
    second_most_hated = nil
    max_hate = 0

    @aggro_list.each_value do |info|
      if info.check_hate(self) > max_hate
        second_most_hated = most_hated
        most_hated = info.attacker
        max_hate = info.hate
      end
    end

    if second_most_hated && attack_by_list.includes?(second_most_hated)
      {most_hated, second_most_hated}
    else
      {most_hated, nil}
    end
  end

  def hate_list : Array(L2Character)?
    if @aggro_list.empty? || looks_dead?
      return
    end

    ret = Array(L2Character).new(@aggro_list.size)

    @aggro_list.each_value do |info|
      info.check_hate(self)
      ret << info.attacker
    end

    ret
  end

  def get_hating(target : L2Character?) : Int64
    return 0i64 if target.nil? || @aggro_list.empty?
    return 0i64 unless info = @aggro_list[target]?
    attacker = info.attacker

    if pc = attacker.as?(L2PcInstance)
      if pc.invisible? || pc.invul? || pc.spawn_protected?
        @aggro_list.delete(target)
        return 0i64
      end
    end

    if !attacker.visible? || attacker.invisible?
      @aggro_list.delete(target)
      return 0i64
    end

    if attacker.looks_dead?
      info.stop_hate
      return 0i64
    end

    info.hate
  end

  def do_item_drop(killer : L2Character?)
    do_item_drop(template, killer)
  end

  def do_item_drop(template : L2NpcTemplate, killer : L2Character?)
    return unless killer
    return unless pc = killer.acting_player

    CursedWeaponsManager.check_drop(self, pc)

    if spoiled?
      @sweep_items.set(template.calculate_drops(DropListScope::CORPSE, self, pc))
    end

    if drops = template.calculate_drops(DropListScope::DEATH, self, pc)
      drops.each do |drop|
        next unless item = ItemTable[drop.id]?

        if flying? || (!item.has_ex_immediate_effect? && ((!raid? && Config.auto_loot) || (raid? && Config.auto_loot_raids)))
          pc.do_auto_loot(self, drop)
        else
          drop_item(pc, drop)
        end

        if raid? && !raid_minion? && drop.count > 0
          sm = SystemMessage.c1_died_dropped_s3_s2
          sm.add_char_name(self)
          sm.add_item_name(item)
          sm.add_long(drop.count)
          broadcast_packet(sm)
        end
      end
    end

    if Config.champion_enable && champion? && (Config.champion_reward_lower_lvl_item_chance > 0 || Config.champion_reward_higher_lvl_item_chance > 0)
      champqty = Rnd.rand(Config.champion_reward_qty).to_i64
      item = ItemHolder.new(Config.champion_reward_id, champqty &+ 1)

      if pc.level <= level && Rnd.rand(100) < Config.champion_reward_lower_lvl_item_chance
        if Config.auto_loot || flying?
          pc.add_item("ChampionLoot", item.id, item.count, self, true)
        else
          drop_item(pc, item)
        end
      elsif pc.level > level && Rnd.rand(100) < Config.champion_reward_higher_lvl_item_chance
        if Config.auto_loot || flying?
          pc.add_item("ChampionLoot", item.id, item.count, self, true)
        else
          drop_item(pc, item)
        end
      end
    end
  end

  def do_event_drop(last_attacker : L2Character?)
    return unless last_attacker
    return unless pc = last_attacker.acting_player

    if pc.level &- level > 9
      return
    end

    EventDroplist.all_drops.each do |drop|
      ev_drop = drop.event_drop
      if Rnd.rand(1_000_000) < ev_drop.drop_chance
        item_id = ev_drop.item_id_list.sample(random: Rnd)
        item_count = Rnd.rand(ev_drop.min_count..ev_drop.max_count)
        if Config.auto_loot || flying?
          pc.do_auto_loot(self, item_id, item_count)
        else
          drop_item(pc, item_id, item_count)
        end
      end
    end
  end

  def in_aggro_list?(char : L2Character) : Bool
    @aggro_list.has_key?(char)
  end

  def clear_aggro_list
    @aggro_list.clear
    @overhit = false
    @overhit_damage = 0
    @overhit_attacker = nil
  end

  def sweep_active? : Bool
    !!@sweep_items.get
  end

  def spoil_loot_items : Slice(L2Item)
    if items = @sweep_items.get
      return items.slice_map { |it| ItemTable[it.id] }
    end

    Slice(L2Item).empty
  end

  def take_sweep : Array(ItemHolder)?
    @sweep_items.swap(nil)
  end

  def take_harvest : ItemHolder?
    @harvest_item.swap(nil)
  end

  def old_corpse?(attacker : L2PcInstance?, time : Int32, send_msg : Bool) : Bool
    if dead? && DecayTaskManager.get_remaining_time(self) < time
      if send_msg && attacker
        attacker.send_packet(SystemMessageId::CORPSE_TOO_OLD_SKILL_NOT_USED)
      end

      return true
    end

    false
  end

  def check_spoil_owner(sweeper : L2PcInstance, send_msg : Bool) : Bool
    if sweeper.l2id != spoiler_l2id && !sweeper.in_looter_party?(spoiler_l2id)
      if send_msg
        sweeper.send_packet(SystemMessageId::SWEEP_NOT_ALLOWED)
      end

      return false
    end

    true
  end

  def set_overhit_values(attacker : L2Character?, damage : Float64)
    overhit_dmg = -(current_hp - damage)

    if overhit_dmg < 0
      self.overhit = false
      @overhit_damage = 0
      @overhit_attacker = nil
      return
    end

    self.overhit = true
    @overhit_damage = overhit_dmg
    @overhit_attacker = attacker
  end

  def absorb_soul
    @absorbed = true
  end

  def add_absorber(attacker : L2PcInstance)
    if info = @absorbers_list[attacker.l2id]?
      info.absorbed_hp = current_hp
    else
      @absorbers_list[attacker.l2id] = AbsorberInfo.new(attacker.l2id, current_hp)
    end

    absorb_soul
  end

  def reset_absorb_list
    @absorbed = false
    @absorbers_list.clear
  end

  def calculate_exp_and_sp(diff : Int32, damage : Int32, total_damage : Int64) : {Int64, Int32}
    diff = -5 if diff < -5

    xp = (exp_reward.to_f * damage) / total_damage
    if Config.alt_game_exponent_xp != 0
      xp *= 2.0 ** (-diff / Config.alt_game_exponent_xp)
    end
    sp = (sp_reward.to_f * damage) / total_damage
    if Config.alt_game_exponent_sp != 0
      sp *= 2.0 ** (-diff / Config.alt_game_exponent_sp)
    end

    if Config.alt_game_exponent_xp == 0 && Config.alt_game_exponent_sp == 0
      if diff > 5
        pow = 5.fdiv(6) ** (diff &- 5)
        xp *= pow
        sp *= pow
      end

      if xp <= 0
        xp = sp = 0
      elsif sp <= 0
        sp = 0
      end
    end

    {xp.to_i64, sp.to_i32}
  end

  def calculate_overhit_exp(normal_exp : Int64) : Int64
    percent = (overhit_damage * 100.0) / max_hp
    percent = 25.0 if percent > 25
    exp = (percent / 100) * normal_exp
    exp.round.to_i64
  end

  def can_be_attacked? : Bool
    true
  end

  def on_spawn
    super

    self.spoiler_l2id = 0
    clear_aggro_list
    @harvest_item.set(nil)
    @seeded = false
    @seed = nil
    @seeder_id = 0
    self.overhit = false
    @sweep_items.set(nil)
    reset_absorb_list
    set_walking

    unless in_active_region?
      ai.stop_ai_task if ai?
    end
  end

  def spoiled? : Bool
    @spoiler_l2id != 0
  end

  def set_seeded(seeder : L2PcInstance)
    if (seed = @seed) && @seeder_id == seeder.l2id
      @seeded = true

      count = 1i64
      template.skills.each_key do |skill_id|
        case skill_id
        when 4303 then count &*= 2 # Strong type x2
        when 4304 then count &*= 3 # Strong type x3
        when 4305 then count &*= 4 # Strong type x4
        when 4306 then count &*= 5 # Strong type x5
        when 4307 then count &*= 6 # Strong type x6
        when 4308 then count &*= 7 # Strong type x7
        when 4309 then count &*= 8 # Strong type x8
        when 4310 then count &*= 9 # Strong type x9
        end
      end

      diff = level &- seed.level &- 5
      if diff > 0
        count &+= diff
      end

      item = ItemHolder.new(seed.crop_id, count * Config.rate_drop_manor)
      @harvest_item.set(item)
    end
  end

  def set_seeded(seed : L2Seed, seeder : L2PcInstance)
    unless @seeded
      @seed = seed
      @seeder_id = seeder.l2id
    end
  end

  def has_random_animation? : Bool
    Config.max_monster_animation > 0 && random_animation_enabled? &&
      !is_a?(L2GrandBossInstance)
  end

  def mob? : Bool
    true
  end

  def return_home
    clear_aggro_list
    return unless ai?
    return unless sp = spawn?
    set_intention(AI::MOVE_TO, sp.get_location(self))
  end

  def get_vitality_points(damage : Int32) : Float32
    return 0f32 if damage <= 0
    lvl = level
    exp = exp_reward

    if lvl > 0 && exp > 0
      divider = (template.base_hp_max * 9 * lvl * lvl) / (100 * exp)
    else
      divider = 0
    end

    return 0f32 if divider == 0

    (-Math.min(damage, max_hp).fdiv(divider)).to_f32
  end

  def use_vitality_rate? : Bool
    champion? ? Config.champion_enable_vitality : true
  end

  def raid_minion=(val : Bool)
    @raid = val
    @raid_minion = val
  end

  def leader : L2Attackable?
    # return nil
  end

  def minion? : Bool
    !!leader
  end

  def attackable? : Bool
    true
  end
end
