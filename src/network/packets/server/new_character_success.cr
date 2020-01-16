class Packets::Outgoing::NewCharacterSuccess < GameServerPacket
  static_packet

  private def write_impl
    c 0x0d

    templates = PlayerTemplateData.new_character_templates

    d templates.size

    templates.each do |t|
      d t.race.to_i
      d t.class_id.to_i
      d 0x46
      d t.base_str
      d 0x0a
      d 0x46
      d t.base_dex
      d 0x0a
      d 0x46
      d t.base_con
      d 0x0a
      d 0x46
      d t.base_int
      d 0x0a
      d 0x46
      d t.base_wit
      d 0x0a
      d 0x46
      d t.base_men
      d 0x0a
    end
  end
end
