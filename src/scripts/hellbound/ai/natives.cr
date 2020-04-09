class Scripts::Natives < AbstractNpcAI
  # NPCs
  private NATIVE = 32362
  private INSURGENT = 32363
  private TRAITOR = 32364
  private INCASTLE = 32357
  # Items
  private MARK_OF_BETRAYAL = 9676 # Mark of Betrayal
  private BADGES = 9674 # Darion's Badge
  # Misc
  private DOORS = {
    19250003,
    19250004
  }

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_first_talk_id(NATIVE)
    add_first_talk_id(INSURGENT)
    add_first_talk_id(INCASTLE)
    add_start_npc(TRAITOR)
    add_start_npc(INCASTLE)
    add_talk_id(TRAITOR)
    add_talk_id(INCASTLE)
    add_spawn_id(NATIVE)
  end

  def on_first_talk(npc, pc)
    level = HellboundEngine.level

    case npc.id
    when NATIVE
      html = level > 5 ? "32362-01.htm" : "32362.htm"
    when INSURGENT
      html = level > 5 ? "32363-01.htm" : "32363.htm"
    when INCASTLE
      if level < 9
        html = "32357-01a.htm"
      elsif level == 9
        html = npc.busy? ? "32357-02.htm" : "32357-01.htm"
      else
        html = "32357-01b.htm"
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    if npc.id == TRAITOR
      if event.casecmp?("open_door")
        pc = pc.not_nil!
        if get_quest_items_count(pc, MARK_OF_BETRAYAL) >= 10
          take_items(pc, MARK_OF_BETRAYAL, 10)
          broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::ALRIGHT_NOW_LEODAS_IS_YOURS)
          HellboundEngine.update_trust(-50, true)

          DOORS.each do |door_id|
            if door = DoorData.get_door(door_id)
              door.open_me
            end
          end

          cancel_quest_timers("close_doors")
          start_quest_timer("close_doors", 1800000, npc, pc) # 30 min
        elsif has_quest_items?(pc, MARK_OF_BETRAYAL)
          html = "32364-01.htm"
        else
          html = "32364-02.htm"
        end
      elsif event.casecmp?("close_doors")
        DOORS.each do |door_id|
          if door = DoorData.get_door(door_id)
            door.close_me
          end
        end
      end
    elsif npc.id == NATIVE && event.casecmp?("hungry_death")
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::HUN_HUNGRY)
      npc.do_die(nil)
    elsif npc.id == INCASTLE
      pc = pc.not_nil!
      if event.casecmp?("FreeSlaves")
        if get_quest_items_count(pc, BADGES) >= 5
          take_items(pc, BADGES, 5)
          npc.busy = true # Prevent Native from take items more, than once
          HellboundEngine.update_trust(100, true)
          html = "32357-02.htm"
          start_quest_timer("delete_me", 3000, npc, nil)
        else
          html = "32357-02a.htm"
        end
      elsif event.casecmp?("delete_me")
        npc.busy = false # TODO: Does it really need?
        npc.delete_me
        npc.spawn.decrease_count(npc)
      end
    end

    html
  end

  def on_spawn(npc)
    if npc.id == NATIVE && HellboundEngine.level < 6
      start_quest_timer("hungry_death", 600000, npc, nil)
    end

    super
  end
end
