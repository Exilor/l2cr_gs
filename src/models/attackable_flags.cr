struct AttackableFlags
  private SEEDED = 1 << 0
  private RAID_MINION = 1 << 1
  private ABSORBED = 1 << 2
  private OVERHIT = 1 << 9
  private CHAMPION = 1 << 10
  private RAID = 1 << 11
  private MUST_REWARD_EXP_SP = 1 << 12
  private CAN_RETURN_TO_SPAWN_POINT = 1 << 13
  private RETURNING_TO_SPAWN_POINT = 1 << 14
  private CAN_SEE_THROUGH_SILENT_MOVE = 1 << 15

  @mask = 0u32

  {% for c in @type.constants %}
    def {{c.stringify.downcase.id}}? : Bool
      @mask & {{c}} != 0
    end

    def {{c.stringify.downcase.id}}=(val : Bool)
      if val
        @mask |= {{c}}
      else
        @mask &= ~{{c}}
      end
    end
  {% end %}
end
