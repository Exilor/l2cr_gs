require "../../../data/sql/pet_name_table"

class Packets::Incoming::RequestChangePetName < GameClientPacket
  private PET_NAME_MAX_LENGHT = 16

  @name = ""

  def read_impl
    @name = s
  end

  def run_impl
    return unless pc = active_char
    return unless pet = pc.summon

    unless pet.pet?
      pc.send_packet(SystemMessageId::DONT_HAVE_PET)
      return
    end

    unless pet.name.empty?
      pc.send_packet(SystemMessageId::NAMING_YOU_CANNOT_SET_NAME_OF_THE_PET)
      return
    end

    if PetNameTable.includes?(@name)
      pc.send_packet(SystemMessageId::NAMING_ALREADY_IN_USE_BY_ANOTHER_PET)
      return
    end

    if @name.empty? || @name.size > PET_NAME_MAX_LENGHT
      pc.send_packet(SystemMessageId::NAMING_CHARNAME_UP_TO_16CHARS)
      return
    end

    unless PetNameTable.valid?(@name)
      pc.send_packet(SystemMessageId::NAMING_PETNAME_CONTAINS_INVALID_CHARS)
      return
    end


    pet.name = @name
    pet.update_and_broadcast_status(1)
  end
end
