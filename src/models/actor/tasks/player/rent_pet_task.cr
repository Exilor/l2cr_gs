struct RentPetTask
  include Runnable

  initializer pc: L2PcInstance

  def run
    @pc.stop_rent_pet
  end
end
