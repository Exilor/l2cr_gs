struct RentPetTask
  initializer pc : L2PcInstance

  def call
    @pc.stop_rent_pet
  end
end
