class Scripts::SoDController < AirShipController
  private DOCK_ZONE = 50601
  private LOCATION = 102
  private CONTROLLER_ID = 32605

  private ARRIVAL = Slice[
    VehiclePathPoint.new(-246445, 252331, 4359, 280, 2000),
  ]

  private DEPART = Slice[
    VehiclePathPoint.new(-245245, 251040, 4359, 280, 2000)
  ]

  private TELEPORTS = Slice[
    Slice[
      VehiclePathPoint.new(-245245, 251040, 4359, 280, 2000),
      VehiclePathPoint.new(-235693, 248843, 5100, 0, 0)
    ],
    Slice[
      VehiclePathPoint.new(-245245, 251040, 4359, 280, 2000),
      VehiclePathPoint.new(-195357, 233430, 2500, 0, 0)
    ]
  ]

  private FUEL = Slice[
    0,
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

    @ship_spawn_x = -247702
    @ship_spawn_y = 253631
    @ship_spawn_z = 4359

    @oust_loc = Location.new(-247746, 251079, 4328)

    @location_id = LOCATION
    @arrival_path = ARRIVAL
    @depart_path = DEPART
    @teleports_table = TELEPORTS
    @fuel_table = FUEL

    @movie_id = 1003

    validity_check
  end
end
