class Scripts::Q00619_RelicsOfTheOldEmpire < Quest
  private record DropInfo, drop_chance : Float64, double_item_chance : Int32,
    drop_entrance_pass : Bool

  # NPC
  private GHOST_OF_ADVENTURER = 31538
  # Items
  private ENTRANCE_PASS_TO_THE_SEPULCHER = 7075
  private BROKEN_RELIC_PART = 7254
  # Misc
  private MIN_LEVEL = 74
  private REQUIRED_RELIC_COUNT = 1000
  # Reward
  private RECIPES = {
    6881, # Recipe: Forgotten Blade (60%)
    6883, # Recipe: Basalt Battlehammer (60%)
    6885, # Recipe: Imperial Staff (60%)
    6887, # Recipe: Angel Slayer (60%)
    6891, # Recipe: Dragon Hunter Axe (60%)
    6893, # Recipe: Saint Spear (60%)
    6895, # Recipe: Demon Splinter (60%)
    6897, # Recipe: Heavens Divider (60%)
    6899, # Recipe: Arcana Mace (60%)
    7580  # Recipe: Draconic Bow (60%)
  }
  # Mobs
  private MOBS = {
    21396 => DropInfo.new(0.51, 0, true), # carrion_scarab
    21397 => DropInfo.new(0.50, 0, true), # carrion_scarab_a
    21398 => DropInfo.new(0.95, 0, true), # soldier_scarab
    21399 => DropInfo.new(0.84, 0, true), # soldier_scarab_a
    21400 => DropInfo.new(0.76, 0, true), # hexa_beetle
    21401 => DropInfo.new(0.67, 0, true), # hexa_beetle_a
    21402 => DropInfo.new(0.69, 0, true), # katraxith
    21403 => DropInfo.new(0.80, 0, true), # katraxith_a
    21404 => DropInfo.new(0.90, 0, true), # tera_beetle
    21405 => DropInfo.new(0.64, 0, true), # tera_beetle_a
    21406 => DropInfo.new(0.87, 0, true), # imperial_knight
    21407 => DropInfo.new(0.56, 0, true), # imperial_knight_a
    21408 => DropInfo.new(0.82, 0, true), # imperial_guard
    21409 => DropInfo.new(0.92, 0, true), # imperial_guard_a
    21410 => DropInfo.new(0.81, 0, true), # guardian_scarab
    21411 => DropInfo.new(0.66, 0, true), # guardian_scarab_a
    21412 => DropInfo.new(1.00, 6, true), # ustralith
    21413 => DropInfo.new(0.81, 0, true), # ustralith_a
    21414 => DropInfo.new(0.79, 0, true), # imperial_assassin
    21415 => DropInfo.new(0.80, 0, true), # imperial_assassin_a
    21416 => DropInfo.new(0.82, 0, true), # imperial_warlord
    21417 => DropInfo.new(1.00, 27, true), # imperial_warlord_a
    21418 => DropInfo.new(0.66, 0, true), # imperial_highguard
    21419 => DropInfo.new(0.67, 0, true), # imperial_highguard_a
    21420 => DropInfo.new(0.82, 0, true), # ashuras
    21421 => DropInfo.new(0.77, 0, true), # ashuras_a
    21422 => DropInfo.new(0.88, 0, true), # imperial_dancer
    21423 => DropInfo.new(0.94, 0, true), # imperial_dancer_a
    21424 => DropInfo.new(1.00, 19, true), # ashikenas
    21425 => DropInfo.new(1.00, 21, true), # ashikenas_a
    21426 => DropInfo.new(1.00, 8, true), # abraxian
    21427 => DropInfo.new(0.74, 0, true), # abraxian_a
    21428 => DropInfo.new(0.76, 0, true), # hasturan
    21429 => DropInfo.new(0.80, 0, true), # hasturan_a
    21430 => DropInfo.new(1.00, 10, true), # ahrimanes
    21431 => DropInfo.new(0.94, 0, true), # ahrimanes_a
    21432 => DropInfo.new(1.00, 34, true), # chakram_beetle
    21433 => DropInfo.new(1.00, 34, true), # jamadhr_beetle
    21434 => DropInfo.new(1.00, 90, true), # priest_of_blood
    21435 => DropInfo.new(1.00, 60, true), # sacrifice_guide
    21436 => DropInfo.new(1.00, 66, true), # sacrifice_bearer
    21437 => DropInfo.new(0.69, 0, true), # sacrifice_scarab
    21798 => DropInfo.new(0.33, 0, true), # guard_skeleton_2d
    21799 => DropInfo.new(0.61, 0, true), # guard_skeleton_3d
    21800 => DropInfo.new(0.31, 0, true), # guard_undead
    18120 => DropInfo.new(1.00, 28, false), # r11_roomboss_strong
    18121 => DropInfo.new(1.00, 21, false), # r11_roomboss_weak
    18122 => DropInfo.new(0.93, 0, false), # r11_roomboss_teleport
    18123 => DropInfo.new(1.00, 28, false), # r12_roomboss_strong
    18124 => DropInfo.new(1.00, 21, false), # r12_roomboss_weak
    18125 => DropInfo.new(0.93, 0, false), # r12_roomboss_teleport
    18126 => DropInfo.new(1.00, 28, false), # r13_roomboss_strong
    18127 => DropInfo.new(1.00, 21, false), # r13_roomboss_weak
    18128 => DropInfo.new(0.93, 0, false), # r13_roomboss_teleport
    18129 => DropInfo.new(1.00, 28, false), # r14_roomboss_strong
    18130 => DropInfo.new(1.00, 21, false), # r14_roomboss_weak
    18131 => DropInfo.new(0.93, 0, false), # r14_roomboss_teleport
    18132 => DropInfo.new(1.00, 30, false), # r1_beatle_healer
    18133 => DropInfo.new(1.00, 20, false), # r1_scorpion_warrior
    18134 => DropInfo.new(0.90, 0, false), # r1_warrior_longatk1_h
    18135 => DropInfo.new(1.00, 20, false), # r1_warrior_longatk2
    18136 => DropInfo.new(1.00, 20, false), # r1_warrior_selfbuff
    18137 => DropInfo.new(0.89, 0, false), # r1_wizard_h
    18138 => DropInfo.new(1.00, 19, false), # r1_wizard_clanbuff
    18139 => DropInfo.new(1.00, 17, false), # r1_wizard_debuff
    18140 => DropInfo.new(1.00, 19, false), # r1_wizard_selfbuff
    18141 => DropInfo.new(0.76, 0, false), # r21_scarab_roombosss
    18142 => DropInfo.new(0.76, 0, false), # r22_scarab_roombosss
    18143 => DropInfo.new(0.76, 0, false), # r23_scarab_roombosss
    18144 => DropInfo.new(0.76, 0, false), # r24_scarab_roombosss
    18145 => DropInfo.new(0.65, 0, false), # r2_wizard_clanbuff
    18146 => DropInfo.new(0.66, 0, false), # r2_warrior_longatk2
    18147 => DropInfo.new(0.62, 0, false), # r2_wizard
    18148 => DropInfo.new(0.72, 0, false), # r2_warrior
    18149 => DropInfo.new(0.63, 0, false), # r2_bomb
    18166 => DropInfo.new(0.92, 0, false), # r3_warrior
    18167 => DropInfo.new(0.92, 0, false), # r3_warrior_longatk1_h
    18168 => DropInfo.new(0.93, 0, false), # r3_warrior_longatk2
    18169 => DropInfo.new(0.90, 0, false), # r3_warrior_selfbuff
    18170 => DropInfo.new(0.90, 0, false), # r3_wizard_h
    18171 => DropInfo.new(0.94, 0, false), # r3_wizard_clanbuff
    18172 => DropInfo.new(0.89, 0, false), # r3_wizard_selfbuff
    18173 => DropInfo.new(0.99, 0, false), # r41_roomboss_strong
    18174 => DropInfo.new(1.00, 22, false), # r41_roomboss_weak
    18175 => DropInfo.new(0.93, 0, false), # r41_roomboss_teleport
    18176 => DropInfo.new(0.99, 0, false), # r42_roomboss_strong
    18177 => DropInfo.new(1.00, 22, false), # r42_roomboss_weak
    18178 => DropInfo.new(0.93, 0, false), # r42_roomboss_teleport
    18179 => DropInfo.new(0.99, 0, false), # r43_roomboss_strong
    18180 => DropInfo.new(1.00, 22, false), # r43_roomboss_weak
    18181 => DropInfo.new(0.93, 0, false), # r43_roomboss_teleport
    18183 => DropInfo.new(1.00, 22, false), # r44_roomboss_weak
    18183 => DropInfo.new(0.99, 0, false), # r44_roomboss_strong
    18184 => DropInfo.new(0.93, 0, false), # r44_roomboss_teleport
    18185 => DropInfo.new(1.00, 23, false), # r4_healer_srddmagic
    18186 => DropInfo.new(1.00, 24, false), # r4_hearler_srdebuff
    18187 => DropInfo.new(1.00, 20, false), # r4_warrior
    18188 => DropInfo.new(0.90, 0, false), # r4_warrior_longatk1_h
    18189 => DropInfo.new(1.00, 20, false), # r4_warrior_longatk2
    18190 => DropInfo.new(1.00, 20, false), # r4_warrior_selfbuff
    18191 => DropInfo.new(0.89, 0, false), # r4_wizard_h
    18192 => DropInfo.new(1.00, 19, false), # r4_wizard_clanbuff
    18193 => DropInfo.new(1.00, 17, false), # r4_wizard_debuff
    18194 => DropInfo.new(1.00, 19, false), # r4_wizard_selfbuff
    18195 => DropInfo.new(0.91, 0, false), # r4_bomb
    18220 => DropInfo.new(1.00, 24, false), # r5_healer1
    18221 => DropInfo.new(1.00, 27, false), # r5_healer2
    18222 => DropInfo.new(1.00, 21, false), # r5_warrior
    18223 => DropInfo.new(0.90, 0, false), # r5_warrior_longatk1_h
    18224 => DropInfo.new(1.00, 22, false), # r5_warrior_longatk2
    18225 => DropInfo.new(1.00, 21, false), # r5_warrior_sbuff
    18226 => DropInfo.new(0.89, 0, false), # r5_wizard_h
    18227 => DropInfo.new(1.00, 53, false), # r5_wizard_clanbuff
    18228 => DropInfo.new(1.00, 15, false), # r5_wizard_debuff
    18229 => DropInfo.new(1.00, 19, false), # r5_wizard_slefbuff
    18230 => DropInfo.new(0.49, 0, false)  # r5_bomb
  }

  private ARCHON_OF_HALISHA = {
    18212, 18213, 18214, 18215, 18216, 18217, 18218, 18219
  }

  def initialize
    super(619, self.class.simple_name, "Relics of the Old Empire")

    add_start_npc(GHOST_OF_ADVENTURER)
    add_talk_id(GHOST_OF_ADVENTURER)
    add_kill_id(MOBS.keys)
    add_kill_id(ARCHON_OF_HALISHA)
    register_quest_items(BROKEN_RELIC_PART)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = nil
    case event
    when "31538-02.htm"
      st.start_quest
      html = event
    when "31538-05.html"
      html = event
    when "31538-06.html"
      if st.get_quest_items_count(BROKEN_RELIC_PART) >= REQUIRED_RELIC_COUNT
        st.reward_items(RECIPES.sample(random: Rnd), 1)
        st.take_items(BROKEN_RELIC_PART, REQUIRED_RELIC_COUNT)
        html = event
      end
    when "31538-08.html"
      st.exit_quest(true, true)
      html = event
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if st = get_random_party_member_state(pc, -1, 3, npc)
      npc_id = npc.id
      if ARCHON_OF_HALISHA.includes?(npc_id)
        item_count = Rnd.rand(100) < 79 ? 4 : 3
        st.give_item_randomly(npc, BROKEN_RELIC_PART, item_count, 0, 1.0, true)
      else
        info = MOBS[npc_id]

        if info.double_item_chance > 0
          item_count = Rnd.rand(100) < info.double_item_chance ? 2 : 1
        else
          item_count = 1
        end

        st.give_item_randomly(npc, BROKEN_RELIC_PART, item_count, 0, info.drop_chance, true)

        if info.drop_entrance_pass
          st.give_item_randomly(npc, ENTRANCE_PASS_TO_THE_SEPULCHER, 1, 0, 1.0 / 30, false)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if st.created?
      html = pc.level >= MIN_LEVEL ? "31538-01.htm" : "31538-03.html"
    elsif st.started?
      if get_quest_items_count(pc, BROKEN_RELIC_PART) >= REQUIRED_RELIC_COUNT
        html = "31538-04.html"
      else
        html = "31538-07.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
