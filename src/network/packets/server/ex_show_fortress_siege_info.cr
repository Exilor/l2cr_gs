class Packets::Outgoing::ExShowFortressSiegeInfo < GameServerPacket
  @fort_id : Int32
  @size : Int32
  @commanders : Array(FortSiegeSpawn)?
  @csize : Int32
  @csize2 : Int32

  def initialize(fort : Fort)
    @fort_id = fort.residence_id
    @size = fort.fort_size
    @commanders = FortSiegeManager.get_commander_spawn_list(@fort_id)
    @csize = @commanders.try &.size || 0
    @csize2 = fort.siege.commanders.size
  end

  private def write_impl
    c 0xfe
    h 0x17

    d @fort_id # Fortress Id
    d @size # Total Barracks Count
    if @csize > 0
      case @csize
      when 3
        case @csize2
        when 0
          d 0x03
        when 1
          d 0x02
        when 2
          d 0x01
        when 3
          d 0x00
        else
          # automatically added
        end

      when 4 # L2J TODO: change 4 to 5 once control room supporte
        case @csize2
        # L2J TODO: once control room supported, update writeD(0x0x) to support 5th room
        when 0
          d 0x05
        when 1
          d 0x04
        when 2
          d 0x03
        when 3
          d 0x02
        when 4
          d 0x01
        else
          # automatically added
        end

      else
        # automatically added
      end

    else
      @size.times do
        d 0
      end
    end
  end
end