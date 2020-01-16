require "../../enums/duel_result"

class Duel
  include Packets::Outgoing
  include Loggable

  private PARTY_DUEL_DURATION = 300
  private PARTY_DUEL_PREPARE_TIME = 30
  private PARTY_DUEL_TELEPORT_BACK_TIME = 10 * 1000
  private PLAYER_DUEL_DURATION = 120
  private DUEL_PREPARE_TIME = 5

  @countdown = 0
  @player_conditions = Concurrent::Map(Int32, PlayerCondition).new
  @surrender_request = 0
  @duel_end_time : Int64

  getter duel_instance_id = 0
  getter team_a
  getter team_b
  getter? party_duel

  def initialize(@leader_a : L2PcInstance, @leader_b : L2PcInstance, @party_duel : Bool, @duel_id : Int32)
    if party_duel
      party_a, party_b = leader_a.party.not_nil!, leader_b.party.not_nil!
      @team_a = Array(L2PcInstance).new(party_a.size)
      party_a.members.each { |m| @team_a << m }
      @team_b = Array(L2PcInstance).new(party_b.size)
      party_b.members.each { |m| @team_b << m }
    else
      @team_a = [@leader_a]
      @team_b = [@leader_b]
    end

    if party_duel
      @duel_end_time = Time.ms + (PARTY_DUEL_DURATION * 1000)
    else
      @duel_end_time = Time.ms + (PLAYER_DUEL_DURATION * 1000)
    end

    save_player_conditions

    if party_duel
      @countdown = PARTY_DUEL_PREPARE_TIME
      teleport_players
    else
      @countdown = DUEL_PREPARE_TIME
    end

    task = DuelPreparationTask.new(self)
    ThreadPoolManager.schedule_general(task, @countdown - 3)
  end

  def start_duel
    debug "start_duel"
    broadcast_to_team_1(ExDuelReady::PARTY_DUEL)
    broadcast_to_team_2(ExDuelReady::PARTY_DUEL)
    broadcast_to_team_1(ExDuelStart::PARTY_DUEL)
    broadcast_to_team_2(ExDuelStart::PARTY_DUEL)

    @team_a.each do |pc|
      pc.cancel_active_trade
      pc.in_duel = @duel_id
      pc.team = Team::BLUE
      pc.broadcast_user_info
      broadcast_to_team_2(ExDuelUpdateUserInfo.new(pc))
    end

    @team_b.each do |pc|
      pc.cancel_active_trade
      pc.in_duel = @duel_id
      pc.team = Team::RED
      pc.broadcast_user_info
      broadcast_to_team_1(ExDuelUpdateUserInfo.new(pc))
    end

    if @party_duel
      if inst = InstanceManager.get_instance(duel_instance_id)
        inst.doors.each do |door|
          if door.open?
            door.close_me
          end
        end
      else
        warn { "Instance with id #{duel_instance_id} not found." }
      end
    end

    packet = Music::B04_S01.packet
    broadcast_to_team_1(packet)
    broadcast_to_team_2(packet)

    ThreadPoolManager.schedule_general(DuelClockTask.new(self), 1000)
  end

  def stop_fighting
    debug "stop_fighting"
    @team_a.each do |pc|
      pc.abort_cast
      pc.intention = AI::ACTIVE
      pc.target = nil
      pc.action_failed
    end

    @team_b.each do |pc|
      pc.abort_cast
      pc.intention = AI::ACTIVE
      pc.target = nil
      pc.action_failed
    end
  end

  def save_player_conditions
    debug "save_player_conditions"
    @team_a.each do |pc|
      @player_conditions[pc.l2id] = PlayerCondition.new(pc, @party_duel)
    end

    @team_b.each do |pc|
      @player_conditions[pc.l2id] = PlayerCondition.new(pc, @party_duel)
    end
  end

  def restore_player_conditions
    delay = @party_duel ? PARTY_DUEL_TELEPORT_BACK_TIME : 1000
    task = -> { @player_conditions.each_value &.restore_condition }
    ThreadPoolManager.schedule_general(task, delay)
    ThreadPoolManager.schedule_general(->clear, delay)
  end

  def restore_player_conditions
    delay = @party_duel ? PARTY_DUEL_TELEPORT_BACK_TIME : 1000
    task = -> do
      @player_conditions.each_value &.restore_condition
      clear
    end
    ThreadPoolManager.schedule_general(task, delay)
  end

  def id : Int32
    @duel_id
  end

  def team_leader_a : L2PcInstance
    @leader_a
  end

  def team_leader_b : L2PcInstance
    @leader_b
  end

  def remaining_time : Int64
    @duel_end_time - Time.ms
  end

  def losers : Array(L2PcInstance)?
    if @leader_a.duel_state.winner?
      @team_b
    elsif @leader_b.duel_state.winner?
      @team_a
    end
  end

  def teleport_players
    return unless @party_duel

    @duel_instance_id = InstanceManager.create_dynamic_instance("PartyDuel.xml")

    instance = InstanceManager.get_instance(@duel_instance_id).not_nil!

    @team_a.each_with_index do |pc, i|
      loc = instance.enter_locations[i]
      pc.tele_to_location(*loc.xyz, 0, @duel_instance_id, 0)
    end

    @team_b.each_with_index do |pc, i|
      loc = instance.enter_locations[i + 9]
      pc.tele_to_location(*loc.xyz, 0, @duel_instance_id, 0)
    end
  end

  def broadcast_to_team_1(msg : GameServerPacket | SystemMessageId)
    @team_a.each &.send_packet(msg)
  end

  def broadcast_to_team_2(msg : GameServerPacket | SystemMessageId)
    @team_b.each &.send_packet(msg)
  end

  private def play_kneel_animation
    debug "play_kneel_animation"
    losers.try &.each do |pc|
      pc.broadcast_packet(SocialAction.new(pc.l2id, 7))
    end
  end

  def countdown : Int32
    debug "#countdown: #{@countdown}"
    if (@countdown -= 1) > 3
      return @countdown
    end

    if @countdown > 0
      sm = SystemMessage.the_duel_will_begin_in_s1_seconds
      sm.add_int(@countdown)
    else
      sm = SystemMessageId::LET_THE_DUEL_BEGIN
    end

    broadcast_to_team_1(sm)
    broadcast_to_team_2(sm)

    @countdown
  end

  def end_duel
    debug "end_duel"
    ede = @party_duel ? ExDuelEnd::PARTY_DUEL : ExDuelEnd::PLAYER_DUEL
    broadcast_to_team_1(ede)
    broadcast_to_team_2(ede)
    play_kneel_animation
    send_end_messages
    restore_player_conditions
  end

  private def clear
    debug "clear"
    InstanceManager.destroy_instance(duel_instance_id)
    DuelManager.remove_duel(self)
  end

  private def send_end_messages
    result = check_end_duel_condition
    debug "#send_end_messages: #{result}."
    case result
    when DuelResult::TEAM_1_WIN, DuelResult::TEAM_2_SURRENDER
      if @party_duel
        sm = SystemMessage.c1_party_has_won_the_duel
      else
        sm = SystemMessage.c1_has_won_the_duel
      end

      sm.add_string(@leader_a.name)
    when DuelResult::TEAM_1_SURRENDER, DuelResult::TEAM_2_WIN
      if @party_duel
        sm = SystemMessage.c1_party_has_won_the_duel
      else
        sm = SystemMessage.c1_has_won_the_duel
      end

      sm.add_string(@leader_b.name)
    when DuelResult::CANCELED, DuelResult::TIMEOUT
      sm = SystemMessageId::THE_DUEL_HAS_ENDED_IN_A_TIE
    end

    if sm
      broadcast_to_team_1(sm)
      broadcast_to_team_2(sm)
    end
  end

  def check_end_duel_condition : DuelResult
    debug "check_end_duel_condition"

    if @surrender_request != 0
      if @surrender_request == 1
        return DuelResult::TEAM_1_SURRENDER
      end

      return DuelResult::TEAM_2_SURRENDER
    elsif remaining_time <= 0
      return DuelResult::TIMEOUT
    elsif @leader_a.duel_state.winner?
      stop_fighting
      return DuelResult::TEAM_1_WIN
    elsif @leader_b.duel_state.winner?
      stop_fighting
      return DuelResult::TEAM_2_WIN
    elsif !@party_duel
      if @leader_a.duel_state.interrupted? || @leader_b.duel_state.interrupted?
        return DuelResult::CANCELED
      end

      unless @leader_a.inside_radius?(@leader_b, 2000, false, false)
        return DuelResult::CANCELED
      end

      if @leader_a.inside_peace_zone? || @leader_b.inside_peace_zone? || @leader_a.inside_siege_zone? || @leader_b.inside_siege_zone? || @leader_a.inside_pvp_zone? || @leader_b.inside_pvp_zone?
        return DuelResult::CANCELED
      end
    end

    DuelResult::CONTINUE
  end

  def do_surrender(pc : L2PcInstance)
    debug "do_surrender"
    if @surrender_request != 0 || @party_duel
      return
    end

    stop_fighting

    if pc == @leader_a
      @surrender_request = 1
      @leader_a.duel_state = DuelState::DEAD
      @leader_b.duel_state = DuelState::WINNER
    elsif pc == @leader_b
      @surrender_request = 2
      @leader_b.duel_state = DuelState::DEAD
      @leader_a.duel_state = DuelState::WINNER
    end
  end

  def on_player_defeat(pc : L2PcInstance)
    debug "on_player_defeat"
    pc.duel_state = DuelState::DEAD
    pc.team = Team::NONE

    if @party_duel
      team_defeated = true
      is_in_team_a = true
      if @team_a.includes?(pc)
        team_defeated = @team_a.none? &.duel_state.duelling?
      elsif @team_b.includes?(pc)
        is_in_team_a = false
        team_defeated = @team_b.none? &.duel_state.duelling?
      end

      if team_defeated
        winners = is_in_team_a ? @team_b : @team_a
        winners.each &.duel_state = DuelState::WINNER
      end
    else
      if pc != @leader_a && pc != @leader_b
        warn { "#{pc} is not part of this 1 vs 1 duel." }
      end

      if @leader_a == pc
        @leader_b.duel_state = DuelState::WINNER
      else
        @leader_a.duel_state = DuelState::WINNER
      end
    end
  end

  # Perhaps make it restore a summon's HP/MP as well?
  private struct PlayerCondition
    @hp : Float64
    @mp : Float64
    @cp : Float64
    @player_effects : Enumerable(BuffInfo)
    @pet_effects : Enumerable(BuffInfo)?
    @summon : L2Summon?
    @loc : Location?

    getter player

    def initialize(@player : L2PcInstance, @party_duel : Bool)
      @hp, @mp, @cp = player.current_hp, player.current_mp, player.current_cp
      @player_effects = player.effect_list.effects

      if party_duel
        @loc = player.location
      end

      if smn = player.summon
        @summon = smn
        @pet_effects = smn.effect_list.effects
      end
    end

    def restore_condition
      @player.in_duel = 0
      @player.team = Team::NONE
      @player.broadcast_user_info
      if @party_duel
        teleport_back
      end
      @player.effect_list.stop_all_effects
      @player_effects.try &.each do |info|
        if info.time > 0
          info.skill.apply_effects(@player, @player, true, info.time)
        end
      end

      if player_summon = @player.summon
        player_summon.effect_list.stop_all_effects
        if (summon = @summon) && summon == player_summon
          @pet_effects.try &.each do |info|
            if info.time > 0
              info.skill.apply_effects(summon, summon, true, info.time)
            end
          end
        end
      end

      @player.current_hp = @hp
      @player.current_mp = @mp
      @player.current_cp = @cp
    end

    def teleport_back
      if loc = @loc
        @player.tele_to_location(loc)
      end
    end
  end

  private struct DuelPreparationTask
    include Loggable

    initializer duel : Duel

    def call
      if @duel.countdown > 0
        ThreadPoolManager.schedule_general(self, 1000)
      else
        @duel.start_duel
      end
    rescue e
      error e
    end
  end

  private struct DuelClockTask
    include Loggable

    initializer duel : Duel

    def call
      case @duel.check_end_duel_condition
      when DuelResult::CONTINUE
        ThreadPoolManager.schedule_general(self, 1000)
      else
        @duel.end_duel
      end
    rescue e
      error e
    end
  end
end
