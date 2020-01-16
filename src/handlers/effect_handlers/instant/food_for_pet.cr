class EffectHandler::FoodForPet < AbstractEffect
  @normal : Int32
  @ride : Int32
  @wyvern : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @normal = params.get_i32("normal", 0)
    @ride = params.get_i32("ride", 0)
    @wyvern = params.get_i32("wyvern", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    char = info.effector

    if char.is_a?(L2PetInstance)
      char.current_feed += @normal * Config.pet_food_rate
    elsif char.is_a?(L2PcInstance)
      if char.mount_type.wyvern?
        char.current_feed += @wyvern
      else
        char.current_feed += @ride
      end
    end
  end
end
