module UserCommandHandler::Mount
  extend self
  extend UserCommandHandler

  def use_user_command(id, pc)
    return false unless id == commands[0]
    pc.mount_player(pc.summon)
  end

  def commands
    {61}
  end
end
