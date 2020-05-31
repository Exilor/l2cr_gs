class BoatGiranTalking
  include BoatEngine

  private GIRAN_TO_TALKING = [
    VehiclePathPoint.new(51914, 189023, -3610, 150, 800),
    VehiclePathPoint.new(60567, 189789, -3610, 150, 800),
    VehiclePathPoint.new(63732, 197457, -3610, 200, 800),
    VehiclePathPoint.new(63732, 219946, -3610, 250, 800),
    VehiclePathPoint.new(62008, 222240, -3610, 250, 1200),
    VehiclePathPoint.new(56115, 226791, -3610, 250, 1200),
    VehiclePathPoint.new(40384, 226432, -3610, 300, 800),
    VehiclePathPoint.new(37760, 226432, -3610, 300, 800),
    VehiclePathPoint.new(27153, 226791, -3610, 300, 800),
    VehiclePathPoint.new(12672, 227535, -3610, 300, 800),
    VehiclePathPoint.new(-1808, 228280, -3610, 300, 800),
    VehiclePathPoint.new(-22165, 230542, -3610, 300, 800),
    VehiclePathPoint.new(-42523, 235205, -3610, 300, 800),
    VehiclePathPoint.new(-68451, 259560, -3610, 250, 800),
    VehiclePathPoint.new(-70848, 261696, -3610, 200, 800),
    VehiclePathPoint.new(-83344, 261610, -3610, 200, 800),
    VehiclePathPoint.new(-88344, 261660, -3610, 180, 800),
    VehiclePathPoint.new(-92344, 261660, -3610, 180, 800),
    VehiclePathPoint.new(-94242, 261659, -3610, 150, 800)
  ]

  private TALKING_DOCK = [VehiclePathPoint.new(-96622, 261660, -3610, 150, 800)]

  private TALKING_TO_GIRAN = [
    VehiclePathPoint.new(-113925, 261660, -3610, 150, 800),
    VehiclePathPoint.new(-126107, 249116, -3610, 180, 800),
    VehiclePathPoint.new(-126107, 234499, -3610, 180, 800),
    VehiclePathPoint.new(-126107, 219882, -3610, 180, 800),
    VehiclePathPoint.new(-109414, 204914, -3610, 180, 800),
    VehiclePathPoint.new(-92807, 204914, -3610, 180, 800),
    VehiclePathPoint.new(-80425, 216450, -3610, 250, 800),
    VehiclePathPoint.new(-68043, 227987, -3610, 250, 800),
    VehiclePathPoint.new(-63744, 231168, -3610, 250, 800),
    VehiclePathPoint.new(-60844, 231369, -3610, 250, 1800),
    VehiclePathPoint.new(-44915, 231369, -3610, 200, 800),
    VehiclePathPoint.new(-28986, 231369, -3610, 200, 800),
    VehiclePathPoint.new(8233, 207624, -3610, 200, 800),
    VehiclePathPoint.new(21470, 201503, -3610, 180, 800),
    VehiclePathPoint.new(40058, 195383, -3610, 180, 800),
    VehiclePathPoint.new(43022, 193793, -3610, 150, 800),
    VehiclePathPoint.new(45986, 192203, -3610, 150, 800),
    VehiclePathPoint.new(48950, 190613, -3610, 150, 800)
  ]

  private GIRAN_DOCK = TALKING_TO_GIRAN[-1]

  private ARRIVED_AT_GIRAN = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_ARRIVED_AT_GIRAN)
  private ARRIVED_AT_GIRAN_2 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_TALKING_AFTER_10_MINUTES)
  private LEAVE_GIRAN5 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_TALKING_IN_5_MINUTES)
  private LEAVE_GIRAN1 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_TALKING_IN_1_MINUTE)
  private LEAVE_GIRAN0 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_SOON_FOR_TALKING)
  private LEAVING_GIRAN = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVING_FOR_TALKING)
  private ARRIVED_AT_TALKING = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_ARRIVED_AT_TALKING)
  private ARRIVED_AT_TALKING_2 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_GIRAN_AFTER_10_MINUTES)
  private LEAVE_TALKING5 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_GIRAN_IN_5_MINUTES)
  private LEAVE_TALKING1 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_FOR_GIRAN_IN_1_MINUTE)
  private LEAVE_TALKING0 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVE_SOON_FOR_GIRAN)
  private LEAVING_TALKING = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_LEAVING_FOR_GIRAN)
  private BUSY_TALKING = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_GIRAN_TALKING_DELAYED)

  private ARRIVAL_TALKING15 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_GIRAN_ARRIVE_AT_TALKING_15_MINUTES)
  private ARRIVAL_TALKING10 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_GIRAN_ARRIVE_AT_TALKING_10_MINUTES)
  private ARRIVAL_TALKING5 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_GIRAN_ARRIVE_AT_TALKING_5_MINUTES)
  private ARRIVAL_TALKING1 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_GIRAN_ARRIVE_AT_TALKING_1_MINUTE)
  private ARRIVAL_GIRAN20 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_TALKING_ARRIVE_AT_GIRAN_20_MINUTES)
  private ARRIVAL_GIRAN15 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_TALKING_ARRIVE_AT_GIRAN_15_MINUTES)
  private ARRIVAL_GIRAN10 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_TALKING_ARRIVE_AT_GIRAN_10_MINUTES)
  private ARRIVAL_GIRAN5 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_TALKING_ARRIVE_AT_GIRAN_5_MINUTES)
  private ARRIVAL_GIRAN1 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::FERRY_FROM_TALKING_ARRIVE_AT_GIRAN_1_MINUTE)

  def call
    case @cycle
    when 0
      BoatManager.broadcast_packets(GIRAN_DOCK, TALKING_DOCK[0], LEAVE_GIRAN5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 1
      BoatManager.broadcast_packets(GIRAN_DOCK, TALKING_DOCK[0], LEAVE_GIRAN1)
      ThreadPoolManager.schedule_general(self, 40_000)
    when 2
      BoatManager.broadcast_packets(GIRAN_DOCK, TALKING_DOCK[0], LEAVE_GIRAN0)
      ThreadPoolManager.schedule_general(self, 20_000)
    when 3
      BoatManager.broadcast_packets(GIRAN_DOCK, TALKING_DOCK[0], LEAVING_GIRAN, ARRIVAL_TALKING15)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      @boat.pay_for_ride(3946, 1, 46763, 187041, -3451)
      @boat.execute_path(GIRAN_TO_TALKING)
      ThreadPoolManager.schedule_general(self, 250_000)
    when 4
      BoatManager.broadcast_packets(TALKING_DOCK[0], GIRAN_DOCK, ARRIVAL_TALKING10)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 5
      BoatManager.broadcast_packets(TALKING_DOCK[0], GIRAN_DOCK, ARRIVAL_TALKING5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 6
      BoatManager.broadcast_packets(TALKING_DOCK[0], GIRAN_DOCK, ARRIVAL_TALKING1)
    when 7
      if BoatManager.dock_busy? BoatManager::TALKING_ISLAND
        if @shout_count == 0
          BoatManager.broadcast_packets(TALKING_DOCK[0], GIRAN_DOCK, BUSY_TALKING)
        end

        @shout_count &+= 1
        if @shout_count > 35
          @shout_count = 0
        end

        ThreadPoolManager.schedule_general(self, 5_000)
        return
      else
        @boat.execute_path(TALKING_DOCK)
      end
    when 8
      BoatManager.dock_ship(BoatManager::TALKING_ISLAND, true)
      BoatManager.broadcast_packets(TALKING_DOCK[0], GIRAN_DOCK, ARRIVED_AT_TALKING, ARRIVED_AT_TALKING_2)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      ThreadPoolManager.schedule_general(self, 300_000)
    when 9
      BoatManager.broadcast_packets(TALKING_DOCK[0], GIRAN_DOCK, LEAVE_TALKING5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 10
      BoatManager.broadcast_packets(TALKING_DOCK[0], GIRAN_DOCK, LEAVE_TALKING1)
      ThreadPoolManager.schedule_general(self, 40_000)
    when 11
      BoatManager.broadcast_packets(TALKING_DOCK[0], GIRAN_DOCK, LEAVE_TALKING0)
      ThreadPoolManager.schedule_general(self, 20_000)
    when 12
      BoatManager.dock_ship(BoatManager::TALKING_ISLAND, false)
      BoatManager.broadcast_packets(TALKING_DOCK[0], GIRAN_DOCK, LEAVING_TALKING)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      @boat.pay_for_ride(3945, 1, -96777, 258970, -3623)
      @boat.execute_path(TALKING_TO_GIRAN)
      ThreadPoolManager.schedule_general(self, 200_000)
    when 13
      BoatManager.broadcast_packets(GIRAN_DOCK, TALKING_DOCK[0], ARRIVAL_GIRAN20)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 14
      BoatManager.broadcast_packets(GIRAN_DOCK, TALKING_DOCK[0], ARRIVAL_GIRAN15)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 15
      BoatManager.broadcast_packets(GIRAN_DOCK, TALKING_DOCK[0], ARRIVAL_GIRAN10)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 16
      BoatManager.broadcast_packets(GIRAN_DOCK, TALKING_DOCK[0], ARRIVAL_GIRAN5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 17
      BoatManager.broadcast_packets(GIRAN_DOCK, TALKING_DOCK[0], ARRIVAL_GIRAN1)
    when 18
      BoatManager.broadcast_packets(GIRAN_DOCK, TALKING_DOCK[0], ARRIVED_AT_GIRAN, ARRIVED_AT_GIRAN_2)
      @boat.broadcast_packet(Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      ThreadPoolManager.schedule_general(self, 300_000)
    else
      # [automatically added else]
    end

    @shout_count = 0
    @cycle &+= 1
    if @cycle > 18
      @cycle = 0
    end
  end
end
