class Scripts::Lindvior < AbstractNpcAI
  private LINDVIOR_CAMERA = 18669
  private TOMARIS = 32552
  private ARTIUS = 32559

  private LINDVIOR_SCENE_ID = 1

  private RESET_HOUR = 18
  private RESET_MIN = 58
  private RESET_DAY_1 = Calendar::TUESDAY
  private RESET_DAY_2 = Calendar::FRIDAY

  @@alt_mode = false
  @@alt_mode_min = 60 # schedule delay in minutes if ALT_MODE enabled

  @lindvior_camera : L2Npc?
  @tomaris : L2Npc?
  @artius : L2Npc?

  def initialize
    super(self.class.simple_name, "gracia/AI")
    schedule_next_lindvior_visit
  end

  def on_adv_event(event, npc, player)
    case event
    when "tomaris_shout1"
      broadcast_npc_say(npc.not_nil!, Say2::NPC_SHOUT, NpcString::HUH_THE_SKY_LOOKS_FUNNY_WHATS_THAT)
    when "artius_shout"
      broadcast_npc_say(npc.not_nil!, Say2::NPC_SHOUT, NpcString::A_POWERFUL_SUBORDINATE_IS_BEING_HELD_BY_THE_BARRIER_ORB_THIS_REACTION_MEANS)
    when "tomaris_shout2"
      broadcast_npc_say(npc.not_nil!, Say2::NPC_SHOUT, NpcString::BE_CAREFUL_SOMETHINGS_COMING)
    when "lindvior_scene"
      if npc
        npc.known_list.each_player(4000) do |pl|
          if pl.z.between?(1100, 3100)
            pl.show_quest_movie(LINDVIOR_SCENE_ID)
          end
        end
      end
    when "start"
      @lindvior_camera = SpawnTable.find_any(LINDVIOR_CAMERA).not_nil!.last_spawn
      @tomaris = SpawnTable.find_any(TOMARIS).not_nil!.last_spawn
      @artius = SpawnTable.find_any(ARTIUS).not_nil!.last_spawn

      start_quest_timer("tomaris_shout1", 1000, @tomaris, nil)
      start_quest_timer("artius_shout", 60000, @artius, nil)
      start_quest_timer("tomaris_shout2", 90000, @tomaris, nil)
      start_quest_timer("lindvior_scene", 120000, @lindvior_camera, nil)
      schedule_next_lindvior_visit
    end

    super
  end

  def schedule_next_lindvior_visit
    if @@alt_mode
      delay = @@alt_mode_min.to_i64 * 60000
    else
      delay = schedule_next_lindvior_date
    end
    start_quest_timer("start", delay, nil, nil)
  end

  private def schedule_next_lindvior_date : Int64
    date = Calendar.new
    date.minute = RESET_MIN
    date.hour = RESET_HOUR
    if Time.ms >= date.ms
      date.add(:DAY, 1)
    end

    day_of_week = date.day_of_week
    if day_of_week <= RESET_DAY_1
      date.add(:DAY, RESET_DAY_1 - day_of_week)
    elsif day_of_week <= RESET_DAY_2
      date.add(:DAY, RESET_DAY_2 - day_of_week)
    else
      date.add(:DAY, 1 + RESET_DAY_1)
    end

    date.ms - Time.ms
  end
end
