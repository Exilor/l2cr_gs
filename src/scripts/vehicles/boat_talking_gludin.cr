class BoatTalkingGludin
  include BoatEngine

  private TALKING_TO_GLUDIN = [
    VehiclePathPoint.new(-121385, 261660, -3610, 180, 800),
    VehiclePathPoint.new(-127694, 253312, -3610, 200, 800),
    VehiclePathPoint.new(-129274, 237060, -3610, 250, 800),
    VehiclePathPoint.new(-114688, 139040, -3610, 200, 800),
    VehiclePathPoint.new(-109663, 135704, -3610, 180, 800),
    VehiclePathPoint.new(-102151, 135704, -3610, 180, 800),
    VehiclePathPoint.new(-96686, 140595, -3610, 180, 800),
    VehiclePathPoint.new(-95686, 147718, -3610, 180, 800),
    VehiclePathPoint.new(-95686, 148718, -3610, 180, 800),
    VehiclePathPoint.new(-95686, 149718, -3610, 150, 800)
  ]

  private GLUDIN_DOCK = [VehiclePathPoint.new(-95686, 150514, -3610, 150, 800)]

  private GLUDIN_TO_TALKING = [
    VehiclePathPoint.new(-95686, 155514, -3610, 180, 800),
    VehiclePathPoint.new(-95686, 185514, -3610, 250, 800),
    VehiclePathPoint.new(-60136, 238816, -3610, 200, 800),
    VehiclePathPoint.new(-60520, 259609, -3610, 180, 1800),
    VehiclePathPoint.new(-65344, 261460, -3610, 180, 1800),
    VehiclePathPoint.new(-83344, 261560, -3610, 180, 1800),
    VehiclePathPoint.new(-88344, 261660, -3610, 180, 1800),
    VehiclePathPoint.new(-92344, 261660, -3610, 150, 1800),
    VehiclePathPoint.new(-94242, 261659, -3610, 150, 1800)
  ]

  private TALKING_DOCK = [VehiclePathPoint.new(-96622, 261660, -3610, 150, 1800)]

  private ARRIVED_AT_TALKING   = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_ARRIVED_AT_TALKING)
  private ARRIVED_AT_TALKING_2 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_GLUDIN_AFTER_10_MINUTES)
  private LEAVE_TALKING5       = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_GLUDIN_IN_5_MINUTES)
  private LEAVE_TALKING1       = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_GLUDIN_IN_1_MINUTE)
  private LEAVE_TALKING1_2     = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::MAKE_HASTE_GET_ON_BOAT)
  private LEAVE_TALKING0       = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_SOON_FOR_GLUDIN)
  private LEAVING_TALKING      = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVING_FOR_GLUDIN)
  private ARRIVED_AT_GLUDIN    = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_ARRIVED_AT_GLUDIN)
  private ARRIVED_AT_GLUDIN_2  = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_TALKING_AFTER_10_MINUTES)
  private LEAVE_GLUDIN5        = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_TALKING_IN_5_MINUTES)
  private LEAVE_GLUDIN1        = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_TALKING_IN_1_MINUTE)
  private LEAVE_GLUDIN0        = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_SOON_FOR_TALKING)
  private LEAVING_GLUDIN       = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVING_FOR_TALKING)
  private BUSY_TALKING         = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_GLUDIN_TALKING_DELAYED)
  private BUSY_GLUDIN          = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_TALKING_GLUDIN_DELAYED)
  private ARRIVAL_GLUDIN10     = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_TALKING_ARRIVE_AT_GLUDIN_10_MINUTES)
  private ARRIVAL_GLUDIN5      = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_TALKING_ARRIVE_AT_GLUDIN_5_MINUTES)
  private ARRIVAL_GLUDIN1      = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_TALKING_ARRIVE_AT_GLUDIN_1_MINUTE)
  private ARRIVAL_TALKING10    = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_GLUDIN_ARRIVE_AT_TALKING_10_MINUTES)
  private ARRIVAL_TALKING5     = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_GLUDIN_ARRIVE_AT_TALKING_5_MINUTES)
  private ARRIVAL_TALKING1     = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_GLUDIN_ARRIVE_AT_TALKING_1_MINUTE)

  def call
    case @cycle
    when 0
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], LEAVE_TALKING5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 1
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], LEAVE_TALKING1, LEAVE_TALKING1_2)
      ThreadPoolManager.schedule_general(self, 40_000)
    when 2
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], LEAVE_TALKING0)
      ThreadPoolManager.schedule_general(self, 20_000)
    when 3
      BoatManager.dock_ship(BoatManager::TALKING_ISLAND, false)
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], LEAVING_TALKING)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      @boat.pay_for_ride(1074, 1, -96777, 258970, -3623)
      @boat.execute_path(TALKING_TO_GLUDIN)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 4
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], TALKING_DOCK[0], ARRIVAL_GLUDIN10)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 5
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], TALKING_DOCK[0], ARRIVAL_GLUDIN5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 6
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], TALKING_DOCK[0], ARRIVAL_GLUDIN1)
    when 7
      if BoatManager.dock_busy? BoatManager::GLUDIN_HARBOR
        if @shout_count == 0
          BoatManager.broadcast_packets(GLUDIN_DOCK[0], TALKING_DOCK[0], BUSY_GLUDIN)
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
    when 8
      BoatManager.dock_ship(BoatManager::GLUDIN_HARBOR, true)
      BoatManager.broadcast_packets(GLUDIN_DOCK[0], TALKING_DOCK[0], ARRIVED_AT_GLUDIN, ARRIVED_AT_GLUDIN_2)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      ThreadPoolManager.schedule_general(self, 300_000)
    when 9
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], LEAVE_GLUDIN5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 10
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], LEAVE_GLUDIN1, LEAVE_TALKING1_2)
      ThreadPoolManager.schedule_general(self, 40_000)
    when 11
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], LEAVE_GLUDIN0)
      ThreadPoolManager.schedule_general(self, 20_000)
    when 12
      BoatManager.dock_ship(BoatManager::GLUDIN_HARBOR, false)
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], LEAVING_GLUDIN)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      @boat.pay_for_ride(1075, 1, -90015, 150422, -3610)
      @boat.execute_path(GLUDIN_TO_TALKING)
      ThreadPoolManager.schedule_general(self, 150_000)
    when 13
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], ARRIVAL_TALKING10)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 14
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], ARRIVAL_TALKING5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 15
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], ARRIVAL_TALKING1)
    when 16
      if BoatManager.dock_busy? BoatManager::TALKING_ISLAND
        if @shout_count == 0
          BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], BUSY_TALKING)
        end

        @shout_count += 1
        if @shout_count > 35
          @shout_count = 0
        end

        ThreadPoolManager.schedule_general(self, 5_000)
        return
      else
        @boat.execute_path(TALKING_DOCK)
      end
    when 17
      BoatManager.dock_ship(BoatManager::TALKING_ISLAND, true)
      BoatManager.broadcast_packets(TALKING_DOCK[0], GLUDIN_DOCK[0], ARRIVED_AT_TALKING, ARRIVED_AT_TALKING_2)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      ThreadPoolManager.schedule_general(self, 300_000)
    else
      # [automatically added else]
    end

    @shout_count = 0
    @cycle += 1
    @cycle = 0 if @cycle > 17
  end
end
