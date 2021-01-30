require "./competition_type"

class OlympiadAnnouncer
  private alias NpcSay = Packets::Outgoing::NpcSay

  private OLY_MANAGER = 31688

  @current_stadium = 0
  @managers : Interfaces::Set(L2Spawn)

  def initialize
    @managers = SpawnTable.get_spawns(OLY_MANAGER)
  end

  def call
    OlympiadGameManager.number_of_stadiums.downto(0) do
      if @current_stadium > OlympiadGameManager.number_of_stadiums
        @current_stadium = 0
      end

      task = OlympiadGameManager.get_olympiad_task(@current_stadium)
      if task && task.game? && task.needs_announce?
        arena_id = (task.game.stadium_id + 1).to_s
        case task.game.type
        when CompetitionType::NON_CLASSED
          npc_str = NpcString::OLYMPIAD_CLASS_FREE_INDIVIDUAL_MATCH_IS_GOING_TO_BEGIN_IN_ARENA_S1_IN_A_MOMENT
        when CompetitionType::CLASSED
          npc_str = NpcString::OLYMPIAD_CLASS_INDIVIDUAL_MATCH_IS_GOING_TO_BEGIN_IN_ARENA_S1_IN_A_MOMENT
        when CompetitionType::TEAMS
          npc_str = NpcString::OLYMPIAD_CLASS_FREE_TEAM_MATCH_IS_GOING_TO_BEGIN_IN_ARENA_S1_IN_A_MOMENT
        else
          next
        end

        @managers.each do |sp|
          if manager = sp.last_spawn
            shout = Packets::Incoming::Say2::NPC_SHOUT
            say = NpcSay.new(manager.l2id, shout, manager.id, npc_str)
            say.add_string_parameter(arena_id)
            manager.broadcast_packet(say)
          end
        end

        break
      end

      @current_stadium += 1
    end
  end
end
