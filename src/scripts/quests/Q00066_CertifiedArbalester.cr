class Scripts::Q00066_CertifiedArbalester < Quest
  # NPCs
  private WAREHOUSE_KEEPER_HOLVAS = 30058
  private MAGISTER_GAIUS = 30171
  private BLACKSMITH_POITAN = 30458
  private MAGISTER_CLAYTON = 30464
  private MAGISTER_GAUEN = 30717
  private MAGISTER_KAIENA = 30720
  private MASTER_RINDY = 32201
  private GRAND_MASTER_MELDINA = 32214
  private MASTER_SELSIA = 32220
  # Items
  private ENMITY_CRYSTAL = 9773
  private ENMITY_CRYSTAL_CORE = 9774
  private MANUSCRIPT_PAGE = 9775
  private ENCODED_PAGE_ON_THE_ANCIENT_RACE = 9776
  private KAMAEL_INQUISITOR_TRAINEE_MARK = 9777
  private FRAGMENT_OF_ATTACK_ORDERS = 9778
  private GRANDIS_ATTACK_ORDERS = 9779
  private MANASHENS_TALISMAN = 9780
  private RESEARCH_ON_THE_GIANTS_AND_THE_ANCIENT_RACE = 9781
  # Reward
  private DIMENSIONAL_DIAMOND = 7562
  private KAMAEL_INQUISITOR_MARK = 9782
  # Monster
  private GRANITIC_GOLEM = 20083
  private HANGMAN_TREE = 20144
  private AMBER_BASILISK = 20199
  private STRAIN = 20200
  private GHOUL = 20201
  private DEAD_SEEKER = 20202
  private GRANDIS = 20554
  private MANASHEN_GARGOYLE = 20563
  private TIMAK_ORC = 20583
  private TIMAK_ORC_ARCHER = 20584
  private DELU_LIZARDMAN_SHAMAN = 20781
  private WATCHMAN_OF_THE_PLAINS = 21102
  private ROUGHLY_HEWN_ROCK_GOLEM = 21103
  private DELU_LIZARDMAN_SUPPLIER = 21104
  private DELU_LIZARDMAN_AGENT = 21105
  private CURSED_SEER = 21106
  private DELU_LIZARDMAN_COMMANDER = 21107
  # Quest Monster
  private CRIMSON_LADY = 27336
  # Misc
  private MIN_LEVEL = 39

  def initialize
    super(66, self.class.simple_name, "Certified Arbalester")

    add_start_npc(MASTER_RINDY)
    add_talk_id(
      MASTER_RINDY, WAREHOUSE_KEEPER_HOLVAS, MAGISTER_GAIUS, BLACKSMITH_POITAN,
      MAGISTER_CLAYTON, MAGISTER_GAUEN, MAGISTER_KAIENA, GRAND_MASTER_MELDINA,
      MASTER_SELSIA
    )
    add_kill_id(
      GRANITIC_GOLEM, HANGMAN_TREE, AMBER_BASILISK, STRAIN, GHOUL, DEAD_SEEKER,
      GRANDIS, MANASHEN_GARGOYLE, TIMAK_ORC, TIMAK_ORC_ARCHER,
      DELU_LIZARDMAN_SHAMAN, WATCHMAN_OF_THE_PLAINS, ROUGHLY_HEWN_ROCK_GOLEM,
      DELU_LIZARDMAN_SUPPLIER, DELU_LIZARDMAN_AGENT, CURSED_SEER,
      DELU_LIZARDMAN_COMMANDER, CRIMSON_LADY
    )
    register_quest_items(
      ENMITY_CRYSTAL, ENMITY_CRYSTAL_CORE, MANUSCRIPT_PAGE,
      ENCODED_PAGE_ON_THE_ANCIENT_RACE, KAMAEL_INQUISITOR_TRAINEE_MARK,
      FRAGMENT_OF_ATTACK_ORDERS, GRANDIS_ATTACK_ORDERS, MANASHENS_TALISMAN,
      RESEARCH_ON_THE_GIANTS_AND_THE_ANCIENT_RACE
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if pc.level >= MIN_LEVEL && pc.class_id.warder? && !has_quest_items?(pc, KAMAEL_INQUISITOR_MARK)
        qs.start_quest
        qs.memo_state = 1
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 64)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "32201-07a.htm"
        else
          html = "32201-07.htm"
        end
      end
    when "32201-08.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = event
      end
    when "30058-03.html", "30058-04.html"
      if qs.memo_state?(7)
        html = event
      end
    when "30058-05.html"
      if qs.memo_state?(7)
        qs.memo_state = 8
        qs.set_cond(7, true)
        html = event
      end
    when "30058-08.html"
      if qs.memo_state?(9)
        give_items(pc, ENCODED_PAGE_ON_THE_ANCIENT_RACE, 1)
        qs.memo_state = 10
        qs.set_cond(9, true)
        html = event
      end
    when "30171-03.html"
      if qs.memo_state?(23)
        html = event
      end
    when "30171-05.html"
      if qs.memo_state?(23)
        take_items(pc, GRANDIS_ATTACK_ORDERS, -1)
        qs.memo_state = 24
        html = event
      end
    when "30171-06.html", "30171-07.html"
      if qs.memo_state?(24)
        html = event
      end
    when "30171-08.html"
      if qs.memo_state?(24)
        qs.memo_state = 25
      end
      qs.set_cond(14, true)
      html = event
    when "30458-03.html"
      if qs.memo_state?(5)
        take_items(pc, ENMITY_CRYSTAL_CORE, 1)
        qs.memo_state = 6
        html = event
      end
    when "30458-05.html", "30458-06.html", "30458-07.html", "30458-08.html"
      if qs.memo_state?(6)
        html = event
      end
    when "30458-09.html"
      if qs.memo_state?(6)
        qs.memo_state = 7
        qs.set_cond(6, true)
        html = event
      end
    when "30464-03.html", "30464-04.html", "30464-05.html"
      if qs.memo_state?(2)
        html = event
      end
    when "30464-06.html"
      if qs.memo_state?(2)
        qs.memo_state = 3
        qs.set_cond(3, true)
        html = event
      end
    when "30464-09.html"
      if qs.memo_state?(4)
        give_items(pc, ENMITY_CRYSTAL_CORE, 1)
        qs.memo_state = 5
        qs.set_cond(5, true)
        html = event
      end
    when "30464-11.html"
      html = event
    when "30717-03.html", "30717-05.html", "30717-06.html", "30717-07.html",
         "30717-08.html"
      if qs.memo_state?(28)
        html = event
      end
    when "30717-09.html"
      if qs.memo_state?(28)
        qs.memo_state = 29
        qs.set_cond(17, true)
        html = event
      end
    when "30720-03.html"
      if qs.memo_state?(29)
        html = event
      end
    when "30720-04.html"
      if qs.memo_state?(29)
        qs.memo_state = 30
        qs.set_cond(18, true)
        html = event
      end
    when "32214-03.html"
      if qs.memo_state?(10)
        html = event
      end
    when "32214-04.html"
      if qs.memo_state?(10)
        take_items(pc, ENCODED_PAGE_ON_THE_ANCIENT_RACE, 1)
        give_items(pc, KAMAEL_INQUISITOR_TRAINEE_MARK, 1)
        qs.memo_state = 11
        qs.set_cond(10, true)
        html = event
      end
    when "32220-03.html"
      if qs.memo_state?(11)
        take_items(pc, KAMAEL_INQUISITOR_TRAINEE_MARK, -1)
        qs.memo_state = 12
        html = event
      end
    when "32220-05.html"
      if qs.memo_state?(12)
        qs.memo_state = 13
        html = event
      end
    when "32220-06.html"
      if qs.memo_state?(13)
        qs.set_memo_state_ex(1, 0)
        html = event
      end
    when "32220-09.html", "32220-10.html"
      if qs.memo_state?(13)
        html = event
      end
    when "32220-11.html", "32220-12.html", "32220-13.html"
      if qs.memo_state?(13)
        qs.memo_state = 13
        qs.set_memo_state_ex(1, 1)
        html = event
      end
    when "32220-13a.html"
      if qs.memo_state?(13)
        qs.memo_state = 20
        qs.set_memo_state_ex(1, 0)
        html = event
      end
    when "32220-13b.html"
      if qs.memo_state?(20)
        qs.memo_state = 21
        qs.set_cond(11, true)
        html = event
      end
    when "32220-19.html", "32220-21.html", "32220-22.html", "32220-23.html",
         "32220-24.html", "32220-25.html"
      if qs.memo_state?(31)
        html = event
      end
    when "32220-26.html"
      if qs.memo_state?(31)
        qs.set_memo_state_ex(1, 0)
        qs.memo_state = 32
        qs.set_cond(19, true)
        html = event
      end
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when GRANITIC_GOLEM, HANGMAN_TREE
        if qs.memo_state?(8) && get_quest_items_count(killer, MANUSCRIPT_PAGE) < 30
          if get_quest_items_count(killer, MANUSCRIPT_PAGE) >= 29
            qs.set_cond(8, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
          give_items(killer, MANUSCRIPT_PAGE, 1)
          if Rnd.rand(1000) < 100 && get_quest_items_count(killer, MANUSCRIPT_PAGE) < 29
            give_items(killer, MANUSCRIPT_PAGE, 1)
          end
        end
      when AMBER_BASILISK
        if qs.memo_state?(8) && get_quest_items_count(killer, MANUSCRIPT_PAGE) < 30
          if Rnd.rand(1000) < 980
            if get_quest_items_count(killer, MANUSCRIPT_PAGE) >= 29
              qs.set_cond(8, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
            give_items(killer, MANUSCRIPT_PAGE, 1)
          end
        end
      when STRAIN
        if qs.memo_state?(8) && get_quest_items_count(killer, MANUSCRIPT_PAGE) < 30
          if Rnd.rand(1000) < 860
            if get_quest_items_count(killer, MANUSCRIPT_PAGE) >= 29
              qs.set_cond(8, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
            give_items(killer, MANUSCRIPT_PAGE, 1)
          end
        end
      when GHOUL, DEAD_SEEKER
        if qs.memo_state?(8) && get_quest_items_count(killer, MANUSCRIPT_PAGE) < 30
          if get_quest_items_count(killer, MANUSCRIPT_PAGE) >= 29
            qs.set_cond(8, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
          give_items(killer, MANUSCRIPT_PAGE, 1)
          if Rnd.rand(1000) < 20 && get_quest_items_count(killer, MANUSCRIPT_PAGE) < 29
            give_items(killer, MANUSCRIPT_PAGE, 1)
          end
        end
      when GRANDIS
        if qs.memo_state?(21) || (qs.memo_state?(22) && get_quest_items_count(killer, FRAGMENT_OF_ATTACK_ORDERS) < 10)
          if Rnd.rand(1000) < 780
            if qs.memo_state?(21) && !has_quest_items?(killer, FRAGMENT_OF_ATTACK_ORDERS)
              qs.memo_state = 22
              qs.set_cond(12, true)
              give_items(killer, FRAGMENT_OF_ATTACK_ORDERS, 1)
            elsif qs.memo_state?(22) && get_quest_items_count(killer, FRAGMENT_OF_ATTACK_ORDERS) >= 9
              qs.memo_state = 23
              qs.set_cond(13, true)
              take_items(killer, FRAGMENT_OF_ATTACK_ORDERS, -1)
              give_items(killer, GRANDIS_ATTACK_ORDERS, 1)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              give_items(killer, FRAGMENT_OF_ATTACK_ORDERS, 1)
            end
          end
        end
      when MANASHEN_GARGOYLE
        if qs.memo_state?(25) || (qs.memo_state?(26) && get_quest_items_count(killer, MANASHENS_TALISMAN) < 10)
          if Rnd.rand(1000) < 840
            if qs.memo_state?(25) && !has_quest_items?(killer, MANASHENS_TALISMAN)
              qs.memo_state = 26
              qs.set_cond(15, true)
            elsif qs.memo_state?(26) && get_quest_items_count(killer, MANASHENS_TALISMAN) >= 9
              qs.memo_state = 27
              qs.set_cond(16, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
            give_items(killer, MANASHENS_TALISMAN, 1)
          end
        end
      when TIMAK_ORC, TIMAK_ORC_ARCHER
        if qs.memo_state?(32)
          i4 = qs.get_memo_state_ex(1)
          if i4 < 5
            qs.set_memo_state_ex(1, i4 + 1)
          elsif i4 >= 4
            qs.set_memo_state_ex(1, 0)
            add_spawn(CRIMSON_LADY, npc, true, 0, false)
          end
        end
      when DELU_LIZARDMAN_SHAMAN, DELU_LIZARDMAN_SUPPLIER
        if qs.memo_state?(3) && get_quest_items_count(killer, ENMITY_CRYSTAL) < 30
          if get_quest_items_count(killer, ENMITY_CRYSTAL) >= 29
            qs.set_cond(4, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
          give_items(killer, ENMITY_CRYSTAL, 1)
          if Rnd.rand(1000) < 80 && get_quest_items_count(killer, ENMITY_CRYSTAL) < 29
            give_items(killer, ENMITY_CRYSTAL, 1)
          end
        end
      when WATCHMAN_OF_THE_PLAINS
        if qs.memo_state?(3) && get_quest_items_count(killer, ENMITY_CRYSTAL) < 30
          if Rnd.rand(1000) < 840
            if get_quest_items_count(killer, ENMITY_CRYSTAL) >= 29
              qs.set_cond(4, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
            give_items(killer, ENMITY_CRYSTAL, 1)
          end
        end
      when ROUGHLY_HEWN_ROCK_GOLEM
        if qs.memo_state?(3) && get_quest_items_count(killer, ENMITY_CRYSTAL) < 30
          if Rnd.rand(1000) < 860
            if get_quest_items_count(killer, ENMITY_CRYSTAL) >= 29
              qs.set_cond(4, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
            give_items(killer, ENMITY_CRYSTAL, 1)
          end
        end
      when DELU_LIZARDMAN_AGENT
        if qs.memo_state?(3) && get_quest_items_count(killer, ENMITY_CRYSTAL) < 30
          if get_quest_items_count(killer, ENMITY_CRYSTAL) >= 29
            qs.set_cond(4, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
          give_items(killer, ENMITY_CRYSTAL, 1)
          if Rnd.rand(1000) < 240 && get_quest_items_count(killer, ENMITY_CRYSTAL) < 29
            give_items(killer, ENMITY_CRYSTAL, 1)
          end
        end
      when CURSED_SEER
        if qs.memo_state?(3) && get_quest_items_count(killer, ENMITY_CRYSTAL) < 30
          if get_quest_items_count(killer, ENMITY_CRYSTAL) >= 29
            qs.set_cond(4, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
          give_items(killer, ENMITY_CRYSTAL, 1)
          if Rnd.rand(1000) < 40 && get_quest_items_count(killer, ENMITY_CRYSTAL) < 29
            give_items(killer, ENMITY_CRYSTAL, 1)
          end
        end
      when DELU_LIZARDMAN_COMMANDER
        if qs.memo_state?(3) && get_quest_items_count(killer, ENMITY_CRYSTAL) < 30
          if get_quest_items_count(killer, ENMITY_CRYSTAL) >= 28
            qs.set_cond(4, true)
          end

          if get_quest_items_count(killer, ENMITY_CRYSTAL) < 29
            give_items(killer, ENMITY_CRYSTAL, 2)
            if Rnd.rand(1000) < 220 && get_quest_items_count(killer, ENMITY_CRYSTAL) < 28
              give_items(killer, ENMITY_CRYSTAL, 1)
              if get_quest_items_count(killer, ENMITY_CRYSTAL) >= 27
                qs.set_cond(4, true)
              else
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            end
          else
            give_items(killer, ENMITY_CRYSTAL, 1)
          end
        end
      when CRIMSON_LADY
        if qs.memo_state?(32)
          give_items(killer, RESEARCH_ON_THE_GIANTS_AND_THE_ANCIENT_RACE, 1)
          qs.memo_state = 32
          qs.set_cond(20, true)
        end
      else
        # automatically added
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state
    html = get_no_quest_msg(pc)
    if qs.created?
      if npc.id == MASTER_RINDY
        if pc.class_id.warder? && !has_quest_items?(pc, KAMAEL_INQUISITOR_MARK)
          if pc.level >= MIN_LEVEL
            html = "32201-01.htm"
          else
            html = "32201-02.html"
          end
        else
          html = "32201-03.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MASTER_RINDY
        if memo_state == 1
          qs.memo_state = 2
          qs.set_cond(2, true)
          html = "32201-09.html"
        elsif memo_state == 2
          html = "32201-10.html"
        elsif (memo_state > 2) && (memo_state < 11)
          html = "32201-11.html"
        elsif memo_state >= 11
          html = "32201-12.html"
        end
      when WAREHOUSE_KEEPER_HOLVAS
        if memo_state < 7
          html = "30058-01.html"
        elsif memo_state == 7
          html = "30058-02.html"
        elsif memo_state == 8
          if get_quest_items_count(pc, MANUSCRIPT_PAGE) < 30
            html = "30058-06.html"
          else
            take_items(pc, MANUSCRIPT_PAGE, -1)
            qs.memo_state = 9
            html = "30058-07.html"
          end
        elsif memo_state == 9
          give_items(pc, ENCODED_PAGE_ON_THE_ANCIENT_RACE, 1)
          qs.memo_state = 10
          qs.set_cond(9, true)
          html = "30058-09.html"
        elsif memo_state > 9
          html = "30058-10.html"
        end
      when MAGISTER_GAIUS
        if memo_state < 23
          html = "30171-01.html"
        elsif memo_state == 23
          html = "30171-02.html"
        elsif memo_state == 24
          html = "30171-06.html"
        elsif memo_state == 25
          html = "30171-09.html"
        elsif memo_state == 26
          html = "30171-10.html"
        elsif memo_state == 27
          html = "30171-11.html"
        elsif memo_state == 28
          html = "30171-12.html"
        elsif memo_state == 29
          html = "30171-13.html"
        end
      when BLACKSMITH_POITAN
        if memo_state < 5
          html = "30458-01.html"
        elsif memo_state == 5
          html = "30458-02.html"
        elsif memo_state == 6
          html = "30458-04.html"
        elsif memo_state == 7
          html = "30458-10.html"
        end
      when MAGISTER_CLAYTON
        if memo_state < 2
          html = "30464-01.html"
        elsif memo_state == 2
          qs.memo_state = 2
          html = "30464-02.html"
        elsif memo_state == 3
          if get_quest_items_count(pc, ENMITY_CRYSTAL) < 30
            html = "30464-07.html"
          else
            take_items(pc, ENMITY_CRYSTAL, -1)
            qs.memo_state = 4
            html = "30464-08.html"
          end
        elsif memo_state == 4
          give_items(pc, ENMITY_CRYSTAL_CORE, 1)
          qs.memo_state = 5
          qs.set_cond(5, true)
          html = "30464-10.html"
        elsif memo_state == 5
          html = "30464-12.html"
        elsif memo_state > 5
          html = "30464-13.html"
        end
      when MAGISTER_GAUEN
        if memo_state < 27
          html = "30717-01.html"
        elsif memo_state == 27
          take_items(pc, MANASHENS_TALISMAN, -1)
          qs.memo_state = 28
          html = "30717-02.html"
        elsif memo_state == 28
          html = "30717-04.html"
        elsif memo_state >= 29
          html = "30717-10.html"
        end
      when MAGISTER_KAIENA
        if memo_state < 29
          html = "30720-01.html"
        elsif memo_state == 29
          html = "30720-02.html"
        end
        if memo_state >= 30
          html = "30720-05.html"
        end
      when GRAND_MASTER_MELDINA
        if memo_state < 10
          html = "32214-01.html"
        elsif memo_state == 10
          html = "32214-02.html"
        end
        if memo_state == 11
          html = "32214-05.html"
        end
        if memo_state > 11
          html = "32214-06.html"
        end
      when MASTER_SELSIA
        if memo_state < 11
          html = "32220-01.html"
        elsif memo_state == 11
          html = "32220-02.html"
        elsif memo_state == 12
          html = "32220-04.html"
        elsif memo_state == 13
          if qs.get_memo_state_ex(1) == 0
            qs.set_memo_state_ex(1, 0)
            html = "32220-07.html"
          elsif qs.get_memo_state_ex(1) == 1
            qs.set_memo_state_ex(1, 0)
            html = "32220-08.html"
          end
        elsif memo_state == 20
          qs.memo_state = 21
          qs.set_cond(11, true)
          html = "32220-14.html"
        elsif memo_state == 21
          html = "32220-15.html"
        elsif memo_state == 22
          html = "32220-16.html"
        elsif memo_state >= 23 && memo_state < 30
          html = "32220-17.html"
        elsif memo_state == 30
          qs.memo_state = 31
          html = "32220-18.html"
        elsif memo_state == 31
          html = "32220-20.html"
        elsif memo_state == 32
          if !has_quest_items?(pc, RESEARCH_ON_THE_GIANTS_AND_THE_ANCIENT_RACE)
            html = "32220-27.html"
          else
            give_adena(pc, 77666, true)
            give_items(pc, KAMAEL_INQUISITOR_MARK, 1)
            add_exp_and_sp(pc, 429546, 29476)
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            html = "32220-28.html"
          end
        end
      else
        # automatically added
      end

    end
    if qs.completed?
      if npc.id == MASTER_RINDY
        if pc.class_id.arbalester?
          html = "32201-05.html"
        else
          html = "32201-06.html"
        end
      end
    end

    html
  end
end