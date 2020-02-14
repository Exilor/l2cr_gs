class Scripts::KeucereusSouthController < AirShipController
  private DOCK_ZONE = 50603
  private LOCATION = 100
  private CONTROLLER_ID = 32517

  private ARRIVAL = Slice[
    VehiclePathPoint.new(-185312, 246544, 2500),
    VehiclePathPoint.new(-185312, 246544, 1336)
  ]

  private DEPART = Slice[
    VehiclePathPoint.new(-185312, 246544, 1700, 280, 2000),
    VehiclePathPoint.new(-186900, 251699, 1700, 280, 2000)
  ]

  private TELEPORTS = Slice[
    Slice[
      VehiclePathPoint.new(-185312, 246544, 1700, 280, 2000),
      VehiclePathPoint.new(-186900, 251699, 1700, 280, 2000),
      VehiclePathPoint.new(-186373, 234000, 2500, 0, 0)
    ],
    Slice[
      VehiclePathPoint.new(-185312, 246544, 1700, 280, 2000),
      VehiclePathPoint.new(-186900, 251699, 1700, 280, 2000),
      VehiclePathPoint.new(-206692, 220997, 3000, 0, 0)
    ],
    Slice[
      VehiclePathPoint.new(-185312, 246544, 1700, 280, 2000),
      VehiclePathPoint.new(-186900, 251699, 1700, 280, 2000),
      VehiclePathPoint.new(-235693, 248843, 5100, 0, 0)
    ]
  ]

  private FUEL = Slice[
    0,
    50,
    100
  ]

  def initialize
    super(-1, self.class.simple_name, "gracia/vehicles")

    add_start_npc(CONTROLLER_ID)
    add_first_talk_id(CONTROLLER_ID)
    add_talk_id(CONTROLLER_ID)

    @dock_zone = DOCK_ZONE
    add_enter_zone_id(DOCK_ZONE)
    add_exit_zone_id(DOCK_ZONE)

    @ship_spawn_x = -184527
    @ship_spawn_y = 243611
    @ship_spawn_z = 3000

    @location_id = LOCATION
    @arrival_path = ARRIVAL
    @depart_path = DEPART
    @teleports_table = TELEPORTS
    @fuel_table = FUEL

    @oust_loc = Location.new(-186148, 246296, 1360)

    @movie_id = 1000

    validity_check
  end
end
