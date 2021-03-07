require "./agathion"

module AgathionRepository
  extend self

  private AGATHIONS = {
    1539 => Agathion.new(1539, 539, 20818, 100000, 100000),
    1540 => Agathion.new(1540, 540, 20820, 100000, 100000),
    1541 => Agathion.new(1541, 541, 20822, 100000, 100000),
    1542 => Agathion.new(1542, 542, 20824, 100000, 100000),
    1543 => Agathion.new(1543, 543, 20826, 100000, 100000),
    1544 => Agathion.new(1544, 544, 20828, 100000, 100000),
    1545 => Agathion.new(1545, 545, 20830, 100000, 100000),
    1546 => Agathion.new(1546, 546, 20832, 100000, 100000),
    1547 => Agathion.new(1547, 547, 20834, 100000, 100000),
    1548 => Agathion.new(1548, 548, 20836, 100000, 100000),
    1549 => Agathion.new(1549, 549, 20838, 100000, 100000),
    1550 => Agathion.new(1550, 550, 20840, 100000, 100000),
    1576 => Agathion.new(1576, 576, 20983, 1000, 1000),
    1577 => Agathion.new(1577, 577, 20984, 1000, 1000),
    1578 => Agathion.new(1578, 578, 20985, 1000, 1000),
    1579 => Agathion.new(1579, 579, 20986, 1000, 1000),
    1580 => Agathion.new(1580, 580, 20987, 1000, 1000),
    1581 => Agathion.new(1581, 581, 20988, 1000, 1000),
    1582 => Agathion.new(1582, 582, 20989, 1000, 1000),
    1583 => Agathion.new(1583, 583, 20990, 1000, 1000),
    1584 => Agathion.new(1584, 584, 20991, 1000, 1000)
  }

  AGATHION_ITEMS = AGATHIONS.transform_keys { |k| AGATHIONS[k].item_id }

  def get_by_npc_id(npc_id : Int32) : Agathion?
    AGATHIONS[npc_id]?
  end

  def get_by_item_id(item_id : Int32) : Agathion?
    AGATHION_ITEMS[item_id]?
  end
end
