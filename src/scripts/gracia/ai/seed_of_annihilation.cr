class Scripts::SeedOfAnnihilation < AbstractNpcAI
  private ANNIHILATION_FURNACE = 18928

  # Skills
  private SOUL_WEAKNESS = SkillHolder.new(6408)
  private TREYKAN_TRANSFORMATION = SkillHolder.new(6649)

  # Strength, Agility, Wisdom
  private ZONE_BUFFS = {
    0,
    6443,
    6444,
    6442
  }

  private ZONE_BUFFS_LIST = {
    {1, 2, 3},
    {1, 3, 2},
    {2, 1, 3},
    {2, 3, 1},
    {3, 2, 1},
    {3, 1, 2}
  }

  private TELEPORT_ZONES = {
    60002 => Location.new(-213175, 182648, -10992),
    60003 => Location.new(-181217, 186711, -10528),
    60004 => Location.new(-180211, 182984, -15152),
    60005 => Location.new(-179275, 186802, -10720)
  }

  # 0: Bistakon, 1: Reptilikon, 2: Cokrakon
  private REGION_DATA = {
    SeedRegion.new(
      [22750, 22751, 22752, 22753],
      [
        [22746, 22746, 22746],
        [22747, 22747, 22747],
        [22748, 22748, 22748],
        [22749, 22749, 22749]
      ],
      60006,
      [
        [-180450, 185507, -10544, 11632],
        [-180005, 185489, -10544, 11632]
      ]
    ),
    SeedRegion.new(
      [22757, 22758, 22759],
      [
        [22754, 22755, 22756]
      ],
      60007,
      [
        [-179600, 186998, -10704, 11632],
        [-179295, 186444, -10704, 11632]
      ]
    ),
    SeedRegion.new(
      [22763, 22764, 22765],
      [
        [22760, 22760, 22761],
        [22760, 22760, 22762],
        [22761, 22761, 22760],
        [22761, 22761, 22762],
        [22762, 22762, 22760],
        [22762, 22762, 22761]
      ],
      60008,
      [
        [-180971, 186361, -10528, 11632],
        [-180758, 186739, -10528, 11632]
      ]
    )
  }

  @seeds_next_status_change = 0i64

  def initialize
    super(self.class.simple_name, "gracia/AI")

    load_seed_region_data
    TELEPORT_ZONES.each_key do |i|
      add_enter_zone_id(i)
    end
    REGION_DATA.each do |element|
      element.elite_mob_ids.each do |elite_mob_id|
        add_spawn_id(elite_mob_id)
      end
    end
    add_start_npc(32739)
    add_talk_id(32739)
    start_effect_zones_control
  end

  def load_seed_region_data
    buffs_now = 0
    var = load_global_quest_var("SeedNextStatusChange")

    if var.empty? || var.to_i64 < Time.ms
      buffs_now = rand(ZONE_BUFFS_LIST.size)
      save_global_quest_var("SeedBuffsList", buffs_now.to_s)
      @seeds_next_status_change = get_next_seeds_status_change_time
      save_global_quest_var("SeedNextStatusChange", @seeds_next_status_change.to_s)
    else
      @seeds_next_status_change = var.to_i64
      buffs_now = load_global_quest_var("SeedBuffsList").to_i
    end

    REGION_DATA.each_with_index do |e, i|
      e.active_buff = ZONE_BUFFS_LIST[buffs_now][i]
    end
  end

  private def get_next_seeds_status_change_time
    reenter = Calendar.new
    reenter.second = 0
    reenter.minute = 0
    reenter.hour = 13
    reenter.day_of_week = Calendar::MONDAY
    if reenter.ms <= Time.ms
      reenter.add(:DAY, 7)
    end

    debug { "Next seeds status change at #{reenter}." }

    reenter.ms
  end

  private def start_effect_zones_control
    REGION_DATA.size.times do |i|
      REGION_DATA[i].af_spawns.size.times do |j|
        sp = add_spawn(ANNIHILATION_FURNACE, REGION_DATA[i].af_spawns[j][0], REGION_DATA[i].af_spawns[j][1], REGION_DATA[i].af_spawns[j][2], REGION_DATA[i].af_spawns[j][3], false, 0)
        REGION_DATA[i].af_npcs[j] = sp
        sp.display_effect = REGION_DATA[i].active_buff
      end

      zone = ZoneManager.get_zone_by_id!(REGION_DATA[i].buff_zone, L2EffectZone)
      zone.add_skill(ZONE_BUFFS[REGION_DATA[i].active_buff], 1)
    end

    start_quest_timer("ChangeSeedsStatus", @seeds_next_status_change - Time.ms, nil, nil)
  end

  private def spawn_group_of_minions(npc, mob_ids)
    mob_ids.each { |mob_id| add_minion(npc, mob_id) }
  end

  def on_spawn(npc)
    REGION_DATA.each do |element|
      if element.elite_mob_ids.includes?(npc.id)
        spawn_group_of_minions(npc.as(L2MonsterInstance), element.minion_lists.sample)
      end
    end

    super
  end

  def on_adv_event(event, npc, pc)
    debug { "on_adv_event(event: #{event}, npc: #{npc}, pc: #{pc})" }

    if event.casecmp?("ChangeSeedsStatus")
      buffs_now = Rnd.rand(ZONE_BUFFS_LIST.size)
      save_global_quest_var("SeedBuffsList", buffs_now.to_s)
      @seeds_next_status_change = get_next_seeds_status_change_time
      save_global_quest_var("SeedNextStatusChange", @seeds_next_status_change.to_s)
      REGION_DATA.size.times do |i|
        REGION_DATA[i].active_buff = ZONE_BUFFS_LIST[buffs_now][i]

        REGION_DATA[i].af_npcs.each do |af|
          af = af.not_nil!
          af.display_effect = REGION_DATA[i].active_buff
        end

        zone = ZoneManager.get_zone_by_id!(REGION_DATA[i].buff_zone, L2EffectZone)
        zone.clear_skills
        zone.add_skill(ZONE_BUFFS[REGION_DATA[i].active_buff], 1)
      end
      start_quest_timer("ChangeSeedsStatus", @seeds_next_status_change - Time.ms, nil, nil)
    elsif event.casecmp?("transform")
      return unless pc && npc
      if pc.affected_by_skill?(SOUL_WEAKNESS.skill_id)
        npc.show_chat_window(pc, 2)
      else
        npc.target = pc
        npc.do_cast(SOUL_WEAKNESS)
        npc.do_cast(TREYKAN_TRANSFORMATION)
        npc.show_chat_window(pc, 1)
      end
    end

    nil
  end

  def on_enter_zone(character, zone)
    if tmp = TELEPORT_ZONES[zone.id]?
      character.tele_to_location(tmp, false)
    end

    super
  end

  private class SeedRegion
    property elite_mob_ids : Array(Int32)
    property minion_lists : Array(Array(Int32))
    property buff_zone : Int32
    property af_spawns : Array(Array(Int32))
    property af_npcs : Array(L2Npc?) = Array(L2Npc?).new(2, nil)
    property active_buff : Int32 = 0

    initializer elite_mob_ids : Array(Int32),
      minion_lists : Array(Array(Int32)), buff_zone : Int32,
      af_spawns : Array(Array(Int32))
  end
end
