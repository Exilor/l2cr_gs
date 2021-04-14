struct PlayerFlags
  private SITTING = 1 << 0
  private RECO_TWO_HOURS_GIVEN = 1 << 1
  private ENCHANTING = 1 << 2
  private IN_CRYSTALLIZE = 1 << 3
  private IN_CRAFT_MODE = 1 << 4
  private IN_SIEGE = 1 << 5
  private IN_HIDEOUT_SIEGE = 1 << 6
  private IN_7S_DUNGEON = 1 << 7
  private MINIMAP_ALLOWED = 1 << 8
  private DIET_MODE = 1 << 9
  private TRADE_REFUSAL = 1 << 10
  private FAKE_DEATH = 1 << 11
  private MARRIED = 1 << 12
  private MARRY_REQUEST = 1 << 13
  private MARRY_ACCEPTED = 1 << 14
  private COMBAT_FLAG_EQUIPPED = 1 << 15
  private FISHING = 1 << 16
  private IN_OLYMPIAD_MODE = 1 << 17
  private OLYMPIAD_START = 1 << 18
  private CHARM_OF_COURAGE = 1 << 19
  private HAS_PET_ITEMS = 1 << 20
  private ONLINE = 1 << 21
  private IN_OBSERVER_MODE = 1 << 22
  private NOBLE = 1 << 23
  private HERO = 1 << 24
  private MESSAGE_REFUSAL = 1 << 25
  private SILENCE_MODE = 1 << 26
  private INVENTORY_DISABLED = 1 << 27
  private ENGAGE_REQUEST = 1 << 28
  private CAN_REVIVE = 1 << 29
  private EXCHANGE_REFUSAL = 1 << 30
  private REVIVE_PET = 1 << 31
  private CAN_FEED = 1 << 32
  # Just one more flag and it won't fit a UInt32 anymore

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
