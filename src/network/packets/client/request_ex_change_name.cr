class Packets::Incoming::RequestExChangeName < GameClientPacket
  @type = 0
  @new_name = ""
  @char_slot = 0

  def read_impl
    @type = d
    @new_name = s
    @char_slot = d
  end

  def run_impl
    # L2J TODO
    warn "Recieved #{@type} name: #{@new_name} type: #{@type} CharSlot: #{@char_slot}."
  end
end
