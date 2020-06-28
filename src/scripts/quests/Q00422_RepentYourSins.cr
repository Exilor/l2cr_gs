class Scripts::Q00422_RepentYourSins < Quest
  # NPCs
  private BLACKSMITH_PUSHKIN = 30300
  private PIOTUR = 30597
  private ELDER_CASIAN = 30612
  private KATARI = 30668
  private MAGISTER_JOAN = 30718
  private BLACK_JUDGE = 30981
  # Items
  private RATMAN_SCAVENGERS_SKULL = 4326
  private TUREK_WAR_HOUNDS_TAIL = 4327
  private TYRANT_KINGPINS_HEART = 4328
  private TRISALIM_TARANTULAS_VENOM_SAC = 4329
  private PENITENTS_MANACLES1 = 4330
  private MANUAL_OF_MANACLES = 4331
  private PENITENTS_MANACLES = 4425
  # Reward
  private MANACLES_OF_PENITENT = 4426
  # Materials
  private SILVER_NUGGET = 1873
  private ADAMANTITE_NUGGET = 1877
  private COKES = 1879
  private STEEL = 1880
  private BLACKSMITHS_FRAME = 1892
  # Monster
  private SCAVENGER_WERERAT = 20039
  private TYRANT_KINGPIN = 20193
  private TUREK_WAR_HOUND = 20494
  private TRISALIM_TARANTULA = 20561

  def initialize
    super(422, self.class.simple_name, "Repent Your Sins")

    add_start_npc(BLACK_JUDGE)
    add_talk_id(
      BLACK_JUDGE, BLACKSMITH_PUSHKIN, PIOTUR, ELDER_CASIAN, KATARI,
      MAGISTER_JOAN
    )
    add_kill_id(
      SCAVENGER_WERERAT, TYRANT_KINGPIN, TUREK_WAR_HOUND, TRISALIM_TARANTULA
    )
    register_quest_items(
      RATMAN_SCAVENGERS_SKULL, TUREK_WAR_HOUNDS_TAIL, TYRANT_KINGPINS_HEART,
      TRISALIM_TARANTULAS_VENOM_SAC, PENITENTS_MANACLES1, MANUAL_OF_MANACLES,
      PENITENTS_MANACLES
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "ACCEPT"
      qs.start_quest
      if pc.level > 20 && pc.level < 31
        play_sound(pc, Sound::ITEMSOUND_QUEST_ACCEPT)
        qs.memo_state = 2
        qs.set_cond(3)
        html = "30981-04.htm"
      elsif pc.level < 21
        qs.memo_state = 1
        qs.set_memo_state_ex(1, 0)
        qs.set_cond(2)
        html = "30981-03.htm"
      elsif pc.level > 30 && pc.level < 41
        qs.memo_state = 3
        qs.set_cond(4)
        html = "30981-05.htm"
      else
        qs.memo_state = 4
        qs.set_cond(5)
        html = "30981-06.htm"
      end
    when "30981-11.html"
      if qs.memo_state >= 9 && qs.memo_state <= 12
        if has_at_least_one_quest_item?(pc, MANACLES_OF_PENITENT, PENITENTS_MANACLES1)
          if has_quest_items?(pc, PENITENTS_MANACLES1)
            take_items(pc, PENITENTS_MANACLES1, 1)
          end

          if has_quest_items?(pc, MANACLES_OF_PENITENT)
            take_items(pc, MANACLES_OF_PENITENT, 1)
          end
          qs.set_memo_state_ex(1, pc.level)
          give_items(pc, PENITENTS_MANACLES, 1)
          qs.set_cond(16)
          html = event
        end
      end
    when "30981-14.html", "30981-17.html"
      if qs.memo_state >= 9 && qs.memo_state <= 12
        html = event
      end
    when "30981-15t.html"
      pet_item = pc.inventory.get_item_by_item_id(PENITENTS_MANACLES)
      pet_level = pet_item ? pet_item.enchant_level : 0
      if qs.memo_state >= 9 && qs.memo_state <= 12 && pet_level > qs.get_memo_state_ex(1)
        if pc.summon
          html = event
        else
          i1 = 0
          if pc.level > qs.get_memo_state_ex(1)
            i1 = pet_level - qs.get_memo_state_ex(1) - pc.level - qs.get_memo_state_ex(1)
          else
            i1 = pet_level - qs.get_memo_state_ex(1)
          end

          if i1 < 0
            i1 = 0
          end

          i0 = Rnd.rand(i1) + 1
          if pc.pk_kills <= i0
            give_items(pc, MANACLES_OF_PENITENT, 1)
            if pet_item
              take_items(pc, PENITENTS_MANACLES, -1)
            end
            html = "30981-15.html"

            pc.pk_kills = 0
            qs.exit_quest(true, true)
          else
            give_items(pc, MANACLES_OF_PENITENT, 1)
            if pet_item
              take_items(pc, PENITENTS_MANACLES, -1)
            end
            html = "30981-16.html"

            pc.pk_kills = pc.pk_kills - i0
            qs.set_memo_state_ex(1, 0)
          end
        end
      end
    when "30981-18.html"
      if qs.memo_state >= 9 && qs.memo_state <= 12
        qs.exit_quest(true, true)
        html = event
      end
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when SCAVENGER_WERERAT
        if qs.memo_state?(5) && get_quest_items_count(killer, RATMAN_SCAVENGERS_SKULL) < 10
          if get_quest_items_count(killer, RATMAN_SCAVENGERS_SKULL) == 9
            give_items(killer, RATMAN_SCAVENGERS_SKULL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            give_items(killer, RATMAN_SCAVENGERS_SKULL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when TYRANT_KINGPIN
        if qs.memo_state?(7) && !has_quest_items?(killer, TYRANT_KINGPINS_HEART)
          give_items(killer, TYRANT_KINGPINS_HEART, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
        end
      when TUREK_WAR_HOUND
        if qs.memo_state?(6) && get_quest_items_count(killer, TUREK_WAR_HOUNDS_TAIL) < 10
          if get_quest_items_count(killer, TUREK_WAR_HOUNDS_TAIL) == 9
            give_items(killer, TUREK_WAR_HOUNDS_TAIL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            give_items(killer, TUREK_WAR_HOUNDS_TAIL, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when TRISALIM_TARANTULA
        if qs.memo_state?(8) && get_quest_items_count(killer, TRISALIM_TARANTULAS_VENOM_SAC) < 3
          if get_quest_items_count(killer, TRISALIM_TARANTULAS_VENOM_SAC) == 2
            give_items(killer, TRISALIM_TARANTULAS_VENOM_SAC, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            give_items(killer, TRISALIM_TARANTULAS_VENOM_SAC, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == BLACK_JUDGE
        if pc.pk_kills == 0
          html = "30981-01.htm"
        else
          html = "30981-02.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when BLACK_JUDGE
        if memo_state == 1000
          take_items(pc, PENITENTS_MANACLES, 1)
        elsif memo_state < 9
          html = "30981-07.html"
        elsif memo_state >= 9 && memo_state <= 12
          if !has_at_least_one_quest_item?(pc, MANUAL_OF_MANACLES, MANACLES_OF_PENITENT, PENITENTS_MANACLES1, PENITENTS_MANACLES)
            give_items(pc, MANUAL_OF_MANACLES, 1)
            qs.set_cond(14, true)
            html = "30981-08.html"
          elsif has_quest_items?(pc, MANUAL_OF_MANACLES) && !has_at_least_one_quest_item?(pc, MANACLES_OF_PENITENT, PENITENTS_MANACLES1, PENITENTS_MANACLES)
            html = "30981-09.html"
          elsif has_quest_items?(pc, PENITENTS_MANACLES1) && !has_at_least_one_quest_item?(pc, MANUAL_OF_MANACLES, MANACLES_OF_PENITENT, PENITENTS_MANACLES)
            html = "30981-10.html"
          elsif has_quest_items?(pc, PENITENTS_MANACLES)
            pet_item = pc.inventory.get_item_by_item_id(PENITENTS_MANACLES)
            pet_level = pet_item ? pet_item.enchant_level : 0
            if pet_level < qs.get_memo_state_ex(1) + 1
              html = "30981-12.html"
            else
              html = "30981-13.html"
            end
          elsif has_quest_items?(pc, MANACLES_OF_PENITENT) && !has_quest_items?(pc, PENITENTS_MANACLES)
            html = "30981-16t.html"
          end
        end
      when BLACKSMITH_PUSHKIN
        if memo_state >= 9 && memo_state <= 12
          if !has_at_least_one_quest_item?(pc, PENITENTS_MANACLES1, PENITENTS_MANACLES, MANACLES_OF_PENITENT) && has_quest_items?(pc, MANUAL_OF_MANACLES)
            if get_quest_items_count(pc, BLACKSMITHS_FRAME) > 0 && get_quest_items_count(pc, STEEL) >= 5 && get_quest_items_count(pc, ADAMANTITE_NUGGET) >= 2 && get_quest_items_count(pc, SILVER_NUGGET) >= 10 && get_quest_items_count(pc, COKES) >= 10
              take_items(pc, SILVER_NUGGET, 10)
              take_items(pc, ADAMANTITE_NUGGET, 2)
              take_items(pc, COKES, 10)
              take_items(pc, STEEL, 5)
              take_items(pc, BLACKSMITHS_FRAME, 1)
              give_items(pc, PENITENTS_MANACLES1, 1)
              take_items(pc, MANUAL_OF_MANACLES, 1)
              qs.set_cond(15, true)
              html = "30300-01.html"
            else
              html = "30300-02.html"
            end
          elsif has_at_least_one_quest_item?(pc, PENITENTS_MANACLES1, PENITENTS_MANACLES, MANACLES_OF_PENITENT)
            html = "30300-03.html"
          end
        end
      when PIOTUR
        if memo_state == 2
          qs.memo_state = 6
          qs.set_cond(7, true)
          html = "30597-01.html"
        elsif memo_state == 6
          if get_quest_items_count(pc, TUREK_WAR_HOUNDS_TAIL) < 10
            html = "30597-02.html"
          else
            take_items(pc, TUREK_WAR_HOUNDS_TAIL, -1)
            qs.memo_state = 10
            qs.set_cond(11, true)
            html = "30597-03.html"
          end
        elsif memo_state == 10
          html = "30597-04.html"
        end
      when ELDER_CASIAN
        if memo_state == 3
          qs.memo_state = 7
          qs.set_cond(8, true)
          html = "30612-01.html"
        elsif memo_state == 7
          if !has_quest_items?(pc, TYRANT_KINGPINS_HEART)
            html = "30612-02.html"
          else
            take_items(pc, TYRANT_KINGPINS_HEART, -1)
            qs.memo_state = 11
            qs.set_cond(12, true)
            html = "30612-03.html"
          end
        elsif memo_state == 11
          html = "30612-04.html"
        end
      when KATARI
        if memo_state == 1
          qs.memo_state = 5
          qs.set_cond(6, true)
          html = "30668-01.html"
        elsif memo_state == 5
          if get_quest_items_count(pc, RATMAN_SCAVENGERS_SKULL) < 10
            html = "30668-02.html"
          else
            take_items(pc, RATMAN_SCAVENGERS_SKULL, -1)
            qs.memo_state = 9
            qs.set_cond(10, true)
            html = "30668-03.html"
          end
        elsif memo_state == 9
          html = "30668-04.html"
        end
      when MAGISTER_JOAN
        if memo_state == 4
          qs.memo_state = 8
          qs.set_cond(9, true)
          html = "30718-01.html"
        elsif memo_state == 8
          if get_quest_items_count(pc, TRISALIM_TARANTULAS_VENOM_SAC) < 3
            html = "30718-02.html"
          else
            take_items(pc, TRISALIM_TARANTULAS_VENOM_SAC, -1)
            qs.memo_state = 12
            qs.set_cond(13, true)
            html = "30718-03.html"
          end
        elsif memo_state == 12
          html = "30718-04.html"
        end
      end

    end

    html || get_no_quest_msg(pc)
  end
end
