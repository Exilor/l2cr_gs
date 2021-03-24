module UserCommandHandler::Mount
  extend self
  extend UserCommandHandler

  def use_user_command(id : Int32, pc : L2PcInstance) : Bool
    return false unless id == commands[0]
    pc.mount_player(pc.summon)
  end

  def commands : Enumerable(Int32)
    {61}
  end
end
