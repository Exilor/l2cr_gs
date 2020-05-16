abstract class AbstractOlympiadGame
  include Loggable
  include Packets::Outgoing

  private POINTS = "olympiad_points"
  private COMP_DONE = "competitions_done"
  private COMP_WON = "competitions_won"
  private COMP_LOST = "competitions_lost"
  private COMP_DRAWN = "competitions_drawn"
  private COMP_DONE_WEEK = "competitions_done_week"
  private COMP_DONE_WEEK_CLASSED = "competitions_done_week_classed"
  private COMP_DONE_WEEK_NON_CLASSED = "competitions_done_week_non_classed"
  private COMP_DONE_WEEK_TEAM = "competitions_done_week_team"

  @start_time = 0i64

  getter? aborted = false

  getter_initializer stadium_id : Int32

  def make_competition_start : Bool
    @start_time = Time.ms
    !@aborted
  end

  def add_points_to_participant(par : Participant, points : Int32)
    par.update_stat(POINTS, points)
    sm = SystemMessage.c1_has_gained_s2_olympiad_points
    sm.add_string(par.name)
    sm.add_int(points)
    broadcast_packet(sm)
  end

  def remove_points_from_participant(par : Participant, points : Int32)
    par.update_stat(POINTS, -points)
    sm = SystemMessage.c1_has_lost_s2_olympiad_points
    sm.add_string(par.name)
    sm.add_int(points)
    broadcast_packet(sm)
  end

  def check_defaulted(pc : L2PcInstance?) : SystemMessageId?
    if pc.nil? || !pc.online?
      return SystemMessageId::THE_GAME_HAS_BEEN_CANCELLED_BECAUSE_THE_OTHER_PARTY_ENDS_THE_GAME
    end
    client = pc.client
    if client.nil? || client.detached?
      return SystemMessageId::THE_GAME_HAS_BEEN_CANCELLED_BECAUSE_THE_OTHER_PARTY_ENDS_THE_GAME
    end

    # safety precautions
    if pc.in_observer_mode? || TvTEvent.participant?(pc.l2id)
      return SystemMessageId::THE_GAME_HAS_BEEN_CANCELLED_BECAUSE_THE_OTHER_PARTY_DOES_NOT_MEET_THE_REQUIREMENTS_FOR_JOINING_THE_GAME
    end

    if pc.dead?
      sm = SystemMessage.c1_cannot_participate_olympiad_while_dead
      sm.add_pc_name(pc)
      pc.send_packet(sm)
      return SystemMessageId::THE_GAME_HAS_BEEN_CANCELLED_BECAUSE_THE_OTHER_PARTY_DOES_NOT_MEET_THE_REQUIREMENTS_FOR_JOINING_THE_GAME
    end
    if pc.subclass_active?
      sm = SystemMessage.c1_cannot_participate_in_olympiad_while_changed_to_sub_class
      sm.add_pc_name(pc)
      pc.send_packet(sm)
      return SystemMessageId::THE_GAME_HAS_BEEN_CANCELLED_BECAUSE_THE_OTHER_PARTY_DOES_NOT_MEET_THE_REQUIREMENTS_FOR_JOINING_THE_GAME
    end
    if pc.cursed_weapon_equipped?
      sm = SystemMessage.c1_cannot_join_olympiad_possessing_s2
      sm.add_pc_name(pc)
      sm.add_item_name(pc.cursed_weapon_equipped_id)
      pc.send_packet(sm)
      return SystemMessageId::THE_GAME_HAS_BEEN_CANCELLED_BECAUSE_THE_OTHER_PARTY_DOES_NOT_MEET_THE_REQUIREMENTS_FOR_JOINING_THE_GAME
    end
    unless pc.inventory_under_90?(true)
      sm = SystemMessage.c1_cannot_participate_in_olympiad_inventory_slot_exceeds_80_percent
      sm.add_pc_name(pc)
      pc.send_packet(sm)
      return SystemMessageId::THE_GAME_HAS_BEEN_CANCELLED_BECAUSE_THE_OTHER_PARTY_DOES_NOT_MEET_THE_REQUIREMENTS_FOR_JOINING_THE_GAME
    end

    nil
  end

  def port_player_to_arena(par : Participant, loc : Location, id : Int32) : Bool
    pc = par.player?
    if pc.nil? || !pc.online?
      return false
    end

    begin
      pc.set_last_location
      if pc.sitting?
        pc.stand_up
      end
      pc.target = nil

      pc.olympiad_game_id = id
      pc.in_olympiad_mode = true
      pc.olympiad_start = false
      pc.olympiad_side = par.side
      pc.olympiad_buff_count = Config.alt_oly_max_buffs
      loc.instance_id = OlympiadGameManager.get_olympiad_task(id).not_nil!.zone.instance_id
      pc.tele_to_location(loc, false)
      pc.send_packet(ExOlympiadMode.new(2))
    rescue e
      error e
      return false
    end

    true
  end

  def removals(pc : L2PcInstance?, remove_party : Bool)
    return unless pc
    pc.stop_all_effects_except_those_that_last_through_death

    if clan = pc.clan
      clan.remove_skill_effects(pc)
      if clan.castle_id > 0
        CastleManager.get_castle_by_owner(clan).not_nil!.remove_residential_skills(pc)
      end
      if clan.fort_id > 0
        FortManager.get_fort_by_owner(clan).not_nil!.remove_residential_skills(pc)
      end
    end

    pc.abort_attack
    pc.abort_cast

    pc.invisible = false

    pc.heal!

    if summon = pc.summon
      summon.stop_all_effects_except_those_that_last_through_death
      summon.abort_attack
      summon.abort_cast

      if summon.pet?
        summon.unsummon(pc)
      end
    end

    pc.stop_cubics_by_others

    if remove_party
      if party = pc.party
        party.remove_party_member(pc, L2Party::MessageType::Expelled)
      end
    end

    if pc.agathion_id > 0
      pc.agathion_id = 0
      pc.broadcast_user_info
    end

    pc.check_item_restriction

    pc.disable_all_shots

    if item = pc.active_weapon_instance
      item.uncharge_all_shots
    end

    pc.all_skills.each do |skill|
      if skill.reuse_delay <= 900000
        pc.enable_skill(skill)
      end
    end

    pc.send_skill_list
    pc.send_packet(SkillCoolTime.new(pc))
  rescue e
    error e
  end

  def clean_effects(pc : L2PcInstance)
    pc.olympiad_start = false
    pc.target = nil
    pc.abort_attack
    pc.abort_cast
    pc.intention = AI::IDLE

    if pc.dead?
      pc.dead = false
    end

    pc.stop_all_effects_except_those_that_last_through_death
    pc.clear_souls
    pc.clear_charges
    if pc.agathion_id > 0
      pc.agathion_id = 0
    end
    summon = pc.summon
    if summon && summon.alive?
      summon.target = nil
      summon.abort_attack
      summon.abort_cast
      summon.intention = AI::IDLE
      summon.stop_all_effects_except_those_that_last_through_death
    end

    pc.heal!
    pc.status.start_hp_mp_regeneration
  rescue e
    error e
  end

  def player_status_back(pc : L2PcInstance)
    if pc.transformed?
      pc.untransform
    end

    if pc.in_olympiad_mode?
      pc.send_packet(ExOlympiadMode.new(0))
    end

    pc.in_olympiad_mode = false
    pc.olympiad_start = false
    pc.olympiad_side = -1
    pc.olympiad_game_id = -1

    # Add Clan Skills
    if clan = pc.clan
      clan.add_skill_effects(pc)
      if clan.castle_id > 0
        CastleManager.get_castle_by_owner(clan).not_nil!.give_residential_skills(pc)
      end
      if clan.fort_id > 0
        FortManager.get_fort_by_owner(clan).not_nil!.give_residential_skills(pc)
      end
      pc.send_skill_list
    end

    # heal again after adding clan skills
    pc.heal!
    pc.status.start_hp_mp_regeneration

    if Config.dualbox_check_max_olympiad_participants_per_ip > 0
      AntiFeedManager.remove_player(AntiFeedManager::OLYMPIAD_ID, pc)
    end
  rescue e
    error e
  end

  def port_player_back(pc : L2PcInstance)
    loc = pc.last_location
    if loc.x == 0 && loc.y == 0
      return
    end
    pc.pending_revive = false
    pc.instance_id = 0
    pc.tele_to_location(loc)
    pc.unset_last_location
  end

  def reward_participant(pc : L2PcInstance, reward : Slice(Slice(Int32)))
    if !pc.online? || reward.nil?
      return
    end

    begin
      iu = InventoryUpdate.new
      reward.each do |it|
        if it.size != 2 # will this ever happen?
          next
        end

        item = pc.inventory.add_item("Olympiad", it[0], it[1].to_i64, pc, nil)
        unless item
          next
        end

        iu.add_modified_item(item)
        sm = SystemMessage.earned_s2_s1_s
        sm.add_item_name(it[0])
        sm.add_int(it[1])
        pc.send_packet(sm)
      end
      pc.send_packet(iu)
    rescue e
      error e
    end
  end

  abstract def type : CompetitionType
  abstract def player_names : Indexable(String)
  abstract def contains_participant?(player_id : Int32) : Bool
  abstract def send_olympiad_info(char : L2Character)
  abstract def broadcast_olympiad_info(stadium : L2OlympiadStadiumZone)
  abstract def broadcast_packet(gsp : GameServerPacket)
  abstract def needs_buffers? : Bool
  abstract def check_defaulted : Bool
  abstract def removals
  abstract def port_players_to_arena(spawns : Array(Location))
  abstract def clean_effects
  abstract def port_players_back
  abstract def players_status_back
  abstract def clear_players
  abstract def handle_disconnect(pc : L2PcInstance)
  abstract def reset_damage
  abstract def add_damage(pc : L2PcInstance, damage : Int32)
  abstract def check_battle_status : Bool
  abstract def has_winner? : Bool
  abstract def validate_winner(stadium : L2OlympiadStadiumZone)
  abstract def divider : Int32
  abstract def reward : Slice(Slice(Int32))
  abstract def weekly_match_type : String
end
