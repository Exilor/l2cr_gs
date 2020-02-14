class Scripts::ChamberOfDelusionNorth < ChamberOfDelusion
  # NPCs
  private ENTRANCE_GATEKEEPER = 32661
  private ROOM_GATEKEEPER_FIRST = 32679
  private ROOM_GATEKEEPER_LAST = 32683
  private AENKINEL = 25693
  private BOX = 18838

  # Misc
  private ENTER_POINTS = [
    Location.new(-108976, -207772, -6720),
    Location.new(-108976, -206972, -6720),
    Location.new(-108960, -209164, -6720),
    Location.new(-108048, -207340, -6720),
    Location.new(-108048, -209020, -6720) # Raid room
  ]
  private INSTANCE_ID = 130
  private INSTANCE_TEMPLATE = "ChamberOfDelusionNorth.xml"

  def initialize
    super(self.class.simple_name, "instances", INSTANCE_ID, INSTANCE_TEMPLATE, ENTRANCE_GATEKEEPER, ROOM_GATEKEEPER_FIRST, ROOM_GATEKEEPER_LAST, AENKINEL, BOX)
    @room_enter_points = ENTER_POINTS
  end
end
