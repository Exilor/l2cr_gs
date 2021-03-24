class Scripts::Q00454_CompletelyLost < Quest
  # NPCs
  private INJURED_SOLDIER = 32738
  private ERMIAN = 32736
  # Misc
  private MIN_LEVEL = 84
  private  MOVE_TO = Location.new(-180219, 186341, -10600)

  def initialize
    super(454, self.class.simple_name, "Completely Lost")

    add_start_npc(INJURED_SOLDIER)
    add_talk_id(INJURED_SOLDIER, ERMIAN)
    add_spawn_id(ERMIAN)
    add_move_finished_id(INJURED_SOLDIER)
    add_see_creature_id(INJURED_SOLDIER)
    add_event_received_id(INJURED_SOLDIER)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    case event
    when "QUEST_TIMER"
      npc.broadcast_event("SCE_IM_ERMIAN", 300, nil)
      start_quest_timer("QUEST_TIMER", 100, npc, nil)
    when "SAY_TIMER1"
      # TODO: npc.changeStatus(3)
      broadcast_npc_say(npc, NpcString::GASP)
    when "SAY_TIMER2"
      broadcast_npc_say(npc, NpcString::SOB_TO_SEE_ERMIAN_AGAIN_CAN_I_GO_TO_MY_FAMILY_NOW)
      start_quest_timer("EXPIRED_TIMER", 2000, npc, nil)
    when "CHECK_TIMER"
      if leader = npc.variables.get_object("leader", L2PcInstance?)
        dist = Util.calculate_distance(npc, leader, false, false)
        if dist > 1000
          if (dist > 5000 && dist < 6900) || (dist > 31000 && dist < 32000)
            npc.tele_to_location(leader)
          elsif npc.variables.get_i32("whisper", 0) == 0
            whisper(npc, leader, NpcString::WHERE_ARE_YOU_I_CANT_SEE_ANYTHING)
            npc.variables["whisper"] = 1
          elsif npc.variables.get_i32("whisper", 0) == 1
            whisper(npc, leader, NpcString::WHERE_ARE_YOU_REALLY_I_CANT_FOLLOW_YOU_LIKE_THIS)
            npc.variables["whisper"] = 2
          elsif npc.variables.get_i32("whisper", 0) == 2
            whisper(npc, leader, NpcString::IM_SORRY_THIS_IS_IT_FOR_ME)
            npc.send_script_event("SCE_A_SEED_ESCORT_QUEST_FAILURE", npc, nil)
          end
        end
      end
      start_quest_timer("CHECK_TIMER", 2000, npc, nil)
    when "TIME_LIMIT1"
      if leader = npc.variables.get_object("leader", L2PcInstance?)
        start_quest_timer("TIME_LIMIT2", 150_000, npc, nil)
        whisper(npc, leader, NpcString::IS_IT_STILL_LONG_OFF)
      end
    when "TIME_LIMIT2"
      if leader = npc.variables.get_object("leader", L2PcInstance?)
        start_quest_timer("TIME_LIMIT3", 150_000, npc, nil)
        whisper(npc, leader, NpcString::IS_ERMIAN_WELL_EVEN_I_CANT_BELIEVE_THAT_I_SURVIVED_IN_A_PLACE_LIKE_THIS)
      end
    when "TIME_LIMIT3"
      if leader = npc.variables.get_object("leader", L2PcInstance?)
        start_quest_timer("TIME_LIMIT4", 150_000, npc, nil)
        whisper(npc, leader, NpcString::I_DONT_KNOW_HOW_LONG_ITS_BEEN_SINCE_I_PARTED_COMPANY_WITH_YOU_TIME_DOESNT_SEEM_TO_MOVE_IT_JUST_FEELS_TOO_LONG)
      end
    when "TIME_LIMIT4"
      if leader = npc.variables.get_object("leader", L2PcInstance?)
        start_quest_timer("TIME_LIMIT5", 150_000, npc, nil)
        whisper(npc, leader, NpcString::SORRY_TO_SAY_THIS_BUT_THE_PLACE_YOU_STRUCK_ME_BEFORE_NOW_HURTS_GREATLY)
      end
    when "TIME_LIMIT5"
      if leader = npc.variables.get_object("leader", L2PcInstance?)
        whisper(npc, leader, NpcString::UGH_IM_SORRY_IT_LOOKS_LIKE_THIS_IS_IT_FOR_ME_I_WANTED_TO_LIVE_AND_SEE_MY_FAMILY)
      end
      npc.send_script_event("SCE_A_SEED_ESCORT_QUEST_FAILURE", npc, nil)
      start_quest_timer("EXPIRED_TIMER", 2000, npc, nil)
    when "EXPIRED_TIMER"
      npc.delete_me
    end

    # For NPC-only timers, player is nil and no further checks or actions are required.
    unless pc
      return
    end

    unless qs = get_quest_state(pc, false)
      return
    end

    html = nil
    case event
    when "32738-04.htm"
      if qs.created? && qs.now_available? && pc.level >= MIN_LEVEL
        if npc.variables.get_i32("quest_escort", 0) == 0
          npc.variables["leader"] = pc
          npc.variables["quest_escort"] = 1
          if party = pc.party
            npc.variables["partyId"] = party.leader_l2id
          end
          qs.memo_state = 1
          qs.start_quest
          html = event
        else
          leader = npc.variables.get_object("leader", L2PcInstance)
          if (party = leader.party) && party.includes?(pc)
            qs.start_quest
            qs.memo_state = 1
            html = get_htm(pc, "32738-04a.htm")
            html = html.gsub("leader", leader.name)
          else
            html = get_htm(pc, "32738-01b.htm")
            html = html.gsub("leader", leader.name)
          end
        end
      end
    when "agree1"
      if qs.memo_state?(1)
        leader = npc.variables.get_object("leader", L2PcInstance?)
        if leader && leader.in_party?
          qs.memo_state = 2
          npc.send_script_event("SCE_A_SEED_ESCORT_QUEST_START", npc, nil)
          html = "32738-06.html"
        else
          html = "32738-05a.html"
        end
      end
    when "agree2"
      if qs.memo_state?(1)
        qs.memo_state = 2
        html = "32738-06.html"
        npc.send_script_event("SCE_A_SEED_ESCORT_QUEST_START", npc, nil)
        leader = npc.variables.get_object("leader", L2PcInstance?)
        if leader
          if party = leader.party
            party.members.each do |m|
              qs_m = get_quest_state(m, false)
              if qs_m && qs_m.memo_state?(1)
                if npc.variables.get_i32("partyId", 0) == party.leader_l2id
                  qs_m.memo_state = 2
                end
              end
            end
          end
        end
      end
    when "32738-07.html"
      if qs.memo_state?(1)
        html = event
      end
    end

    html
  end

  @[Register(event: ON_CREATURE_ATTACKED, register: NPC, id: 32738)] # INJURED_SOLDIER
  def on_attacked(event : OnCreatureAttacked) : TerminateReturn
    npc = event.target.as(L2Npc)
    # TODO: npc.changeStatus(2)
    npc.variables["state"] = 1
    npc.intention = AI::IDLE
    npc.intention = AI::ACTIVE
    start_quest_timer("SAY_TIMER1", 2000, npc, nil)

    TerminateReturn.new(true, false, false)
  end

  def on_event_received(event_name, sender, receiver, reference)
    case event_name
    when "SCE_IM_ERMIAN"
      if receiver.variables.get_i32("state", 0) == 2
        receiver.variables["state"] = 3
        receiver.variables["ermian"] = sender
        receiver.intention = AI::IDLE
        add_move_to_desire(receiver, MOVE_TO, 10000000)
        receiver.send_script_event("SCE_A_SEED_ESCORT_QUEST_SUCCESS", receiver, nil)
      end
    when "SCE_A_SEED_ESCORT_QUEST_START"
      leader = receiver.variables.get_object("leader", L2PcInstance?)
      if leader
        receiver.set_intention(AI::FOLLOW, leader)
      end

      start_quest_timer("CHECK_TIMER", 1000, receiver, nil)
      start_quest_timer("TIME_LIMIT1", 60_000, receiver, nil)
      receiver.variables["state"] = 2
      receiver.variables["quest_escort"] = 99
    when "SCE_A_SEED_ESCORT_QUEST_SUCCESS"
      leader = receiver.variables.get_object("leader", L2PcInstance?)
      if leader
        if party = leader.party
          party.members.each do |m|
            qs = get_quest_state(m, false)
            if qs && qs.memo_state?(2)
              qs.memo_state = 4
            end
          end
        else
          qs = get_quest_state(leader, false)
          if qs && qs.memo_state?(2)
            qs.memo_state = 4
          end
        end
      end
      # Timers cleanup
      cancel_quest_timer("CHECK_TIMER", receiver, nil)
      cancel_quest_timer("TIME_LIMIT1", receiver, nil)
      cancel_quest_timer("TIME_LIMIT2", receiver, nil)
      cancel_quest_timer("TIME_LIMIT3", receiver, nil)
      cancel_quest_timer("TIME_LIMIT4", receiver, nil)
      cancel_quest_timer("TIME_LIMIT5", receiver, nil)
    when "SCE_A_SEED_ESCORT_QUEST_FAILURE"
      leader = receiver.variables.get_object("leader", L2PcInstance?)
      if leader
        if party = leader.party
          party.members.each do |m|
            qs = get_quest_state(m, false)
            if qs && qs.memo_state?(2)
              qs.memo_state = 3
            end
          end
        else
          qs = get_quest_state(leader, false)
          if qs && qs.memo_state?(2)
            qs.memo_state = 3
          end
        end
      end
      receiver.delete_me
      # Timers cleanup
      cancel_quest_timer("CHECK_TIMER", receiver, nil)
      cancel_quest_timer("TIME_LIMIT1", receiver, nil)
      cancel_quest_timer("TIME_LIMIT2", receiver, nil)
      cancel_quest_timer("TIME_LIMIT3", receiver, nil)
      cancel_quest_timer("TIME_LIMIT4", receiver, nil)
      cancel_quest_timer("TIME_LIMIT5", receiver, nil)
    end

    super
  end

  def on_move_finished(npc)
    if ermian = npc.variables.get_object("ermian", L2Npc?)
      npc.heading = Util.calculate_heading_from(npc, ermian)
      start_quest_timer("SAY_TIMER2", 2000, npc, nil)
    end
  end

  def on_see_creature(npc, creature, is_summon)
    if creature.is_a?(L2PcInstance) && npc.variables.get_i32("state", 0) == 0
      add_attack_desire(npc, creature, 10)
    end

    super
  end

  def on_spawn(npc)
    start_quest_timer("QUEST_TIMER", 1000, npc, nil)
    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case qs.state
    when State::COMPLETED
      unless qs.now_available?
        html = "32738-02.htm"
      end
      qs.state = State::CREATED
    when State::CREATED
      if pc.level >= MIN_LEVEL
        quest_escort = npc.variables.get_i32("quest_escort", 0)
        if quest_escort == 0
          html = "32738-01.htm"
        elsif quest_escort == 99
          html = "32738-01c.htm"
        else
          leader = npc.variables.get_object("leader", L2PcInstance)
          if (party = leader.party) && party.includes?(pc)
            html = get_htm(pc, "32738-01a.htm")
            html = html.gsub("leader", leader.name)
            html = html.gsub("name", pc.name)
          else
            html = get_htm(pc, "32738-01b.htm")
            html = html.gsub("leader", leader.name)
          end
        end
      else
        html = "32738-03.htm"
      end
    when State::STARTED
      case npc.id
      when INJURED_SOLDIER
        if qs.memo_state?(1)
          html = "32738-05.html"
        elsif qs.memo_state?(2)
          html = "32738-08.html"
        end
      when ERMIAN
        case qs.memo_state
        when 1, 2
          html = "32736-01.html"
        when 3
          qs.exit_quest(QuestType::DAILY, true)
          html = "32736-02.html"
        when 4
          group = Rnd.rand(3)
          chance = Rnd.rand(100)
          if group == 0
            if Rnd.bool
              if chance < 11
                give_items(pc, 15792, 1) # Recipe - Sealed Vesper Helmet (60%)
              elsif chance <= 11 && chance < 22
                give_items(pc, 15798, 1) # Recipe - Sealed Vesper Gaiter (60%)
              elsif chance <= 22 && chance < 33
                give_items(pc, 15795, 1) # Recipe - Sealed Vesper Breastplate (60%)
              elsif chance <= 33 && chance < 44
                give_items(pc, 15801, 1) # Recipe - Sealed Vesper Gauntlet (60%)
              elsif chance <= 44 && chance < 55
                give_items(pc, 15808, 1) # Recipe - Sealed Vesper Shield (60%)
              elsif chance <= 55 && chance < 66
                give_items(pc, 15804, 1) # Recipe - Sealed Vesper Boots (60%)
              elsif chance <= 66 && chance < 77
                give_items(pc, 15809, 1) # Recipe - Sealed Vesper Ring (70%)
              elsif chance <= 77 && chance < 88
                give_items(pc, 15810, 1) # Recipe - Sealed Vesper Earring (70%)
              else
                give_items(pc, 15811, 1) # Recipe - Sealed Vesper Necklace (70%)
              end
            else
              if chance < 11
                give_items(pc, 15660, 3) # Sealed Vesper Helmet Piece
              elsif chance <= 11 && chance < 22
                give_items(pc, 15666, 3) # Sealed Vesper Gaiter Piece
              elsif chance <= 22 && chance < 33
                give_items(pc, 15663, 3) # Sealed Vesper Breastplate Piece
              elsif chance <= 33 && chance < 44
                give_items(pc, 15667, 3) # Sealed Vesper Gauntlet Piece
              elsif chance <= 44 && chance < 55
                give_items(pc, 15669, 3) # Sealed Vesper Verteidiger Piece
              elsif chance <= 55 && chance < 66
                give_items(pc, 15668, 3) # Sealed Vesper Boots Piece
              elsif chance <= 66 && chance < 77
                give_items(pc, 15769, 3) # Sealed Vesper Ring Gem
              elsif chance <= 77 && chance < 88
                give_items(pc, 15770, 3) # Sealed Vesper Earring Gem
              else
                give_items(pc, 15771, 3) # Sealed Vesper Necklace Gem
              end
            end
          elsif group == 1
            if Rnd.bool
              if chance < 12
                give_items(pc, 15805, 1) # Recipe - Sealed Vesper Leather Boots (60%)
              elsif chance <= 12 && chance < 24
                give_items(pc, 15796, 1) # Recipe - Sealed Vesper Leather Breastplate (60%)
              elsif chance <= 24 && chance < 36
                give_items(pc, 15793, 1) # Recipe - Sealed Vesper Leather Helmet (60%)
              elsif chance <= 36 && chance < 48
                give_items(pc, 15799, 1) # Recipe - Sealed Vesper Leather Legging (60%)
              elsif chance <= 48 && chance < 60
                give_items(pc, 15802, 1) # Recipe - Sealed Vesper Leather Gloves (60%)
              elsif chance <= 60 && chance < 72
                give_items(pc, 15809, 1) # Recipe - Sealed Vesper Ring (70%)
              elsif chance <= 72 && chance < 84
                give_items(pc, 15810, 1) # Recipe - Sealed Vesper Earring (70%)
              else
                give_items(pc, 15811, 1) # Recipe - Sealed Vesper Necklace (70%)
              end
            else
              if chance < 12
                give_items(pc, 15672, 3) # Sealed Vesper Leather Boots Piece
              elsif chance <= 12 && chance < 24
                give_items(pc, 15664, 3) # Sealed Vesper Leather Breastplate Piece
              elsif chance <= 24 && chance < 36
                give_items(pc, 15661, 3) # Sealed Vesper Leather Helmet Piece
              elsif chance <= 36 && chance < 48
                give_items(pc, 15670, 3) # Sealed Vesper Leather Legging Piece
              elsif chance <= 48 && chance < 60
                give_items(pc, 15671, 3) # Sealed Vesper Leather Gloves Piece
              elsif chance <= 60 && chance < 72
                give_items(pc, 15769, 3) # Sealed Vesper Ring Gem
              elsif chance <= 72 && chance < 84
                give_items(pc, 15770, 3) # Sealed Vesper Earring Gem
              else
                give_items(pc, 15771, 3) # Sealed Vesper Necklace Gem
              end
            end
          elsif Rnd.bool
            if chance < 11
              give_items(pc, 15800, 1)
            elsif chance <= 11 && chance < 22 # Recipe - Sealed Vesper Stockings (60%)
              give_items(pc, 15803, 1) # Recipe - Sealed Vesper Gloves (60%)
            elsif chance <= 22 && chance < 33
              give_items(pc, 15806, 1) # Recipe - Sealed Vesper Shoes (60%)
            elsif chance <= 33 && chance < 44
              give_items(pc, 15807, 1) # Recipe - Sealed Vesper Sigil (60%)
            elsif chance <= 44 && chance < 55
              give_items(pc, 15797, 1) # Recipe - Sealed Vesper Tunic (60%)
            elsif chance <= 55 && chance < 66
              give_items(pc, 15794, 1) # Recipe - Sealed Vesper Circlet (60%)
            elsif chance <= 66 && chance < 77
              give_items(pc, 15809, 1) # Recipe - Sealed Vesper Ring (70%)
            elsif chance <= 77 && chance < 88
              give_items(pc, 15810, 1) # Recipe - Sealed Vesper Earring (70%)
            else
              give_items(pc, 15811, 1) # Recipe - Sealed Vesper Necklace (70%)
            end
          else
            if chance < 11
              give_items(pc, 15673, 3) # Sealed Vesper Stockings Piece
            elsif chance <= 11 && chance < 22
              give_items(pc, 15674, 3) # Sealed Vesper Gloves Piece
            elsif chance <= 22 && chance < 33
              give_items(pc, 15675, 3) # Sealed Vesper Shoes Piece
            elsif chance <= 33 && chance < 44
              give_items(pc, 15691, 3) # Sealed Vesper Sigil Piece
            elsif chance <= 44 && chance < 55
              give_items(pc, 15665, 3) # Sealed Vesper Tunic Piece
            elsif chance <= 55 && chance < 66
              give_items(pc, 15662, 3) # Sealed Vesper Circlet Piece
            elsif chance <= 66 && chance < 77
              give_items(pc, 15769, 3) # Sealed Vesper Ring Gem
            elsif chance <= 77 && chance < 88
              give_items(pc, 15770, 3) # Sealed Vesper Earring Gem
            else
              give_items(pc, 15771, 3) # Sealed Vesper Necklace Gem
            end
          end

          qs.exit_quest(QuestType::DAILY, true)
          html = "32736-03.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def broadcast_npc_say(npc, str_id)
    Broadcast.to_known_players(npc, NpcSay.new(npc, Say2::NPC_ALL, str_id))
  end

  private def whisper(npc, pc, str_id)
    pc.send_packet(NpcSay.new(npc.l2id, Say2::TELL, npc.id, str_id))
  end
end
