module NpcPersonalAIData
  extend self

  private AI_DATA = {} of String => Hash(String, Int32)

  def store_data(spawn_dat : L2Spawn, data : Hash(String, Int32)?)
    if data && !data.empty?
      name = spawn_dat.name ||= spawn_dat.object_id.to_s
      AI_DATA[name] = data
    end
  end

  def get_ai_value(spawn_name : String, param_name : String?) : Int32
    AI_DATA.dig?(spawn_name, param_name) || -1
  end

  def has_ai_value?(spawn_name : String, param_name : String?) : Bool
    !!AI_DATA.dig?(spawn_name, param_name)
  end

  def initialize_npc_parameters(npc : L2Npc, sp : L2Spawn, spawn_name : String?)
    return unless map = AI_DATA[spawn_name]?
    map.each do |key, val|
      if key == "disableRandomAnimation"
        npc.random_animation_enabled = val == 0
      elsif key == "disableRandomWalk"
        npc.no_random_walk = val == 1
        sp.no_random_walk = val == 1
      end
    end
  end
end
