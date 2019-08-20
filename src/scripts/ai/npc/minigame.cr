class Scripts::Minigame < AbstractNpcAI
  private SUMIEL = 32758
  private BURNER = 18913
  private TREASURE_BOX = 18911

  private UNLIT_TORCHLIGHT = 15540
  private TORCHLIGHT = 15485

  private SKILL_TORCH_LIGHT = 9059
  private TRIGGER_MIRAGE = SkillHolder.new(5144)

  private  TELEPORT1 = Location.new(113187, -85388, -3424, 0)
  private  TELEPORT2 = Location.new(118833, -80589, -2688, 0)

  private TIMER_INTERVAL = 3
  private MAX_ATTEMPTS = 3

  private ROOMS = [] of MinigameRoom

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(SUMIEL)
    add_first_talk_id(SUMIEL)
    add_talk_id(SUMIEL)
    add_spawn_id(SUMIEL, TREASURE_BOX)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    room = get_room_by_manager(npc).not_nil!

    case event
    when "restart"
      started = room.started?
      if !started && !has_quest_items?(pc, UNLIT_TORCHLIGHT)
        return "32758-05.html"
      elsif npc.target && npc.target != pc
        return "32758-04.html"
      end

      take_items(pc, UNLIT_TORCHLIGHT, 1)
      give_items(pc, TORCHLIGHT, 1)
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::THE_FURNACE_WILL_GO_OUT_WATCH_AND_SEE)

      room.manager.target = pc
      room.participant = pc
      room.started = true
      9.times do |i|
        room.order[i] = Rnd.rand(8)
      end
      cancel_quest_timer("hurry_up", npc, nil)
      cancel_quest_timer("hurry_up2", npc, nil)
      cancel_quest_timer("expire", npc, nil)

      start_quest_timer("hurry_up", 120000, npc, nil)
      start_quest_timer("expire", 190000, npc, nil)
      start_quest_timer("start", 1000, npc, nil)
      return
    when "off"
      if npc.id == BURNER
        npc.display_effect = 2
        npc.running = false
      else
        room.burners.each do |burner|
          burner.display_effect = 2
          burner.running = false
        end
      end
    when "teleport1"
      pc.tele_to_location(TELEPORT1, 0)
    when "teleport2"
      pc.tele_to_location(TELEPORT2, 0)
    when "start"
      room.burn_them_all
      start_quest_timer("off", 2000, npc, nil) # It should be nil to stop burn_them_all 2s after
      start_quest_timer("timer", 4000, npc, nil)
    when "timer"
      if room.current_pot < 9
        b = room.burners[room.order[room.current_pot]]
        b.display_effect = 1
        b.running = false
        start_quest_timer("off", 2000, b, nil) # Stopping burning each pot 2s after
        start_quest_timer("timer", TIMER_INTERVAL * 1000, npc, nil)
        room.current_pot += 1
      else
        broadcast_npc_say(room.manager, Say2::NPC_ALL, NpcString::NOW_LIGHT_THE_FURNACES_FIRE)
        room.burn_them_all
        start_quest_timer("off", 2000, npc, nil)
        event_type = EventType::ON_CREATURE_SKILL_USE
        listener = ConsumerEventListener.new(room.participant, event_type, room) do |evt|
          on_skill_use(evt.as(OnCreatureSkillUse))
        end
        room.listener = listener
        room.current_pot = 0
      end
    when "hurry_up"
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::THERES_ABOUT_1_MINUTE_LEFT)
      start_quest_timer("hurry_up2", 60000, npc, nil)
    when "hurry_up2"
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::THERES_JUST_10_SECONDS_LEFT)
      start_quest_timer("expire", 10000, npc, nil)
    when "expire"
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::TIME_IS_UP_AND_YOU_HAVE_FAILED_ANY_MORE_WILL_BE_DIFFICULT)
    when "end"
      cancel_quest_timer("expire", npc, nil)
      cancel_quest_timer("hurry_up", npc, nil)
      cancel_quest_timer("hurry_up2", npc, nil)
      room.clean
    when "afterthat"
      npc.delete_me
    end

    event
  end

  def on_first_talk(npc, pc)
    room = get_room_by_manager(npc).not_nil!
    started = room.started?

    if npc.target.nil?
      html = started ? "32758-08.html" : "32758.html"
    elsif npc.target == pc
      if started
        html = "32758-07.html"
      else
        attempt_number = room.attempt_number

        if attempt_number == 2
          html = "32758-02.html"
        elsif attempt_number == 3
          html = "32758-03.html"
        end
      end
    else
      html = "32758-04.html"
    end

    html
  end

  def on_spawn(npc)
    case npc.id
    when SUMIEL
      ROOMS << init_room(npc)
    when TREASURE_BOX
      npc.disable_core_ai(true)
      start_quest_timer("afterthat", 180000, npc, nil)
    end

    super
  end

  def on_skill_use(event : OnCreatureSkillUse)
    room = get_room_by_participant(event.caster.as(L2PcInstance)).not_nil!
    started = room.started?
    if started && event.skill.id == SKILL_TORCH_LIGHT
      event.targets.not_nil!.each do |obj|
        if npc = obj.as?(L2Npc)
          if npc.id == BURNER
            npc.do_cast(TRIGGER_MIRAGE)
            pos = room.get_burner_pos(npc)
            if pos == room.order[room.current_pot]
              if room.current_pot < 8
                npc.display_effect = 1
                npc.running = false
                start_quest_timer("off", 2000, npc, nil)
                room.current_pot += 1
              else
                add_spawn(TREASURE_BOX, room.participant.location, true, 0)
                broadcast_npc_say(room.manager, Say2::NPC_ALL, NpcString::OH_YOUVE_SUCCEEDED)
                room.current_pot = 0
                room.burn_them_all
                start_quest_timer("off", 2000, room.manager, nil)
                start_quest_timer("end", 4000, room.manager, nil)
              end
            else
              if room.attempt_number == MAX_ATTEMPTS
                broadcast_npc_say(room.manager, Say2::NPC_ALL, NpcString::AH_IVE_FAILED_GOING_FURTHER_WILL_BE_DIFFICULT)
                room.burn_them_all
                start_quest_timer("off", 2000, room.manager, nil)
                event_type = EventType::ON_CREATURE_SKILL_USE
                room.participant.remove_listener_if(event_type) do |listener|
                  listener.owner == room
                end
                start_quest_timer("end", 4000, room.manager, nil)
              elsif room.attempt_number < MAX_ATTEMPTS
                broadcast_npc_say(room.manager, Say2::NPC_ALL, NpcString::AH_IS_THIS_FAILURE_BUT_IT_LOOKS_LIKE_I_CAN_KEEP_GOING)
                room.burn_them_all
                start_quest_timer("off", 2000, room.manager, nil)
                room.attempt_number += 1
              end
            end
            break
          end
        end
      end
    end
  end

  def init_room(manager)
    burners = Array(L2Npc).new(9)
    pot_number = 0

    SpawnTable.get_spawns(BURNER).each do |sp|
      last_spawn = sp.last_spawn.not_nil!
      if pot_number <= 8 && Util.in_range?(1000, manager, last_spawn, false)
        last_spawn.auto_attackable = true
        burners << last_spawn
        pot_number += 1
      end
    end

    MinigameRoom.new(burners, manager)
  end

  def get_room_by_manager(manager)
    ROOMS.find { |room| room.manager == manager }
  end

  def get_room_by_participant(pc)
    ROOMS.find { |room| room.participant == pc }
  end

  private class MinigameRoom
    include EventListenerOwner

    getter order = Slice(Int32).new(9, 0)
    setter listener : ConsumerEventListener?
    property attempt_number : Int32 = 1
    property current_pot : Int32 = 0
    property! participant : L2PcInstance?
    property? started : Bool = false

    getter_initializer burners: Array(L2Npc), manager: L2Npc

    def get_burner_pos(npc)
      @burners.index { |burner| npc == burner } || 0
    end

    def burn_them_all
      @burners.each do |burner|
        burner.display_effect = 1
        burner.running = false
      end
    end

    def clean
      if tmp = @listener
        participant.remove_listener(tmp)
        @listener = nil
      end

      manager.target = nil
      self.participant = nil
      self.started = false
      self.attempt_number = 1
      self.current_pot = 0
    end
  end
end
