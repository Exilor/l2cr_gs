class Scripts::ChamberOfDelusionSquare < ChamberOfDelusion
  # NPCs
  private ENTRANCE_GATEKEEPER = 32662
  private ROOM_GATEKEEPER_FIRST = 32684
  private ROOM_GATEKEEPER_LAST = 32692
  private AENKINEL = 25694
  private BOX = 18820

  # Misc
  private ENTER_POINTS = [
    Location.new(-122368, -153388, -6688),
    Location.new(-122368, -152524, -6688),
    Location.new(-120480, -155116, -6688),
    Location.new(-120480, -154236, -6688),
    Location.new(-121440, -151212, -6688),
    Location.new(-120464, -152908, -6688),
    Location.new(-122368, -154700, -6688),
    Location.new(-121440, -152908, -6688),
    Location.new(-121440, -154572, -6688) # Raid room
  ]
  private INSTANCE_ID = 131
  private INSTANCE_TEMPLATE = "ChamberOfDelusionSquare.xml"

  def initialize
    super(self.class.simple_name, "instances", INSTANCE_ID, INSTANCE_TEMPLATE, ENTRANCE_GATEKEEPER, ROOM_GATEKEEPER_FIRST, ROOM_GATEKEEPER_LAST, AENKINEL, BOX)
    @room_enter_points = ENTER_POINTS
  end
end
