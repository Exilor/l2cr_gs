module BoatEngine
  include Loggable

  private alias CreatureSay = Packets::Outgoing::CreatureSay
  private alias Say2 = Packets::Incoming::Say2

  @cycle = 0
  @shout_count = 0

  initializer boat : L2BoatInstance
end
