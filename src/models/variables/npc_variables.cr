require "./abstract_variables"

class NpcVariables < AbstractVariables
  def restore_me : Bool
    true
  end

  def store_me : Bool
    true
  end

  def get_player(name : String) : L2PcInstance?
    get_object(name, L2PcInstance?)
  end

  def get_summon(name : String) : L2Summon?
    get_object(name, L2Summon?)
  end

  def get_i32(key : String) : Int32
    super(key, 0)
  end
end
