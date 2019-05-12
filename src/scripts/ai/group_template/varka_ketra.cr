class Scripts::VarkaKetra < AbstractNpcAI
  private KETRA = {
    21324, # Ketra Orc Footman
    21325, # Ketra's War Hound
    21327, # Ketra Orc Raider
    21328, # Ketra Orc Scout
    21329, # Ketra Orc Shaman
    21331, # Ketra Orc Warrior
    21332, # Ketra Orc Lieutenant
    21334, # Ketra Orc Medium
    21335, # Ketra Orc Elite Soldier
    21336, # Ketra Orc White Captain
    21338, # Ketra Orc Seer
    21339, # Ketra Orc General
    21340, # Ketra Orc Battalion Commander
    21342, # Ketra Orc Grand Seer
    21343, # Ketra Commander
    21344, # Ketra Elite Guard
    21345, # Ketra's Head Shaman
    21346, # Ketra's Head Guard
    21347, # Ketra Prophet
    21348, # Prophet's Guard
    21349, # Prophet's Aide
    25299, # Ketra's Hero Hekaton (Raid Boss)
    25302, # Ketra's Commander Tayr (Raid Boss)
    25305, # Ketra's Chief Brakki (Raid Boss)
    25306, # Soul of Fire Nastron (Raid Boss)
  }

  private VARKA = {
    21350, # Varka Silenos Recruit
    21351, # Varka Silenos Footman
    21353, # Varka Silenos Scout
    21354, # Varka Silenos Hunter
    21355, # Varka Silenos Shaman
    21357, # Varka Silenos Priest
    21358, # Varka Silenos Warrior
    21360, # Varka Silenos Medium
    21361, # Varka Silenos Magus
    21362, # Varka Silenos Officer
    21364, # Varka Silenos Seer
    21365, # Varka Silenos Great Magus
    21366, # Varka Silenos General
    21368, # Varka Silenos Great Seer
    21369, # Varka's Commander
    21370, # Varka's Elite Guard
    21371, # Varka's Head Magus
    21372, # Varka's Head Guard
    21373, # Varka's Prophet
    21374, # Prophet's Guard
    21375, # Disciple of Prophet
    25309, # Varka's Hero Shadith (Raid Boss)
    25312, # Varka's Commander Mos (Raid Boss)
    25315, # Varka's Chief Horus (Raid Boss)
    25316, # Soul of Water Ashutar (Raid Boss)
  }

  private KETRA_MARKS = {
    7211, # Mark of Ketra's Alliance - Level 1
    7212, # Mark of Ketra's Alliance - Level 2
    7213, # Mark of Ketra's Alliance - Level 3
    7214, # Mark of Ketra's Alliance - Level 4
    7215, # Mark of Ketra's Alliance - Level 5
  }

  private VARKA_MARKS = {
    7221, # Mark of Varka's Alliance - Level 1
    7222, # Mark of Varka's Alliance - Level 2
    7223, # Mark of Varka's Alliance - Level 3
    7224, # Mark of Varka's Alliance - Level 4
    7225, # Mark of Varka's Alliance - Level 5
  }

  private KETRA_QUESTS = {
    "Q00605_AllianceWithKetraOrcs",
    "Q00606_BattleAgainstVarkaSilenos",
    "Q00607_ProveYourCourageKetra",
    "Q00608_SlayTheEnemyCommanderKetra",
    "Q00609_MagicalPowerOfWaterPart1",
    "Q00610_MagicalPowerOfWaterPart2"
  }

  private VARKA_QUESTS = {
    "Q00611_AllianceWithVarkaSilenos",
    "Q00612_BattleAgainstKetraOrcs",
    "Q00613_ProveYourCourageVarka",
    "Q00614_SlayTheEnemyCommanderVarka",
    "Q00615_MagicalPowerOfFirePart1",
    "Q00616_MagicalPowerOfFirePart2"
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_kill_id(KETRA)
    add_kill_id(VARKA)
    add_npc_hate_id(KETRA)
    add_npc_hate_id(VARKA)
  end

  def action_for_each_player(pc, npc, is_summon)
    if Util.in_range?(1500, pc, npc, false)
      if KETRA.includes?(npc.id) && has_at_least_one_quest_item?(pc, KETRA_MARKS)
        decrease_alliance(pc, KETRA_MARKS)
        exit_quests(pc, KETRA_QUESTS)
      elsif VARKA.includes?(npc.id) && has_at_least_one_quest_item?(pc, VARKA_MARKS)
        decrease_alliance(pc, VARKA_MARKS)
        exit_quests(pc, VARKA_QUESTS)
      end
    end
  end

  private def decrease_alliance(pc, marks)
    marks.each_with_index do |mark, i|
      if has_quest_items?(pc, mark)
        take_items(pc, mark, -1)

        if i > 0
          give_items(pc, marks[i - 1], 1)
        end

        return
      end
    end
  end

  private def exit_quests(pc, quests)
    quests.each do |quest|
      qs = pc.get_quest_state(quest)
      if qs && qs.started?
        qs.exit_quest(true)
      end
    end
  end

  def on_kill(npc, killer, is_summon)
    execute_for_each_player(killer, npc, is_summon, true, false)
    super
  end

  def on_npc_hate(mob, pc, is_summon)
    if KETRA.includes?(mob.id)
      !has_at_least_one_quest_item?(pc, KETRA_MARKS)
    else
      !has_at_least_one_quest_item?(pc, VARKA_MARKS)
    end
  end
end
