class Packets::Outgoing::ExBrAgathionEnergyInfo < GameServerPacket
  @agathions : Array(L2ItemInstance)

  def initialize(*agathions : L2ItemInstance)
    @agathions = agathions.to_a
  end

  private def write_impl
    c 0xfe
    h 0xde

    d @agathions.size
    @agathions.each do |agathion|
      d agathion.l2id
      d agathion.id
      d 0x200000
      d agathion.agathion_remaining_energy
      d AgathionRepository.get_by_item_id(agathion.id).not_nil!.energy
    end
  end
end
