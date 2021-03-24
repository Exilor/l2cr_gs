class Packets::Outgoing::PartyMemberPosition < GameServerPacket
  @locations = {} of Int32 => Location

  def initialize(party : L2Party)
    reuse(party)
  end

  def reuse(party : L2Party)
    @locations.clear
    party.each { |m| @locations[m.l2id] = m.location }
    self
  end

  private def write_impl
    c 0xba
    d @locations.size
    # directly iterating the hash has raised a "can't add a new key into hash
    # during iteration" at least once in Ruby but Crystal as of 0.35.1 doesn't.
    @locations.each do |id, loc|
      d id
      l loc
    end
  end
end
