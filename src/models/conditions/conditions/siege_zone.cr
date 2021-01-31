class Condition
  class SiegeZone < self
    COND_NOT_ZONE     = 0x0001
    COND_CAST_ATTACK  = 0x0002
    COND_CAST_DEFEND  = 0x0004
    COND_CAST_NEUTRAL = 0x0008
    COND_FORT_ATTACK  = 0x0010
    COND_FORT_DEFEND  = 0x0020
    COND_FORT_NEUTRAL = 0x0040
    COND_TW_CHANNEL   = 0x0080
    COND_TW_PROGRESS  = 0x0100

    initializer value : Int32, this : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      target = @this ? effector : effected
      unless target # custom
        return false
      end
      castle = CastleManager.get_castle(target)
      fort = FortManager.get_fort(target)

      if @value & COND_TW_PROGRESS != 0 && !TerritoryWarManager.tw_in_progress?
        return false
      elsif @value & COND_TW_CHANNEL != 0 && !TerritoryWarManager.tw_channel_open?
        return false
      elsif castle && fort
        return @value & COND_NOT_ZONE != 0
      end

      if castle
        return ok?(target, castle, @value)
      end

      ok?(target, fort, @value)
    end

    private def ok?(pc : L2Character?, castle : Castle?, value : Int32) : Bool
      unless pc.is_a?(L2PcInstance)
        return false
      end

      if castle.nil? || castle.residence_id <= 0
        if value & COND_NOT_ZONE != 0
          return true
        end
      elsif !castle.zone.active?
        if value & COND_NOT_ZONE != 0
          return true
        end
      elsif value & COND_CAST_ATTACK != 0 && pc.registered_on_this_siege_field?(castle.residence_id) && pc.siege_state == 1
        return true
      elsif value & COND_CAST_DEFEND != 0 && pc.registered_on_this_siege_field?(castle.residence_id) && pc.siege_state == 2
        return true
      elsif value & COND_CAST_NEUTRAL != 0 && pc.siege_state == 0
        return true
      end

      false
    end

    private def ok?(pc : L2Character?, fort : Fort?, value : Int32) : Bool
      unless pc.is_a?(L2PcInstance)
        return false
      end

      if fort.nil? || fort.residence_id <= 0
        if value & COND_NOT_ZONE != 0
          return true
        end
      elsif !fort.zone.active?
        if value & COND_NOT_ZONE != 0
          return true
        end
      elsif value & COND_FORT_ATTACK != 0 && pc.registered_on_this_siege_field?(fort.residence_id) && pc.siege_state == 1
        return true
      elsif value & COND_FORT_DEFEND != 0 && pc.registered_on_this_siege_field?(fort.residence_id) && pc.siege_state == 2
        return true
      elsif value & COND_FORT_NEUTRAL != 0 && pc.siege_state == 0
        return true
      end

      false
    end
  end
end
