class Packets::Outgoing::ExChangePostState < GameServerPacket
  initializer received_board : Bool, changed_msg_ids : Indexable(Int32),
    change_id : Int32

  def initialize(received_board : Bool, changed_msg_ids : Int32, change_id : Int32)
    initialize(received_board, {changed_msg_ids}, change_id)
  end

  private def write_impl
    c 0xfe
    h 0xb3

    d @received_board ? 1 : 0

    d @changed_msg_ids.size
    @changed_msg_ids.each do |id|
      d id
      d @change_id
    end
  end
end
