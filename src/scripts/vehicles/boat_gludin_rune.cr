class BoatGludinRune
  include BoatEngine

  private GLUDIN_TO_RUNE = [
    VehiclePathPoint.new(-95686, 155514, -3610, 150, 800),
    VehiclePathPoint.new(-98112, 159040, -3610, 150, 800),
    VehiclePathPoint.new(-104192, 160608, -3610, 200, 1800),
    VehiclePathPoint.new(-109952, 159616, -3610, 250, 1800),
    VehiclePathPoint.new(-112768, 154784, -3610, 290, 1800),
    VehiclePathPoint.new(-114688, 139040, -3610, 290, 1800),
    VehiclePathPoint.new(-115232, 134368, -3610, 290, 1800),
    VehiclePathPoint.new(-113888, 121696, -3610, 290, 1800),
    VehiclePathPoint.new(-107808, 104928, -3610, 290, 1800),
    VehiclePathPoint.new(-97152, 75520, -3610, 290, 800),
    VehiclePathPoint.new(-85536, 67264, -3610, 290, 1800),
    VehiclePathPoint.new(-64640, 55840, -3610, 290, 1800),
    VehiclePathPoint.new(-60096, 44672, -3610, 290, 1800),
    VehiclePathPoint.new(-52672, 37440, -3610, 290, 1800),
    VehiclePathPoint.new(-46144, 33184, -3610, 290, 1800),
    VehiclePathPoint.new(-36096, 24928, -3610, 290, 1800),
    VehiclePathPoint.new(-33792, 8448, -3610, 290, 1800),
    VehiclePathPoint.new(-23776, 3424, -3610, 290, 1000),
    VehiclePathPoint.new(-12000, -1760, -3610, 290, 1000),
    VehiclePathPoint.new(672, 480, -3610, 290, 1800),
    VehiclePathPoint.new(15488, 200, -3610, 290, 1000),
    VehiclePathPoint.new(24736, 164, -3610, 290, 1000),
    VehiclePathPoint.new(32192, -1156, -3610, 290, 1000),
    VehiclePathPoint.new(39200, -8032, -3610, 270, 1000),
    VehiclePathPoint.new(44320, -25152, -3610, 270, 1000),
    VehiclePathPoint.new(40576, -31616, -3610, 250, 800),
    VehiclePathPoint.new(36819, -35315, -3610, 220, 800)
  ]

  private RUNE_DOCK = [VehiclePathPoint.new(34381, -37680, -3610, 200, 800)]

  private RUNE_TO_GLUDIN = [
    VehiclePathPoint.new(32750, -39300, -3610, 150, 800),
    VehiclePathPoint.new(27440, -39328, -3610, 180, 1000),
    VehiclePathPoint.new(21456, -34272, -3610, 200, 1000),
    VehiclePathPoint.new(6608, -29520, -3610, 250, 800),
    VehiclePathPoint.new(4160, -27828, -3610, 270, 800),
    VehiclePathPoint.new(2432, -25472, -3610, 270, 1000),
    VehiclePathPoint.new(-8000, -16272, -3610, 220, 1000),
    VehiclePathPoint.new(-18976, -9760, -3610, 290, 800),
    VehiclePathPoint.new(-23776, 3408, -3610, 290, 800),
    VehiclePathPoint.new(-33792, 8432, -3610, 290, 800),
    VehiclePathPoint.new(-36096, 24912, -3610, 290, 800),
    VehiclePathPoint.new(-46144, 33184, -3610, 290, 800),
    VehiclePathPoint.new(-52688, 37440, -3610, 290, 800),
    VehiclePathPoint.new(-60096, 44672, -3610, 290, 800),
    VehiclePathPoint.new(-64640, 55840, -3610, 290, 800),
    VehiclePathPoint.new(-85552, 67248, -3610, 290, 800),
    VehiclePathPoint.new(-97168, 85264, -3610, 290, 800),
    VehiclePathPoint.new(-107824, 104912, -3610, 290, 800),
    VehiclePathPoint.new(-102151, 135704, -3610, 290, 800),
    VehiclePathPoint.new(-96686, 140595, -3610, 290, 800),
    VehiclePathPoint.new(-95686, 147717, -3610, 250, 800),
    VehiclePathPoint.new(-95686, 148218, -3610, 200, 800)
  ]

  private ARRIVED_AT_GLUDIN = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_ARRIVED_AT_GLUDIN)
  private ARRIVED_AT_GLUDIN_2 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::DEPARTURE_FOR_RUNE_10_MINUTES)
  private LEAVE_GLUDIN5 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::DEPARTURE_FOR_RUNE_5_MINUTES)
  private LEAVE_GLUDIN1 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::DEPARTURE_FOR_RUNE_1_MINUTE)
  private LEAVE_GLUDIN0 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::DEPARTURE_FOR_GLUDIN_SHORTLY2)
  private LEAVING_GLUDIN = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::DEPARTURE_FOR_GLUDIN_NOW)
  private ARRIVED_AT_RUNE = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::ARRIVED_AT_RUNE)
  private ARRIVED_AT_RUNE_2 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_GLUDIN_AFTER_10_MINUTES)
  private LEAVE_RUNE5 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::DEPARTURE_FOR_GLUDIN_5_MINUTES)
  private LEAVE_RUNE1 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::DEPARTURE_FOR_GLUDIN_1_MINUTE)
  private LEAVE_RUNE0 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::DEPARTURE_FOR_GLUDIN_SHORTLY)
  private LEAVING_RUNE = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::DEPARTURE_FOR_GLUDIN_NOW)
  private BUSY_GLUDIN = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_RUNE_GLUDIN_DELAYED)
  private BUSY_RUNE = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_GLUDIN_RUNE_DELAYED)

  private ARRIVAL_RUNE15 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_GLUDIN_AT_RUNE_15_MINUTES)
  private ARRIVAL_RUNE10 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_GLUDIN_AT_RUNE_10_MINUTES)
  private ARRIVAL_RUNE5 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_GLUDIN_AT_RUNE_5_MINUTES)
  private ARRIVAL_RUNE1 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_GLUDIN_AT_RUNE_1_MINUTE)
  private ARRIVAL_GLUDIN15 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_RUNE_AT_GLUDIN_15_MINUTES)
  private ARRIVAL_GLUDIN10 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_RUNE_AT_GLUDIN_10_MINUTES)
  private ARRIVAL_GLUDIN5 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_RUNE_AT_GLUDIN_5_MINUTES)
  private ARRIVAL_GLUDIN1 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_RUNE_AT_GLUDIN_1_MINUTE)

  private GLUDIN_DOCK = [VehiclePathPoint.new(-95686, 150514, -3610, 150, 800)]

  def call
    case @cycle
    when 0
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], RUNE_DOCK[0], LEAVE_GLUDIN5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 1
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], RUNE_DOCK[0], LEAVE_GLUDIN1)
      ThreadPoolManager.schedule_general(self, 40_000)
    when 2
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], RUNE_DOCK[0], LEAVE_GLUDIN0)
      ThreadPoolManager.schedule_general(self, 20_000)
    when 3
      BoatManager.dock_ship(BoatManager::GLUDIN_HARBOR, false)
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], RUNE_DOCK[0], LEAVING_GLUDIN)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      @boat.pay_for_ride(7905, 1, -90015, 150422, -3610)
      @boat.execute_path(GLUDIN_TO_RUNE)
      ThreadPoolManager.schedule_general(self, 250_000)
    when 4
      BoatManager.broadcast_packets(RUNE_DOCK[0], GLUDIN_DOCK[0], ARRIVAL_RUNE15)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 5
      BoatManager.broadcast_packets(RUNE_DOCK[0], GLUDIN_DOCK[0], ARRIVAL_RUNE10)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 6
      BoatManager.broadcast_packets(RUNE_DOCK[0], GLUDIN_DOCK[0], ARRIVAL_RUNE5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 7
      BoatManager.broadcast_packets(RUNE_DOCK[0], GLUDIN_DOCK[0], ARRIVAL_RUNE1)
    when 8
      if BoatManager.dock_busy? BoatManager::RUNE_HARBOR
        if @shout_count == 0
          BoatManager.broadcast_packets(RUNE_DOCK[0], GLUDIN_DOCK[0], BUSY_RUNE)
        end

        @shout_count += 1
        if @shout_count > 35
          @shout_count = 0
        end

        ThreadPoolManager.schedule_general(self, 5_000)
        return
      else
        @boat.execute_path(RUNE_DOCK)
      end
    when 9
      BoatManager.dock_ship(BoatManager::RUNE_HARBOR, true)
      BoatManager.broadcast_packets(RUNE_DOCK[0], GLUDIN_DOCK[0], ARRIVED_AT_RUNE, ARRIVED_AT_RUNE_2)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      ThreadPoolManager.schedule_general(self, 300_000)
    when 10
      BoatManager.broadcast_packets(RUNE_DOCK[0], GLUDIN_DOCK[0], LEAVE_RUNE5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 11
      BoatManager.broadcast_packets(RUNE_DOCK[0], GLUDIN_DOCK[0], LEAVE_RUNE1)
      ThreadPoolManager.schedule_general(self, 40_000)
    when 12
      BoatManager.broadcast_packets(RUNE_DOCK[0], GLUDIN_DOCK[0], LEAVE_RUNE0)
      ThreadPoolManager.schedule_general(self, 20_000)
    when 13
      BoatManager.dock_ship(BoatManager::RUNE_HARBOR, false)
      BoatManager.broadcast_packets(RUNE_DOCK[0], GLUDIN_DOCK[0], LEAVING_RUNE)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      @boat.pay_for_ride(7904, 1, 34513, -38009, -3640)
      @boat.execute_path(RUNE_TO_GLUDIN)
      ThreadPoolManager.schedule_general(self, 60_000)
    when 14
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], RUNE_DOCK[0], ARRIVAL_GLUDIN15)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 15
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], RUNE_DOCK[0], ARRIVAL_GLUDIN10)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 16
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], RUNE_DOCK[0], ARRIVAL_GLUDIN5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 17
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], RUNE_DOCK[0], ARRIVAL_GLUDIN1)
    when 18
      if BoatManager.dock_busy? BoatManager::GLUDIN_HARBOR
        if @shout_count == 0
          BoatManager.broadcast_packets(GLUDIN_DOCK[0], RUNE_DOCK[0], BUSY_GLUDIN)
        end

        @shout_count += 1
        if @shout_count > 35
          @shout_count = 0
        end

        ThreadPoolManager.schedule_general(self, 5_000)
        return
      else
        @boat.execute_path(GLUDIN_DOCK)
      end
    when 19
      BoatManager.dock_ship(BoatManager::GLUDIN_HARBOR, true)
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], RUNE_DOCK[0], ARRIVED_AT_GLUDIN, ARRIVED_AT_GLUDIN_2)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      ThreadPoolManager.schedule_general(self, 300_000)
    else
      # [automatically added else]
    end

    @shout_count = 0
    @cycle += 1
    if @cycle > 19
      @cycle = 0
    end
  end
end
