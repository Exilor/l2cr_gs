require "./l2_doormen_instance"

class L2CastleDoormenInstance < L2DoormenInstance
  def instance_type : InstanceType
    InstanceType::L2DoormenInstance
  end

  private def open_doors(pc : L2PcInstance, command : String)
    st = command.from(10).split(", ")
    st.shift?

    st.each do |token|
      if hall = conquerable_hall
        hall.open_close_door(token.to_i, true)
      else
        castle.open_door(pc, token.to_i)
      end
    end
  end

  private def close_doors(pc : L2PcInstance, command : String)
    st = command.from(11).split(", ")
    st.shift?

    st.each do |token|
      if hall = conquerable_hall
        hall.open_close_door(token.to_i, false)
      else
        castle.close_door(pc, token.to_i)
      end
    end
  end

  private def owner_clan?(pc : L2PcInstance) : Bool
    if pc.clan && pc.has_clan_privilege?(ClanPrivilege::CS_OPEN_DOOR)
      if hall = conquerable_hall
        if pc.clan_id == hall.owner_id
          return true
        end
      elsif castle = castle?
        if pc.clan_id == castle.owner_id
          return true
        end
      end
    end

    false
  end

  private def under_siege? : Bool
    if hall = conquerable_hall
      return hall.in_siege?
    end

    castle.zone.active?
  end
end
