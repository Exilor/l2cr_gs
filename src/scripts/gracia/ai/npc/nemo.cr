class Scripts::Nemo < AbstractNpcAI
  # NPC
  private NEMO = 32735 # Nemo
  private MAGUEN = 18839 # Wild Maguen
  # Items
  private COLLECTOR = 15487 # Maguen Plasma Collector
  # Misc
  private MAXIMUM_MAGUEN = 18 # Maximum maguens in one time

  def initialize
    super(self.class.simple_name, "gracia/AI/NPC")

    add_start_npc(NEMO)
    add_first_talk_id(NEMO)
    add_talk_id(NEMO)
  end

  def on_adv_event(event, npc, pc)
    html = nil
    case event
    when "32735-01.html"
      html = event
    when "giveCollector"
      pc = pc.not_nil!
      if has_quest_items?(pc, COLLECTOR)
        html = "32735-03.html"
      elsif !pc.inventory_under_90?(false)
        html = "32735-04.html"
      else
        html = "32735-02.html"
        give_items(pc, COLLECTOR, 1)
      end
    when "summonMaguen"
      pc = pc.not_nil!
      npc = npc.not_nil!
      if pc.variables.get_i32("TEST_MAGUEN", 0) == 0 && npc.script_value < MAXIMUM_MAGUEN
         maguen = add_spawn(MAGUEN, npc.location, true, 60000, true)
        maguen.variables["SUMMON_PLAYER"] = pc
        maguen.variables["SPAWNED_NPC"] = npc
        maguen.variables["TEST_MAGUEN"] = 1
        pc.variables["TEST_MAGUEN"] = 1
        maguen.title = pc.name
        maguen.running = true
        maguen.set_intention(AI::FOLLOW, pc)
        maguen.broadcast_status_update
        show_on_screen_msg(pc, NpcString::MAGUEN_APPEARANCE, 2, 4000)
        maguen_ai.start_quest_timer("DIST_CHECK_TIMER", 1000, maguen, pc)
        npc.script_value &+= 1
        html = "32735-05.html"
      else
        html = "32735-06.html"
      end
    when "DECREASE_COUNT"
      pc = pc.not_nil!
      npc = npc.not_nil!
      spawned_npc = npc.variables.get_object("SPAWNED_NPC", L2Npc?)
      if spawned_npc && spawned_npc.script_value > 0
        pc.variables.delete("TEST_MAGUEN")
        spawned_npc.script_value &-= 1
      end
    else
      # [automatically added else]
    end


    html
  end

  private def maguen_ai
    QuestManager.get_quest(Maguen.simple_name).not_nil!
  end
end
