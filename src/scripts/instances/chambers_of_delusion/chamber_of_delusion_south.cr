class Scripts::ChamberOfDelusionSouth < ChamberOfDelusion
  # NPCs
  private ENTRANCE_GATEKEEPER = 32660
  private ROOM_GATEKEEPER_FIRST = 32674
  private ROOM_GATEKEEPER_LAST = 32678
  private AENKINEL = 25692
  private BOX = 18838

  # Misc
  private ENTER_POINTS = [
    Location.new(-122368, -207820, -6720),
    Location.new(-122368, -206940, -6720),
    Location.new(-122368, -209116, -6720),
    Location.new(-121456, -207356, -6720),
    Location.new(-121440, -209004, -6720) # Raid room
  ]
  private INSTANCE_ID = 129
  private INSTANCE_TEMPLATE = "ChamberOfDelusionSouth.xml"

  def initialize
    super(self.class.simple_name, "instances", INSTANCE_ID, INSTANCE_TEMPLATE, ENTRANCE_GATEKEEPER, ROOM_GATEKEEPER_FIRST, ROOM_GATEKEEPER_LAST, AENKINEL, BOX)
    @room_enter_points = ENTER_POINTS
  end
end
