class Quests::Q00111_ElrokianHuntersProof < Quest
  # NPCs
  private MARQUEZ = 32113
  private MUSHIKA = 32114
  private ASAMAH = 32115
  private KIRIKACHIN = 32116
  # Items
  private ELROKIAN_TRAP = 8763
  private TRAP_STONE = 8764
  private DIARY_FRAGMENT = 8768
  private EXPEDITION_MEMBERS_LETTER = 8769
  private ORNITHOMINUS_CLAW = 8770
  private DEINONYCHUS_BONE = 8771
  private PACHYCEPHALOSAURUS_SKIN = 8772
  private PRACTICE_ELROKIAN_TRAP = 8773
  # Misc
  private MIN_LEVEL = 75
  # Mobs
  private MOBS_DROP_CHANCES = {
    22196 => ItemChanceHolder.new(DIARY_FRAGMENT, 0.51, 4), # velociraptor_leader
    22197 => ItemChanceHolder.new(DIARY_FRAGMENT, 0.51, 4), # velociraptor
    22198 => ItemChanceHolder.new(DIARY_FRAGMENT, 0.51, 4), # velociraptor_s
    22218 => ItemChanceHolder.new(DIARY_FRAGMENT, 0.25, 4), # velociraptor_n
    22223 => ItemChanceHolder.new(DIARY_FRAGMENT, 0.26, 4), # velociraptor_leader2
    22200 => ItemChanceHolder.new(ORNITHOMINUS_CLAW, 0.66, 11), # ornithomimus_leader
    22201 => ItemChanceHolder.new(ORNITHOMINUS_CLAW, 0.33, 11), # ornithomimus
    22202 => ItemChanceHolder.new(ORNITHOMINUS_CLAW, 0.66, 11), # ornithomimus_s
    22219 => ItemChanceHolder.new(ORNITHOMINUS_CLAW, 0.33, 11), # ornithomimus_n
    22224 => ItemChanceHolder.new(ORNITHOMINUS_CLAW, 0.33, 11), # ornithomimus_leader2
    22203 => ItemChanceHolder.new(DEINONYCHUS_BONE, 0.65, 11), # deinonychus_leader
    22204 => ItemChanceHolder.new(DEINONYCHUS_BONE, 0.32, 11), # deinonychus
    22205 => ItemChanceHolder.new(DEINONYCHUS_BONE, 0.66, 11), # deinonychus_s
    22220 => ItemChanceHolder.new(DEINONYCHUS_BONE, 0.32, 11), # deinonychus_n
    22225 => ItemChanceHolder.new(DEINONYCHUS_BONE, 0.32, 11), # deinonychus_leader2
    22208 => ItemChanceHolder.new(PACHYCEPHALOSAURUS_SKIN, 0.50, 11), # pachycephalosaurus_ldr
    22209 => ItemChanceHolder.new(PACHYCEPHALOSAURUS_SKIN, 0.50, 11), # pachycephalosaurus
    22210 => ItemChanceHolder.new(PACHYCEPHALOSAURUS_SKIN, 0.50, 11), # pachycephalosaurus_s
    22221 => ItemChanceHolder.new(PACHYCEPHALOSAURUS_SKIN, 0.49, 11), # pachycephalosaurus_n
    22226 => ItemChanceHolder.new(PACHYCEPHALOSAURUS_SKIN, 0.50, 11)  # pachycephalosaurus_ldr2
  }

  def initialize
    super(111, self.class.simple_name, "Elrokian Hunter's Proof")

    add_start_npc(MARQUEZ)
    add_talk_id(MARQUEZ, MUSHIKA, ASAMAH, KIRIKACHIN)
    add_kill_id(MOBS_DROP_CHANCES.keys)
    register_quest_items(DIARY_FRAGMENT, EXPEDITION_MEMBERS_LETTER, ORNITHOMINUS_CLAW, DEINONYCHUS_BONE, PACHYCEPHALOSAURUS_SKIN, PRACTICE_ELROKIAN_TRAP)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless qs = get_quest_state(player, false)
      return
    end

    case event
    when "32113-02.htm", "32113-05.htm", "32113-04.html", "32113-10.html",
         "32113-11.html", "32113-12.html", "32113-13.html", "32113-14.html",
         "32113-18.html", "32113-19.html", "32113-20.html", "32113-21.html",
         "32113-22.html", "32113-23.html", "32113-24.html", "32115-08.html",
         "32116-03.html"
      htmltext = event
    when "32113-03.html"
      qs.start_quest
      qs.memo_state = 1
      htmltext = event
    when "32113-15.html"
      if qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(4, true)
        htmltext = event
      end
    when "32113-25.html"
      if qs.memo_state?(5)
        qs.memo_state = 6
        qs.set_cond(6, true)
        give_items(player, EXPEDITION_MEMBERS_LETTER, 1)
        htmltext = event
      end
    when "32115-03.html"
      if qs.memo_state?(2)
        qs.memo_state = 3
        qs.set_cond(3, true)
        htmltext = event
      end
    when "32115-06.html"
      if qs.memo_state?(9)
        qs.memo_state = 10
        qs.set_cond(9)
        play_sound(player, Sound::ETCSOUND_ELROKI_SONG_FULL)
        htmltext = event
      end
    when "32115-09.html"
      if qs.memo_state?(10)
        qs.memo_state = 11
        qs.set_cond(10, true)
        htmltext = event
      end
    when "32116-04.html"
      if qs.memo_state?(7)
        qs.memo_state = 8
        play_sound(player, Sound::ETCSOUND_ELROKI_SONG_FULL)
        htmltext = event
      end
    when "32116-07.html"
      if qs.memo_state?(8)
        qs.memo_state = 9
        qs.set_cond(8, true)
        htmltext = event
      end
    when "32116-10.html"
      if qs.memo_state?(12) && has_quest_items?(player, PRACTICE_ELROKIAN_TRAP)
        take_items(player, PRACTICE_ELROKIAN_TRAP, -1)
        give_items(player, ELROKIAN_TRAP, 1)
        give_items(player, TRAP_STONE, 100)
        give_adena(player, 1071691, true)
        add_exp_and_sp(player, 553524, 55538)
        qs.exit_quest(false, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, player, is_summon)
    if qs = get_random_party_member_state(player, -1, 3, npc)
      item = MOBS_DROP_CHANCES[npc.id]
      if item.count == qs.memo_state
        if qs.cond?(4)
          if give_item_randomly(qs.player, npc, item.id, 1, 50, item.chance, true)
            qs.set_cond(5)
          end
        elsif qs.cond?(10)
          if give_item_randomly(qs.player, npc, item.id, 1, 10, item.chance, true) &&
            get_quest_items_count(qs.player, ORNITHOMINUS_CLAW) >= 10 &&
            get_quest_items_count(qs.player, DEINONYCHUS_BONE) >= 10 &&
            get_quest_items_count(qs.player, PACHYCEPHALOSAURUS_SKIN) >= 10

            qs.set_cond(11)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)

    case qs.state
    when State::COMPLETED
      if npc.id == MARQUEZ
        htmltext = get_already_completed_msg(player)
      end
    when State::CREATED
      if npc.id == MARQUEZ
        htmltext = player.level >= MIN_LEVEL ? "32113-01.htm" : "32113-06.html"
      end
    when State::STARTED
      case npc.id
      when MARQUEZ
        case qs.memo_state
        when 1
          htmltext = "32113-07.html"
        when 2
          htmltext = "32113-08.html"
        when 3
          htmltext = "32113-09.html"
        when 4
          if get_quest_items_count(player, DIARY_FRAGMENT) < 50
            htmltext = "32113-16.html"
          else
            take_items(player, DIARY_FRAGMENT, -1)
            qs.memo_state = 5
            htmltext = "32113-17.html"
          end
        when 5
          htmltext = "32113-26.html"
        when 6
          htmltext = "32113-27.html"
        when 7, 8
          htmltext = "32113-28.html"
        when 9
          htmltext = "32113-29.html"
        when 10..12
          htmltext = "32113-30.html"
        end
      when MUSHIKA
        if qs.memo_state?(1)
          qs.set_cond(2, true)
          qs.memo_state = 2
          htmltext = "32114-01.html"
        elsif qs.memo_state > 1 && qs.memo_state < 10
          htmltext = "32114-02.html"
        else
          htmltext = "32114-03.html"
        end
      when ASAMAH
        case qs.memo_state
        when 1
          htmltext = "32115-01.html"
        when 2
          htmltext = "32115-02.html"
        when 3..8
          htmltext = "32115-04.html"
        when 9
          htmltext = "32115-05.html"
        when 10
          htmltext = "32115-07.html"
        when 11
          if get_quest_items_count(player, ORNITHOMINUS_CLAW) < 10 || get_quest_items_count(player, DEINONYCHUS_BONE) < 10 || get_quest_items_count(player, PACHYCEPHALOSAURUS_SKIN) < 10
            htmltext = "32115-10.html"
          else
            qs.memo_state = 12
            qs.set_cond(12, true)
            give_items(player, PRACTICE_ELROKIAN_TRAP, 1)
            take_items(player, ORNITHOMINUS_CLAW, -1)
            take_items(player, DEINONYCHUS_BONE, -1)
            take_items(player, PACHYCEPHALOSAURUS_SKIN, -1)
            htmltext = "32115-11.html"
          end
        when 12
          htmltext = "32115-12.html"
        end
      when KIRIKACHIN
        case qs.memo_state
        when 1..5
          htmltext = "32116-01.html"
        when 6
          if has_quest_items?(player, EXPEDITION_MEMBERS_LETTER)
            qs.memo_state = 7
            qs.set_cond(7, true)
            take_items(player, EXPEDITION_MEMBERS_LETTER, -1)
            htmltext = "32116-02.html"
          end
        when 7
          htmltext = "32116-05.html"
        when 8
          htmltext = "32116-06.html"
        when 9..11
          htmltext = "32116-08.html"
        when 12
          htmltext = "32116-09.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
