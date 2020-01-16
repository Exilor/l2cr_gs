require "./playable_known_list"

class PcKnownList < PlayableKnownList
  include Packets::Outgoing

  def add_known_object(object : L2Object) : Bool
    return false unless super

    me = active_char

    if object.poly.morphed? && object.poly.poly_type == "item"
      me.send_packet(SpawnItem.new(object))
    else
      if object.visible_for?(me)
        object.send_info(me)
        if object.is_a?(L2Character) && object.ai?
          object.ai.describe_state_to_player(me)
        end
      end
    end

    true
  end

  def remove_known_object(object : L2Object?, forget : Bool)
    return false unless super

    me = active_char

    if object.is_a?(L2AirshipInstance)
      if object.captain_id != 0 && object.captain_id != @active_object.l2id
        me.send_packet(DeleteObject.new(object.captain_id))
      end

      if object.helm_l2id != 0
        me.send_packet(DeleteObject.new(object.helm_l2id))
      end
    end

    me.send_packet(DeleteObject.new(object))

    if Config.check_known && object.npc? && me.gm?
      me.send_message("Removed NPC: #{object.name}")
    end

    true
  end

  def get_distance_to_forget_object(object : L2Object) : Int32
    return 10_000 if object.vehicle?

    case known_objects.size
    when 0..25  then 4000
    when 26..35 then 3500
    when 36..70 then 2910
    else 2310
    end
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    return 9000 if object.vehicle?

    case known_objects.size
    when 0..25  then 3400
    when 26..35 then 2900
    when 36..70 then 2300
    else 1700
    end
  end

  def active_char : L2PcInstance
    super.as(L2PcInstance)
  end
end
