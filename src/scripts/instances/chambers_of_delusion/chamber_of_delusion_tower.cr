class Scripts::ChamberOfDelusionTower < ChamberOfDelusion
  # NPCs
  private ENTRANCE_GATEKEEPER = 32663
  private ROOM_GATEKEEPER_FIRST = 32693
  private ROOM_GATEKEEPER_LAST = 32701
  private AENKINEL = 25695
  private BOX = 18823

  # Misc
  private ENTER_POINTS = [
    Location.new(-108976, -153372, -6688),
    Location.new(-108960, -152524, -6688),
    Location.new(-107088, -155052, -6688),
    Location.new(-107104, -154236, -6688),
    Location.new(-108048, -151244, -6688),
    Location.new(-107088, -152956, -6688),
    Location.new(-108992, -154604, -6688),
    Location.new(-108032, -152892, -6688),
    Location.new(-108048, -154572, -6688) # Raid room
  ]
  private INSTANCE_ID = 132
  private INSTANCE_TEMPLATE = "ChamberOfDelusionTower.xml"

  def initialize
    super(self.class.simple_name, "instances", INSTANCE_ID, INSTANCE_TEMPLATE, ENTRANCE_GATEKEEPER, ROOM_GATEKEEPER_FIRST, ROOM_GATEKEEPER_LAST, AENKINEL, BOX)
    @room_enter_points = ENTER_POINTS
  end
end
