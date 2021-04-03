require "./abstract_player_group"
require "./entity/dimensional_rift"

class L2Party < AbstractPlayerGroup
  include Synchronizable

  private BONUS_EXP_SP = {1.0, 1.10, 1.20, 1.30, 1.40, 1.50, 2.0, 2.10, 2.20}
  private PARTY_POSITION_BROADCAST_INTERVAL = 12
  private PARTY_DISTRIBUTION_TYPE_REQUEST_TIMEOUT = 15

  @position_broadcast_task : TaskScheduler::PeriodicTask?
  @change_distribution_type_request_task : TaskScheduler::DelayedTask?
  @change_distribution_type_answers : Set(Int32)?
  @position_packet : PartyMemberPosition?
  @item_last_loot = 0
  @pending_invite_timeout = 0
  @disbanding = false
  @change_request_distribution_type : PartyDistributionType?
  @party_lvl : Int32

  getter members : Concurrent::Array(L2PcInstance)
  getter? pending_invitation = false
  property distribution_type : PartyDistributionType
  property command_channel : L2CommandChannel?
  property dimensional_rift : DimensionalRift?

  enum MessageType : UInt8
    Expelled
    Left
    None
    Disconnected
  end

  def initialize(leader : L2PcInstance, dist_type : PartyDistributionType)
    @distribution_type = dist_type
    @members = Concurrent::Array { leader }
    @party_lvl = leader.level
  end

  def position_packet : PartyMemberPosition
    @position_packet ||= PartyMemberPosition.new(self)
  end

  def pending_invitation=(val : Bool)
    @pending_invitation = val
    ticks = GameTimer.ticks
    timeout = L2PcInstance::REQUEST_TIMEOUT
    tps = GameTimer::TICKS_PER_SECOND
    @pending_invite_timeout = ticks + (timeout * tps)
  end

  def invitation_request_expired? : Bool
    @pending_invite_timeout <= GameTimer.ticks
  end

  def get_checked_random_member(item_id : Int32, target : L2Character) : L2PcInstance?
    @members.select do |m|
      m.inventory.validate_capacity_by_item_id(item_id) &&
        Util.in_range?(Config.alt_party_range2, target, m, true)
    end
    .sample?(random: Rnd)
  end

  def get_checked_next_looter(item_id : Int32, target : L2Character) : L2PcInstance?
    size.times do
      @item_last_loot &+= 1
      if @item_last_loot >= size
        @item_last_loot = 0
      end

      m = members[@item_last_loot]
      if m.inventory.validate_capacity_by_item_id(item_id)
        if Util.in_range?(Config.alt_party_range2, target, m, true)
          return m
        end
      end
    end

    nil
  end

  def broadcast_to_party_members_new_leader
    each do |m|
      m.send_packet(PartySmallWindowDeleteAll::STATIC_PACKET)
      m.send_packet(PartySmallWindowAll.new(m, self))
      m.broadcast_user_info
    end
  end

  def broadcast_to_party_members(pc : L2PcInstance, gsp : GameServerPacket)
    each { |m| m.send_packet(gsp) unless m == pc }
  end

  def add_party_member(pc : L2PcInstance)
    return if @members.includes?(pc)

    finish_loot_request(false) if @change_request_distribution_type

    pc.send_packet(PartySmallWindowAll.new(pc, self))

    each do |m|
      if summon = m.summon
        pc.send_packet(ExPartyPetWindowAdd.new(summon))
      end
    end

    sm = SystemMessage.you_joined_s1_party
    sm.add_string(leader.name)
    pc.send_packet(sm)

    sm = SystemMessage.c1_joined_party
    sm.add_string(pc.name)
    broadcast_packet(sm)
    broadcast_packet(PartySmallWindowAdd.new(pc, self))

    if summon = pc.summon
      broadcast_packet(ExPartyPetWindowAdd.new(summon))
    end

    @members << pc

    if pc.level > @party_lvl
      @party_lvl = pc.level
    end

    each do |m|
      m.update_effect_icons(true)
      m.broadcast_user_info
      m.summon.try &.update_effect_icons
    end

    dimensional_rift.try &.party_member_invited

    if in_command_channel?
      pc.send_packet(ExOpenMPCC::STATIC_PACKET)
    end

    @position_broadcast_task ||= begin
      task = -> { broadcast_packet(position_packet.reuse(self)) }
      time = (PARTY_POSITION_BROADCAST_INTERVAL &* 1000) / 2
      ThreadPoolManager.schedule_general_at_fixed_rate(task, time, time)
    end
  end

  def remove_party_member(name : String, type : MessageType)
    remove_party_member(get_player_by_name(name), type)
  end

  def remove_party_member(pc : L2PcInstance, type : MessageType)
    if @members.includes?(pc)
      is_leader = leader?(pc)
      unless @disbanding
        if @members.size == 2 || (is_leader && !Config.alt_leave_party_leader && !type.disconnected?)
          disband_party
          return
        end
      end

      @members.delete_first(pc)
      recalculate_party_level
      if pc.festival_participant?
        SevenSignsFestival.instance.update_participants(pc, self)
      end

      if pc.channeling? && pc.skill_channelizer.has_channelized?
        pc.abort_cast
      elsif pc.channelized?
        pc.skill_channelized.abort_channelization
      end

      if type.expelled?
        pc.send_packet(SystemMessageId::HAVE_BEEN_EXPELLED_FROM_PARTY)
        sm = SystemMessage.c1_was_expelled_from_party
        sm.add_string(pc.name)
        broadcast_packet(sm)
      elsif type.left? || type.disconnected?
        pc.send_packet(SystemMessageId::YOU_LEFT_PARTY)
        sm = SystemMessage.c1_left_party
        sm.add_string(pc.name)
        broadcast_packet(sm)
      end

      pc.send_packet(PartySmallWindowDeleteAll::STATIC_PACKET)
      pc.party = nil
      broadcast_packet(PartySmallWindowDelete.new(pc))
      if summon = pc.summon
        broadcast_packet(ExPartyPetWindowDelete.new(summon))
      end

      if rift = dimensional_rift
        rift.party_member_exited(pc)
      end

      if in_command_channel?
        pc.send_packet(ExCloseMPCC::STATIC_PACKET)
      end

      if is_leader && @members.size > 1 && (Config.alt_leave_party_leader || type.disconnected?)
        sm = SystemMessage.c1_has_become_a_party_leader
        sm.add_string(leader.name)
        broadcast_packet(sm)
        broadcast_to_party_members_new_leader
      elsif @members.size == 1
        if cc = command_channel
          if cc.leader.l2id == leader.l2id
            cc.disband_channel
          else
            cc.remove_party(self)
          end
        end

        leader.party = nil

        if task = @change_distribution_type_request_task
          task.cancel
          @change_distribution_type_request_task = nil
        end

        @members.clear
      end
    end
  end

  def disband_party
    @disbanding = true
    broadcast_packet(SystemMessage.party_dispersed)
    @members.each { |m| remove_party_member(m, MessageType::None) }
  end

  def change_party_leader(name : String)
    self.leader = get_player_by_name(name)
  end

  def leader=(pc : L2PcInstance)
    return if pc.in_duel?

    if idx = @members.index(pc)
      if leader?(pc)
        pc.send_packet(SystemMessageId::YOU_CANNOT_TRANSFER_RIGHTS_TO_YOURSELF)
      else
        temp = leader()
        @members[0] = pc
        @members[idx] = temp

        sm = SystemMessage.c1_has_become_a_party_leader
        sm.add_string(leader().name)
        broadcast_packet(sm)
        broadcast_to_party_members_new_leader
        if (cc = command_channel) && cc.leader?(temp)
          cc.leader = leader()
          sm = SystemMessage.command_channel_leader_now_c1
          sm.add_string(cc.leader.name)
          cc.broadcast_packet(sm)
        end
        if pc.in_party_match_room?
          room = PartyMatchRoomList.get_player_room(pc).not_nil!
          room.change_leader(pc)
        end
      end
    else
      pc.send_packet(SystemMessageId::YOU_CAN_TRANSFER_RIGHTS_ONLY_TO_ANOTHER_PARTY_MEMBER)
    end
  end

  def get_player_by_name(name : String) : L2PcInstance
    @members.find { |m| m.name.casecmp?(name) } ||
      raise "Party member with name '#{name}' not found."
  end

  def recalculate_party_level : Int32
    @party_lvl = @members.max_of &.level
  end

  def level : Int32
    @party_lvl
  end

  def leader : L2PcInstance
    @members[0]
  end

  def distribute_item(pc : L2PcInstance, item : L2ItemInstance)
    count = item.count

    if item.id == Inventory::ADENA_ID
      distribute_adena(pc, count, pc)
      ItemTable.destroy_item("Party", item, pc, nil)
      return
    end

    target = get_actual_looter(pc, item.id, false, pc)
    target.add_item("Party", item, pc, true)

    return unless count > 0

    if count > 1
      sm = SystemMessage.c1_obtained_s3_s2
      sm.add_string(target.name)
      sm.add_item_name(item)
      sm.add_long(count)
    else
      sm = SystemMessage.c1_obtained_s2
      sm.add_string(target.name)
      sm.add_item_name(item)
    end

    broadcast_to_party_members(target, sm)
  end

  def distribute_item(pc : L2PcInstance, item_id : Int32, item_count : Int64, spoil : Bool, target : L2Attackable)
    if item_id == Inventory::ADENA_ID
      distribute_adena(pc, item_count, target)
      return
    end

    looter = get_actual_looter(pc, item_id, spoil, target)

    str = spoil ? "Sweeper Party" : "Party"
    looter.add_item(str, item_id, item_count, target, true)

    if item_count > 0
      if item_count > 1
        if spoil
          sm = SystemMessage.c1_sweeped_up_s3_s2
        else
          sm = SystemMessage.c1_obtained_s3_s2
        end

        sm.add_string(looter.name)
        sm.add_item_name(item_id)
        sm.add_long(item_count)
      else
        if spoil
          sm = SystemMessage.c1_sweeped_up_s2
        else
          sm = SystemMessage.c1_obtained_s2
        end

        sm.add_string(looter.name)
        sm.add_item_name(item_id)
      end

      broadcast_to_party_members(looter, sm)
    end
  end

  def distribute_item(pc : L2PcInstance, item : ItemHolder, spoil : Bool, target : L2Attackable)
    distribute_item(pc, item.id, item.count, spoil, target)
  end

  # Using Atomic(Int64) doesn't work.
  def distribute_adena(pc : L2PcInstance, adena : Int64, target : L2Character)
    rewards = Hash(L2PcInstance, Int64).new(initial_capacity: size)

    members.each do |m|
      if Util.in_range?(Config.alt_party_range2, target, m, true)
        rewards[m] = 0i64
      end
    end

    return if rewards.empty?

    count, left_over = adena.divmod(rewards.size)

    if count > 0
      rewards.transform_values! { |v| v + count }
    end

    if left_over > 0
      keys = rewards.keys_slice
      left_over.times do
        rewards[keys.sample(random: Rnd)] += 1
      end
    end

    rewards.each do |m, value|
      if value > 0
        m.add_adena("Party", value, pc, true)
      end
    end
  end

  def distribute_xp_and_sp(xp_reward : Int64, sp_reward : Int32, rewarded_members : Enumerable(L2PcInstance), top_lvl : Int, party_dmg : Int32, target : L2Attackable)
    valid_members = get_valid_members(rewarded_members, top_lvl)
    xp_reward *= get_exp_bonus(valid_members.size)
    sp_reward *= get_sp_bonus(valid_members.size)
    sq_level_sum = valid_members.sum &.level.abs2

    vitality_points = target.get_vitality_points(party_dmg) * Config.rate_party_xp
    vitality_points /= valid_members.size
    use_vitality_rate = target.use_vitality_rate?

    rewarded_members.each do |m|
      next if m.dead?

      if valid_members.includes?(m)
        sq_level = Math.pow(m.level, 2)
        pre_calc = sq_level / sq_level_sum
        if smn = m.summon.as?(L2ServitorInstance)
          pre_calc *= smn.exp_multiplier
        end
        add_exp = m.calc_stat(Stats::EXPSP_RATE, xp_reward * pre_calc).round.to_i64
        add_sp = m.calc_stat(Stats::EXPSP_RATE, sp_reward * pre_calc).to_i32
        add_exp = calculate_exp_sp_party_cutoff(m, top_lvl, add_exp, add_sp, use_vitality_rate)
        if add_exp > 0
          m.update_vitality_points(vitality_points, true, false)
        end
      else
        m.add_exp_and_sp(0, 0)
      end
    end
  end

  private def calculate_exp_sp_party_cutoff(pc : L2PcInstance, top_lvl : Int32, add_exp : Int64, add_sp : Int32, vit : Bool)
    xp, sp = add_exp, add_sp

    if Config.party_xp_cutoff_method.casecmp?("highfive")
      lvl_diff = top_lvl &- pc.level
      Config.party_xp_cutoff_gaps.each_with_index do |gap, i|
        if lvl_diff.between?(gap[0], gap[1])
          xp = (add_exp * Config.party_xp_cutoff_gap_percents[i]).to_i64 // 100
          sp = (add_sp * Config.party_xp_cutoff_gap_percents[i]) // 100
          pc.add_exp_and_sp(xp, sp, vit)
          break
        end
      end
    else
      pc.add_exp_and_sp(add_exp, add_sp, vit)
    end

    xp
  end

  private def get_valid_members(members, top_lvl)
    valid_members = [] of L2PcInstance

    if Config.party_xp_cutoff_method.casecmp?("level")
      members.each do |m|
        if top_lvl &- m.level <= Config.party_xp_cutoff_level
          valid_members << m
        end
      end
    elsif Config.party_xp_cutoff_method.casecmp?("percentage")
      sq_level_sum = members.reduce(0) { |c, m| c + Math.pow(m.level, 2) }
      members.each do |m|
        sq_level = Math.pow(m.level, 2)
        if sq_level * 100 >= sq_level_sum * Config.party_xp_cutoff_percent
          valid_members << m
        end
      end
    elsif Config.party_xp_cutoff_method.casecmp?("auto")
      sq_level_sum = members.reduce(0) { |c, m| c + Math.pow(m.level, 2) }

      i = members.size &- 1
      return members if i < 1

      members.each do |m|
        sq_level = Math.pow(m.level, 2)
        if sq_level >= sq_level_sum / Math.pow(members.size, 2)
          valid_members << m
        end
      end
    elsif Config.party_xp_cutoff_method.casecmp?("highfive")
      valid_members.concat(members)
    elsif Config.party_xp_cutoff_method.casecmp?("none")
      valid_members.concat(members)
    end

    valid_members
  end

  private def get_base_exp_sp_bonus(members_count)
    i = members_count &- 1
    return 1 if i < 1
    if i >= BONUS_EXP_SP.size
      i = -1
    end

    BONUS_EXP_SP[i]
  end

  def get_exp_bonus(members_count : Int32) : Float64
    if members_count < 2
      get_base_exp_sp_bonus(members_count)
    else
      get_base_exp_sp_bonus(members_count) * Config.rate_party_xp
    end
    .to_f64
  end

  def get_sp_bonus(members_count : Int32) : Float64
    if members_count < 2
      get_base_exp_sp_bonus(members_count)
    else
      get_base_exp_sp_bonus(members_count) * Config.rate_party_sp
    end
    .to_f64
  end

  def in_command_channel? : Bool
    !!@command_channel
  end

  def in_dimensional_rift? : Bool
    !!@dimensional_rift
  end

  def request_loot_change(distribution_type : PartyDistributionType)
    sync do
      return if @change_request_distribution_type

      @change_request_distribution_type = distribution_type
      @change_distribution_type_answers = Set(Int32).new
      delay = PARTY_DISTRIBUTION_TYPE_REQUEST_TIMEOUT &* 1000
      task = -> { finish_loot_request(false) }
      @change_distribution_type_request_task = ThreadPoolManager.schedule_general(task, delay)

      broadcast_to_party_members(
        leader,
        ExAskModifyPartyLooting.new(leader.name, distribution_type)
      )

      sm = SystemMessage.requesting_approval_change_party_loot_s1
      sm.add_system_string(distribution_type.sys_string_id)
      leader.send_packet(sm)
    end
  end

  def answer_loot_change_request(member : L2PcInstance, answer : Bool)
    sync do
      unless @change_request_distribution_type
        return
      end

      unless answers_list = @change_distribution_type_answers
        raise "@change_distribution_type_answers is nil"
      end

      if answers_list.includes?(member.l2id)
        return
      end

      unless answer
        finish_loot_request(false)
        return
      end

      answers_list << member.l2id

      if answers_list.size >= size &- 1
        finish_loot_request(true)
      end
    end
  end

  def finish_loot_request(success : Bool)
    sync do
      return unless temp = @change_request_distribution_type
      if task = @change_distribution_type_request_task
        task.cancel
        @change_distribution_type_request_task = nil
      end
      if success
        broadcast_packet(ExSetPartyLooting.new(1, temp))
        @distribution_type = temp
        sm = SystemMessage.party_loot_changed_s1
        sm.add_system_string(temp.sys_string_id)
        broadcast_packet(sm)
      else
        broadcast_packet(ExSetPartyLooting.new(0, @distribution_type))
        broadcast_packet(SystemMessage.party_loot_change_cancelled)
      end

      @change_request_distribution_type = nil
      @change_distribution_type_answers = nil
    end
  end

  private def get_actual_looter(pc : L2PcInstance, item_id : Int32, spoil : Bool, target) : L2PcInstance
    case @distribution_type
    when PartyDistributionType::RANDOM
      unless spoil
        looter = get_checked_random_member(item_id, target)
      end
    when PartyDistributionType::RANDOM_INCLUDING_SPOIL
      looter = get_checked_random_member(item_id, target)
    when PartyDistributionType::BY_TURN
      unless spoil
        looter = get_checked_next_looter(item_id, target)
      end
    when PartyDistributionType::BY_TURN_INCLUDING_SPOIL
      looter = get_checked_next_looter(item_id, target)
    end

    looter || pc
  end
end
