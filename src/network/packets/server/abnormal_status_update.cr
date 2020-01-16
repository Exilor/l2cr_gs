require "../game_server_packet"
require "../../../models/skills/buff_info"

class Packets::Outgoing::AbnormalStatusUpdate < GameServerPacket
  @effects = [] of BuffInfo

  def add_skill(info : BuffInfo)
    unless info.skill.healing_potion_skill?
      @effects << info
    end
  end

  private def write_impl
    c 0x85

    h @effects.size
    @effects.each do |info|
      if info.in_use?
        d info.skill.display_id
        h info.skill.display_level
        d info.time
      end
    end
  end
end
