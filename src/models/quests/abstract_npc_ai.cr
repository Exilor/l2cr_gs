require "./quest"

abstract class AbstractNpcAI < Quest
  def initialize(name : String, descr : String)
    super(-1, name, descr)
  end

  def on_first_talk(npc, pc)
    "#{npc.id}.html"
  end

  def register_mobs(*mobs)
    add_attack_id(*mobs)
    add_kill_id(*mobs)
    add_spawn_id(*mobs)
    add_spell_finished_id(*mobs)
    add_skill_see_id(*mobs)
    add_aggro_range_enter_id(*mobs)
    add_faction_call_id(*mobs)
  end

  def broadcast_npc_say(npc : L2Npc, type : Int32, text : String)
    say = NpcSay.new(npc.l2id, type, npc.template.display_id, text)
    Broadcast.to_known_players(npc, say)
  end

  def broadcast_npc_say(npc : L2Npc, type : Int32, string_id : NpcString)
    say = NpcSay.new(npc.l2id, type, npc.template.display_id, string_id)
    Broadcast.to_known_players(npc, say)
  end

  def broadcast_npc_say(npc : L2Npc, type : Int32, string_id : NpcString, *parameters : String)
    broadcast_npc_say(npc, type, string_id, parameters)
  end

  def broadcast_npc_say(npc : L2Npc, type : Int32, string_id : NpcString, parameters : Enumerable(String))
    say = NpcSay.new(npc.l2id, type, npc.template.display_id, string_id)
    say.add_string_parameters(parameters)
    Broadcast.to_known_players(npc, say)
  end

  def broadcast_npc_say(npc : L2Npc, type : Int32, text : String, radius : Int)
    say = NpcSay.new(npc.l2id, type, npc.template.display_id, text)
    Broadcast.to_known_players_in_radius(npc, say, radius)
  end

  def broadcast_npc_say(npc : L2Npc, type : Int32, string_id : NpcString, radius : Int)
    say = NpcSay.new(npc.l2id, type, npc.template.display_id, string_id)
    Broadcast.to_known_players_in_radius(npc, say, radius)
  end

  def spawn_minions(npc : L2Npc, spawn_name : String)
    npc.template.parameters.get_minion_list(spawn_name).each do |is|
      add_minion(npc.as(L2MonsterInstance), is.id)
    end
  end
end
