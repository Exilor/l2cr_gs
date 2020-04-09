class Scripts::DragonVortex < AbstractNpcAI
  # NPC
  private DRAGON_VORTEX = 32871
  # Raids
  private EMERALD_HORN = 25718
  private DUST_RIDER = 25719
  private BLEEDING_FLY = 25720
  private BLACKDAGGER_WING = 25721
  private SHADOW_SUMMONER = 25722
  private SPIKE_SLASHER = 25723
  private MUSCLE_BOMBER = 25724
  # Item
  private LARGE_DRAGON_BONE = 17248
  # Variables
  private I_QUEST0 = "I_QUEST0"
  # Locations
  private SPOT_1 = Location.new(92744,  114045, -3072)
  private SPOT_2 = Location.new(110112, 124976, -3624)
  private SPOT_3 = Location.new(121637, 113657, -3792)
  private SPOT_4 = Location.new(109346, 111849, -3040)

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(DRAGON_VORTEX)
    add_first_talk_id(DRAGON_VORTEX)
    add_talk_id(DRAGON_VORTEX)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    case event
    when "RAIDBOSS"
      pc = pc.not_nil!

      if has_quest_items?(pc, LARGE_DRAGON_BONE)
        if !npc.variables.get_bool(I_QUEST0, false)
          take_items(pc, LARGE_DRAGON_BONE, 1)
          random = Rnd.rand(100)

          if random < 3
            raid = MUSCLE_BOMBER
          elsif random < 8
            raid = SHADOW_SUMMONER
          elsif random < 15
            raid = SPIKE_SLASHER
          elsif random < 25
            raid = BLACKDAGGER_WING
          elsif random < 45
            raid = BLEEDING_FLY
          elsif random < 67
            raid = DUST_RIDER
          else
            raid = EMERALD_HORN
          end

          case npc.x
          when 92225
            loc = SPOT_1
          when 110116
            loc = SPOT_2
          when 121172
            loc = SPOT_3
          when 108924
            loc = SPOT_4
          else
            raise "Couldn't get location from #{npc.name}'s x coordinate (#{npc.x})"
          end

          npc.variables[I_QUEST0] = true
          add_spawn(raid, loc, false, 0, true)
          start_quest_timer("CANSPAWN", 60000, npc, nil)
        else
          return "32871-02.html"
        end
      else
        return "32871-01.html"
      end
    when "CANSPAWN"
      npc.variables[I_QUEST0] = false
    else
      # [automatically added else]
    end


    super
  end
end
