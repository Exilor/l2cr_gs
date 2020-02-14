class Scripts::ChamberOfDelusionEast < ChamberOfDelusion
  # NPCs
  private ENTRANCE_GATEKEEPER = 32658
  private ROOM_GATEKEEPER_FIRST = 32664
  private ROOM_GATEKEEPER_LAST = 32668
  private AENKINEL = 25690
  private BOX = 18838

  # Misc
  private ENTER_POINTS = [
    Location.new(-122368, -218972, -6720),
    Location.new(-122352, -218044, -6720),
    Location.new(-122368, -220220, -6720),
    Location.new(-121440, -218444, -6720),
    Location.new(-121424, -220124, -6720) # Raid room
  ]
  private INSTANCE_ID = 127
  private INSTANCE_TEMPLATE = "ChamberOfDelusionEast.xml"

  def initialize
    super(self.class.simple_name, "instances", INSTANCE_ID, INSTANCE_TEMPLATE, ENTRANCE_GATEKEEPER, ROOM_GATEKEEPER_FIRST, ROOM_GATEKEEPER_LAST, AENKINEL, BOX)
    @room_enter_points = ENTER_POINTS
  end
end
