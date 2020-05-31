class BoatRunePrimeval
  include BoatEngine

  private RUNE_TO_PRIMEVAL = [
    VehiclePathPoint.new(32750, -39300, -3610, 180, 800),
    VehiclePathPoint.new(27440, -39328, -3610, 250, 1000),
    VehiclePathPoint.new(19616, -39360, -3610, 270, 1000),
    VehiclePathPoint.new(3840, -38528, -3610, 270, 1000),
    VehiclePathPoint.new(1664, -37120, -3610, 270, 1000),
    VehiclePathPoint.new(896, -34560, -3610, 180, 1800),
    VehiclePathPoint.new(832, -31104, -3610, 180, 180),
    VehiclePathPoint.new(2240, -29132, -3610, 150, 1800),
    VehiclePathPoint.new(4160, -27828, -3610, 150, 1800),
    VehiclePathPoint.new(5888, -27279, -3610, 150, 1800),
    VehiclePathPoint.new(7000, -27279, -3610, 150, 1800),
    VehiclePathPoint.new(10342, -27279, -3610, 150, 1800)
  ]

  private PRIMEVAL_TO_RUNE = [
    VehiclePathPoint.new(15528, -27279, -3610, 180, 800),
    VehiclePathPoint.new(22304, -29664, -3610, 290, 800),
    VehiclePathPoint.new(33824, -26880, -3610, 290, 800),
    VehiclePathPoint.new(38848, -21792, -3610, 240, 1200),
    VehiclePathPoint.new(43424, -22080, -3610, 180, 1800),
    VehiclePathPoint.new(44320, -25152, -3610, 180, 1800),
    VehiclePathPoint.new(40576, -31616, -3610, 250, 800),
    VehiclePathPoint.new(36819, -35315, -3610, 220, 800)
  ]

  private RUNE_DOCK = [VehiclePathPoint.new(34381, -37680, -3610, 220, 800)]

  private PRIMEVAL_DOCK = RUNE_TO_PRIMEVAL[-1]

  private ARRIVED_AT_RUNE       = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::ARRIVED_AT_RUNE)
  private ARRIVED_AT_RUNE_2     = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVING_FOR_PRIMEVAL_3_MINUTES)
  private LEAVING_RUNE          = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVING_RUNE_FOR_PRIMEVAL_NOW)
  private ARRIVED_AT_PRIMEVAL   = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_ARRIVED_AT_PRIMEVAL)
  private ARRIVED_AT_PRIMEVAL_2 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVING_FOR_RUNE_3_MINUTES)
  private LEAVING_PRIMEVAL      = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVING_PRIMEVAL_FOR_RUNE_NOW)
  private BUSY_RUNE             = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_PRIMEVAL_TO_RUNE_DELAYED)

  def call
    case @cycle
    when 0
      BoatManager.dock_ship(BoatManager::RUNE_HARBOR, false)
      BoatManager.broadcast_packets(RUNE_DOCK[0], PRIMEVAL_DOCK, LEAVING_RUNE, Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      @boat.pay_for_ride(8925, 1, 34513, -38009, -3640)
      @boat.execute_path(RUNE_TO_PRIMEVAL)
    when 1
      BoatManager.broadcast_packets(PRIMEVAL_DOCK, RUNE_DOCK[0], ARRIVED_AT_PRIMEVAL, ARRIVED_AT_PRIMEVAL_2, Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      ThreadPoolManager.schedule_general(self, 180_000)
    when 2
      BoatManager.broadcast_packets(PRIMEVAL_DOCK, RUNE_DOCK[0], LEAVING_PRIMEVAL, Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      @boat.pay_for_ride(8924, 1, 10447, -24982, -3664)
      @boat.execute_path(PRIMEVAL_TO_RUNE)
    when 3
      if BoatManager.dock_busy?(BoatManager::RUNE_HARBOR)
        if @shout_count == 0
          BoatManager.broadcast_packets(RUNE_DOCK[0], PRIMEVAL_DOCK, BUSY_RUNE)
        end

        @shout_count &+= 1
        if @shout_count > 35
          @shout_count = 0
        end

        ThreadPoolManager.schedule_general(self, 5_000)
        return
      else
        @boat.execute_path(RUNE_DOCK)
      end
    when 4
      BoatManager.dock_ship(BoatManager::RUNE_HARBOR, true)
      BoatManager.broadcast_packets(RUNE_DOCK[0], PRIMEVAL_DOCK, ARRIVED_AT_RUNE, ARRIVED_AT_RUNE_2, Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      ThreadPoolManager.schedule_general(self, 180_000)
    else
      # [automatically added else]
    end

    @shout_count = 0
    @cycle &+= 1
    if @cycle > 4
      @cycle = 0
    end
  end
end
