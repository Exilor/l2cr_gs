struct CharFlags
  private INVUL = 1 << 0
  private MORTAL = 1 << 1
  private DEAD = 1 << 2
  private PARALYZED = 1 << 3
  private IMMOBILIZED = 1 << 4
  private LETHALABLE = 1 << 5
  private OVERLOADED = 1 << 6
  private RUNNING = 1 << 7
  private FLYING = 1 << 8
  private TELEPORTING = 1 << 9
  private PENDING_REVIVE = 1 << 10
  private NO_RANDOM_WALK = 1 << 11
  private SHOW_SUMMON_ANIMATION = 1 << 12
  private ALL_SKILLS_DISABLED = 1 << 13
  private CORE_AI_DISABLED = 1 << 14
  private CASTING_NOW = 1 << 15
  private CASTING_SIMULTANEOUSLY_NOW = 1 << 16

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
