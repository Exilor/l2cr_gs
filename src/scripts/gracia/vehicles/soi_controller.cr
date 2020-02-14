class Scripts::SoIController < AirShipController
  private DOCK_ZONE = 50600
  private LOCATION = 101
  private CONTROLLER_ID = 32604

  private ARRIVAL = Slice[
    VehiclePathPoint.new(-214422, 211396, 5000, 280, 2000),
    VehiclePathPoint.new(-214422, 211396, 4422, 280, 2000)
  ]

  private DEPART = Slice[
    VehiclePathPoint.new(-214422, 211396, 5000, 280, 2000),
    VehiclePathPoint.new(-215877, 209709, 5000, 280, 2000)
  ]

  private TELEPORTS = Slice[
    Slice[
      VehiclePathPoint.new(-214422, 211396, 5000, 280, 2000),
      VehiclePathPoint.new(-215877, 209709, 5000, 280, 2000),
      VehiclePathPoint.new(-206692, 220997, 3000, 0, 0)
    ],
    Slice[
      VehiclePathPoint.new(-214422, 211396, 5000, 280, 2000),
      VehiclePathPoint.new(-215877, 209709, 5000, 280, 2000),
      VehiclePathPoint.new(-195357, 233430, 2500, 0, 0)
    ]
  ]

  private FUEL = Slice[
    0,
    50
  ]

  def initialize
    super(-1, self.class.simple_name, "gracia/vehicles")

    add_start_npc(CONTROLLER_ID)
    add_first_talk_id(CONTROLLER_ID)
    add_talk_id(CONTROLLER_ID)

    @dock_zone = DOCK_ZONE
    add_enter_zone_id(DOCK_ZONE)
    add_exit_zone_id(DOCK_ZONE)

    @ship_spawn_x = -212719
    @ship_spawn_y = 213348
    @ship_spawn_z = 5000

    @oust_loc = Location.new(-213401, 210401, 4408)

    @location_id = LOCATION
    @arrival_path = ARRIVAL
    @depart_path = DEPART
    @teleports_table = TELEPORTS
    @fuel_table = FUEL

    @movie_id = 1002

    validity_check
  end
end
