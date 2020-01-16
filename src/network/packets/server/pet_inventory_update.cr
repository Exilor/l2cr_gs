class Packets::Outgoing::PetInventoryUpdate < Packets::Outgoing::AbstractInventoryUpdate
  private def write_impl
    c 0xb4
    super
  end
end
