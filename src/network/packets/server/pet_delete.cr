class Packets::Outgoing::PetDelete < GameServerPacket
  initializer pet_type: Int32, pet_l2id: Int32

  def write_impl
    c 0xb7

    d @pet_type
    d @pet_l2id
  end
end
