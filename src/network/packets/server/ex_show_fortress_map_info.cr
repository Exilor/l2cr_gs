class Packets::Outgoing::ExShowFortressMapInfo < GameServerPacket
  initializer fort : Fort

  private def write_impl
    c 0xfe
    h 0x7d

    d @fort.residence_id
    d @fort.siege.in_progress? ? 1 : 0
    d @fort.fort_size

    commanders = FortSiegeManager.get_commander_spawn_list(@fort.residence_id)

    if commanders && !commanders.empty? && @fort.siege.in_progress?
      case commanders.size
      when 3
        commanders.each do |sp|
          if spawned?(sp.id)
            d 0
          else
            d 1
          end
        end
      when 4
        count = 0
        commanders.each do |sp|
          count += 1
          if count == 4
            d 1
          end
          if spawned?(sp.id)
            d 0
          else
            d 1
          end
        end
      else
        # [automatically added else]
      end

    else
      @fort.fort_size.times do
        d 0
      end
    end
  end

  private def spawned?(id)
    @fort.siege.commanders.any? { |sp| sp.id == id }
  end
end
