class BoatInnadrilTour
  include BoatEngine

  private TOUR = [
    VehiclePathPoint.new(105129, 226240, -3610, 150, 800),
    VehiclePathPoint.new(90604, 238797, -3610, 150, 800),
    VehiclePathPoint.new(74853, 237943, -3610, 150, 800),
    VehiclePathPoint.new(68207, 235399, -3610, 150, 800),
    VehiclePathPoint.new(63226, 230487, -3610, 150, 800),
    VehiclePathPoint.new(61843, 224797, -3610, 150, 800),
    VehiclePathPoint.new(61822, 203066, -3610, 150, 800),
    VehiclePathPoint.new(59051, 197685, -3610, 150, 800),
    VehiclePathPoint.new(54048, 195298, -3610, 150, 800),
    VehiclePathPoint.new(41609, 195687, -3610, 150, 800),
    VehiclePathPoint.new(35821, 200284, -3610, 150, 800),
    VehiclePathPoint.new(35567, 205265, -3610, 150, 800),
    VehiclePathPoint.new(35617, 222471, -3610, 150, 800),
    VehiclePathPoint.new(37932, 226588, -3610, 150, 800),
    VehiclePathPoint.new(42932, 229394, -3610, 150, 800),
    VehiclePathPoint.new(74324, 245231, -3610, 150, 800),
    VehiclePathPoint.new(81872, 250314, -3610, 150, 800),
    VehiclePathPoint.new(101692, 249882, -3610, 150, 800),
    VehiclePathPoint.new(107907, 256073, -3610, 150, 800),
    VehiclePathPoint.new(112317, 257133, -3610, 150, 800),
    VehiclePathPoint.new(126273, 255313, -3610, 150, 800),
    VehiclePathPoint.new(128067, 250961, -3610, 150, 800),
    VehiclePathPoint.new(128520, 238249, -3610, 150, 800),
    VehiclePathPoint.new(126428, 235072, -3610, 150, 800),
    VehiclePathPoint.new(121843, 234656, -3610, 150, 800),
    VehiclePathPoint.new(120096, 234268, -3610, 150, 800),
    VehiclePathPoint.new(118572, 233046, -3610, 150, 800),
    VehiclePathPoint.new(117671, 228951, -3610, 150, 800),
    VehiclePathPoint.new(115936, 226540, -3610, 150, 800),
    VehiclePathPoint.new(113628, 226240, -3610, 150, 800),
    VehiclePathPoint.new(111300, 226240, -3610, 150, 800),
    VehiclePathPoint.new(111264, 226240, -3610, 150, 800)
  ]

  private DOCK = TOUR[-1]

  private ARRIVED_AT_INNADRIL = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::INNADRIL_BOAT_ANCHOR_10_MINUTES)
  private LEAVE_INNADRIL5 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::INNADRIL_BOAT_LEAVE_IN_5_MINUTES)
  private LEAVE_INNADRIL1 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::INNADRIL_BOAT_LEAVE_IN_1_MINUTE)
  private LEAVE_INNADRIL0 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::INNADRIL_BOAT_LEAVE_SOON)
  private LEAVING_INNADRIL = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::INNADRIL_BOAT_LEAVING)
  private ARRIVAL20 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::INNADRIL_BOAT_ARRIVE_20_MINUTES)
  private ARRIVAL15 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::INNADRIL_BOAT_ARRIVE_15_MINUTES)
  private ARRIVAL10 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::INNADRIL_BOAT_ARRIVE_10_MINUTES)
  private ARRIVAL5 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::INNADRIL_BOAT_ARRIVE_5_MINUTES)
  private ARRIVAL1 = CreatureSay.new(0, Say2::BOAT, 801, SystemMessageId::INNADRIL_BOAT_ARRIVE_1_MINUTE)

  def call
    case @cycle
    when 0
      BoatManager.broadcast_packets(DOCK, DOCK, LEAVE_INNADRIL5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 1
      BoatManager.broadcast_packets(DOCK, DOCK, LEAVE_INNADRIL1)
      ThreadPoolManager.schedule_general(self, 40_000)
    when 2
      BoatManager.broadcast_packets(DOCK, DOCK, LEAVE_INNADRIL0)
      ThreadPoolManager.schedule_general(self, 20_000)
    when 3
      BoatManager.broadcast_packets(DOCK, DOCK, LEAVING_INNADRIL, Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      @boat.pay_for_ride(0, 1, 107092, 219098, -3952)
      @boat.execute_path(TOUR)
      ThreadPoolManager.schedule_general(self, 650_000)
    when 4
      BoatManager.broadcast_packets(DOCK, DOCK, ARRIVAL20)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 5
      BoatManager.broadcast_packets(DOCK, DOCK, ARRIVAL15)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 6
      BoatManager.broadcast_packets(DOCK, DOCK, ARRIVAL10)
      ThreadPoolManager.schedule_general(self, 300_000)
    when 7
      BoatManager.broadcast_packets(DOCK, DOCK, ARRIVAL5)
      ThreadPoolManager.schedule_general(self, 240_000)
    when 8
      BoatManager.broadcast_packets(DOCK, DOCK, ARRIVAL1)
    when 9
      BoatManager.broadcast_packets(DOCK, DOCK, ARRIVED_AT_INNADRIL, Sound::ITEMSOUND_SHIP_ARRIVAL_DEPARTURE.with_object(@boat))
      ThreadPoolManager.schedule_general(self, 300_000)
    else
      # [automatically added else]
    end

    @cycle += 1
    if @cycle > 9
      @cycle = 0
    end
  end

  def to_log(io : IO)
    io << "Boat (Innadril Tour)"
  end
end
