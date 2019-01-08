module UserCommandHandler::Dismount
  extend self
  extend UserCommandHandler

  def use_user_command(id, pc)
    return false unless id == commands[0]

    if pc.rented_pet?
      pc.stop_rent_pet
    elsif pc.mounted?
      pc.dismount
    end

    true
  end

  def commands
    {64}
  end
end
