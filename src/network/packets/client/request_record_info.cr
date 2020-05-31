class Packets::Incoming::RequestRecordInfo < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    pc.known_list.each_object do |obj|
      if obj.poly? && obj.poly.morphed? && obj.poly.poly_type == "item"
        pc.send_packet(SpawnItem.new(obj))
      else
        unless obj.visible_for?(pc)
          obj.send_info(pc)
          if obj.is_a?(L2Character) && obj.ai?
            obj.ai.describe_state_to_player(pc)
          end
        end
      end
    end
  end
end
