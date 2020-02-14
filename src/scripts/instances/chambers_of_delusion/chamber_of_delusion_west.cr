class Scripts::ChamberOfDelusionWest < ChamberOfDelusion
  # NPCs
  private ENTRANCE_GATEKEEPER = 32659
  private ROOM_GATEKEEPER_FIRST = 32669
  private ROOM_GATEKEEPER_LAST = 32673
  private AENKINEL = 25691
  private BOX = 18838

  # Misc
  private ENTER_POINTS = [
    Location.new(-108960, -218892, -6720),
    Location.new(-108976, -218028, -6720),
    Location.new(-108960, -220204, -6720),
    Location.new(-108032, -218428, -6720),
    Location.new(-108032, -220140, -6720) # Raid room
  ]
  private INSTANCE_ID = 128
  private INSTANCE_TEMPLATE = "ChamberOfDelusionWest.xml"

  def initialize
    super(self.class.simple_name, "instances", INSTANCE_ID, INSTANCE_TEMPLATE, ENTRANCE_GATEKEEPER, ROOM_GATEKEEPER_FIRST, ROOM_GATEKEEPER_LAST, AENKINEL, BOX)
    @room_enter_points = ENTER_POINTS
  end
end
