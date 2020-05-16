class TvTEventTeam
  getter name, coordinates, points, participants

  def initialize(name : String, coordinates : Slice(Int32))
    @name = name
    @coordinates = coordinates
    @points = 0
    @participants = Concurrent::Map(Int32, L2PcInstance).new
  end

  def add_player(pc : L2PcInstance) : Bool
    return false unless pc
    @participants[pc.l2id] = pc
    true
  end

  def remove_player(l2id : Int32)
    @participants.delete(l2id)
  end

  def increase_points
    @points += 1
  end

  def clean_me
    @participants.clear
    @points = 0
  end

  def contains_player?(l2id : Int32) : Bool
    @participants.has_key?(l2id)
  end

  def participants_count : Int32
    @participants.size
  end
end
