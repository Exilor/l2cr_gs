class Packets::Outgoing::MultisellList < GameServerPacket
  @size : Int32

  def initialize(@list : Multisell::PreparedListContainer, @index : Int32)
    @size = list.entries.size - index

    if @size > MultisellData::PAGE_SIZE
      @finished = false
      @size = MultisellData::PAGE_SIZE
    else
      @finished = true
    end
  end

  private def write_impl
    c 0xd0

    d @list.list_id
    d 1 &+ (@index // MultisellData::PAGE_SIZE)
    d @finished ? 1 : 0
    d MultisellData::PAGE_SIZE
    d @size

    while @size > 0
      @size &-= 1
      ent = @list.entries[@index]
      @index &+= 1

      d ent.entry_id
      c ent.stackable? ? 1 : 0
      h 0x00
      d 0x00
      d 0x00
      h 65534
      h 0x00
      h 0x00
      h 0x00
      h 0x00
      h 0x00
      h 0x00
      h 0x00
      h ent.products.size
      h ent.ingredients.size

      ent.products.each do |ing|
        # debug "Sending info of product #{ing}."
        d ing.item_id
        if template = ing.template
          d template.body_part
          h template.type_2.id
        else
          d 0
          h 65535
        end
        q ing.item_count
        if info = ing.item_info
          h info.enchant_level
          d info.augment_id
          d 0x00
          h info.element_id
          h info.element_power
          info.elementals.each { |elem| h elem }
        else
          h 0x00
          d 0x00
          d 0x00
          h 0
          h 0
          h 0
          h 0
          h 0
          h 0
          h 0
          h 0
        end
      end

      ent.ingredients.each do |ing|
        # debug "Sending info of ingredient #{ing}."
        d ing.item_id
        h ing.template.try &.type_2.id || 65535
        q ing.item_count

        if info = ing.item_info
          h info.enchant_level
          d info.augment_id
          d 0x00
          h info.element_id
          h info.element_power
          info.elementals.each { |elem| h elem }
        else
          h 0x00
          d 0x00
          d 0x00
          h 0
          h 0
          h 0
          h 0
          h 0
          h 0
          h 0
          h 0
        end
      end
    end
  end
end
