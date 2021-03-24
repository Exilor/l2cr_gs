module UserCommandHandler::Dismount
  extend self
  extend UserCommandHandler

  def use_user_command(id : Int32, pc : L2PcInstance) : Bool
    return false unless id == commands[0]

    if pc.rented_pet?
      pc.stop_rent_pet
    elsif pc.mounted?
      pc.dismount
    end

    true
  end

  def commands : Enumerable(Int32)
    {62}
  end
end
