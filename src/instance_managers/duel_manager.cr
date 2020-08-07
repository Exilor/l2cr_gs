require "../models/entity/duel"

module DuelManager
  extend self
  extend Loggable
  include Packets::Outgoing

  private DUELS = Concurrent::Map(Int32, Duel).new
  @@current_duel_id = Atomic(Int32).new(0)

  def get_duel(duel_id : Int) : Duel?
    if duel = DUELS[duel_id]?
      return duel
    end

    nil
  end

  def add_duel(pc1 : L2PcInstance, pc2 : L2PcInstance, party_duel : Bool)
    duel_id = @@current_duel_id.add(1) &+ 1
    debug { "Created new duel with id #{duel_id}." }
    DUELS[duel_id] = Duel.new(pc1, pc2, party_duel, duel_id)
  end

  def remove_duel(duel : Duel)
    DUELS.delete(duel.id)
  end

  def do_surrender(pc : L2PcInstance)
    return unless pc.in_duel?
    unless duel = get_duel(pc.duel_id)
      return
    end
    duel.do_surrender(pc)
  end

  def on_player_defeat(pc : L2PcInstance)
    return unless pc.in_duel?
    if duel = get_duel(pc.duel_id)
      duel.on_player_defeat(pc)
    end
  end

  def broadcast_to_opposite_team(pc : L2PcInstance, packet : GameServerPacket)
    return unless pc.in_duel?
    return unless duel = get_duel(pc.duel_id)

    if duel.team_a.includes?(pc)
      duel.broadcast_to_team_2(packet)
    else
      duel.broadcast_to_team_1(packet)
    end
  end

  def can_duel?(pc : L2PcInstance, target : L2PcInstance, party_duel : Bool) : Bool
    reason =
    case
    when target.in_combat? || target.jailed?
      SystemMessage.c1_cannot_duel_because_c1_is_currently_engaged_in_battle
    when target.transformed?
      SystemMessage.c1_cannot_duel_while_polymorphed
    when target.dead? || target.current_hp < target.max_hp // 2
      SystemMessage.c1_cannot_duel_because_c1_hp_or_mp_is_below_50_percent
    when target.in_duel?
      SystemMessage.c1_cannot_duel_because_c1_is_already_engaged_in_a_duel
    when target.in_olympiad_mode?
      SystemMessage.c1_cannot_duel_because_c1_is_participating_in_the_olympiad
    when target.cursed_weapon_equipped? || target.karma > 0 || target.pvp_flag > 0
      SystemMessage.c1_cannot_duel_because_c1_is_in_a_chaotic_state
    when !target.private_store_type.none?
      SystemMessage.c1_cannot_duel_because_c1_is_currently_engaged_in_a_private_store_or_manufacture
    when target.mounted? || target.in_boat?
      SystemMessage.c1_cannot_duel_because_c1_is_currently_riding_a_boat_steed_or_strider
    when target.fishing?
      SystemMessage.c1_cannot_duel_because_c1_is_currently_fishing
    when !party_duel && (target.inside_peace_zone? || target.inside_water_zone?)
      SystemMessage.c1_cannot_make_a_challange_to_a_duel_because_c1_is_currently_in_a_duel_prohibited_area
    end

    if reason
      reason.add_string(target.name)
      pc.send_packet(reason)
      return false
    end

    true
  end
end
