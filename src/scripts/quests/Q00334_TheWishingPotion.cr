class Scripts::Q00334_TheWishingPotion < Quest
  # NPCs
  private TORAI = 30557
  private ALCHEMIST_MATILD = 30738
  private FAIRY_RUPINA = 30742
  private WISDOM_CHEST = 30743

  # Monsters
  private WHISPERING_WIND = 20078
  private ANT_SOLDIER = 20087
  private ANT_WARRIOR_CAPTAIN = 20088
  private SILENOS = 20168
  private TYRANT = 20192
  private TYRANT_KINGPIN = 20193
  private AMBER_BASILISK = 20199
  private MIST_HORROR_RIPPER = 20227
  private TURAK_BUGBEAR = 20248
  private TURAK_BUGBEAR_WARRIOR = 20249
  private GRIMA = 27135
  private GLASS_JAGUAR = 20250
  private SUCCUBUS_OF_SEDUCTION = 27136
  private GREAT_DEMON_KING = 27138
  private SECRET_KEEPER_TREE = 27139
  private DLORD_ALEXANDROSANCHES = 27153
  private ABYSSKING_BONAPARTERIUS = 27154
  private EVILOVERLORD_RAMSEBALIUS = 27155

  # Items
  private Q_WISH_POTION = 3467
  private Q_ANCIENT_CROWN = 3468
  private Q_CERTIFICATE_OF_ROYALTY = 3469
  private Q_ALCHEMY_TEXT = 3678
  private Q_SECRET_BOOK_OF_POTION = 3679
  private Q_POTION_RECIPE_1 = 3680
  private Q_POTION_RECIPE_2 = 3681
  private Q_MATILDS_ORB = 3682
  private Q_FOBBIDEN_LOVE_SCROLL = 3683

  # Items required for create wish potion
  private Q_AMBER_SCALE = 3684
  private Q_WIND_SOULSTONE = 3685
  private Q_GLASS_EYE = 3686
  private Q_HORROR_ECTOPLASM = 3687
  private Q_SILENOS_HORN = 3688
  private Q_ANT_SOLDIER_APHID = 3689
  private Q_TYRANTS_CHITIN = 3690
  private Q_BUGBEAR_BLOOD = 3691

  # Rewards
  private NECKLACE_OF_GRACE = 931
  private DEMONS_TUNIC_FABRIC = 1979
  private DEMONS_HOSE_PATTERN = 1980
  private DEMONS_BOOTS_FABRIC = 2952
  private DEMONS_GLOVES_FABRIC = 2953
  private Q_MUSICNOTE_LOVE = 4408
  private Q_MUSICNOTE_BATTLE = 4409
  private Q_GOLD_CIRCLET = 12766
  private Q_SILVER_CIRCLET = 12767

  private DEMONS_TUNIC = 441
  private DEMONS_HOSE = 472
  private DEMONS_BOOTS = 2435
  private DEMONS_GLOVES = 2459

  # Misc
  private FLAG = "flag"
  private I_QUEST0 = "i_quest0"
  private EXCHANGE = "Exchange"

  # Reward
  def initialize
    super(334, self.class.simple_name, "The Wishing Potion")

    add_start_npc(ALCHEMIST_MATILD)
    add_talk_id(ALCHEMIST_MATILD, TORAI, FAIRY_RUPINA, WISDOM_CHEST)
    add_kill_id(
      WHISPERING_WIND, ANT_SOLDIER, ANT_WARRIOR_CAPTAIN, SILENOS, TYRANT,
      TYRANT_KINGPIN, AMBER_BASILISK, MIST_HORROR_RIPPER
    )
    add_kill_id(
      TURAK_BUGBEAR, TURAK_BUGBEAR_WARRIOR, GRIMA, GLASS_JAGUAR,
      SUCCUBUS_OF_SEDUCTION, GREAT_DEMON_KING, SECRET_KEEPER_TREE
    )
    add_kill_id(
      DLORD_ALEXANDROSANCHES, ABYSSKING_BONAPARTERIUS, EVILOVERLORD_RAMSEBALIUS
    )
    add_spawn_id(
      GRIMA, SUCCUBUS_OF_SEDUCTION, GREAT_DEMON_KING, DLORD_ALEXANDROSANCHES,
      ABYSSKING_BONAPARTERIUS, EVILOVERLORD_RAMSEBALIUS, FAIRY_RUPINA
    )
    register_quest_items(
      Q_SECRET_BOOK_OF_POTION, Q_AMBER_SCALE, Q_GLASS_EYE, Q_HORROR_ECTOPLASM,
      Q_SILENOS_HORN, Q_ANT_SOLDIER_APHID, Q_TYRANTS_CHITIN, Q_BUGBEAR_BLOOD
    )
    register_quest_items(
      Q_WISH_POTION, Q_POTION_RECIPE_1, Q_POTION_RECIPE_2, Q_MATILDS_ORB,
      Q_ALCHEMY_TEXT
    )
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when TORAI
      if qs.has_quest_items?(Q_FOBBIDEN_LOVE_SCROLL)
        qs.give_adena(500000, true)
        qs.take_items(Q_FOBBIDEN_LOVE_SCROLL, 1)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "30557-01.html"
      end
    when ALCHEMIST_MATILD
      if qs.created?
        if pc.level < 30
          return "30738-01.htm"
        end
        return "30738-02.html"
      end
      if !qs.has_quest_items?(Q_SECRET_BOOK_OF_POTION) && qs.has_quest_items?(Q_ALCHEMY_TEXT)
        return "30738-05.html"
      end
      if qs.has_quest_items?(Q_SECRET_BOOK_OF_POTION) && qs.has_quest_items?(Q_ALCHEMY_TEXT)
        return "30738-06.html"
      end
      if qs.has_quest_items?(Q_POTION_RECIPE_1, Q_POTION_RECIPE_2) && (!qs.has_quest_items?(Q_AMBER_SCALE) || (qs.has_quest_items?(Q_WIND_SOULSTONE) && !qs.has_quest_items?(Q_GLASS_EYE)) || (!qs.has_quest_items?(Q_HORROR_ECTOPLASM) || !qs.has_quest_items?(Q_SILENOS_HORN) || !qs.has_quest_items?(Q_ANT_SOLDIER_APHID) || !qs.has_quest_items?(Q_TYRANTS_CHITIN) || !qs.has_quest_items?(Q_BUGBEAR_BLOOD)))
        return "30738-08.html"
      end
      if qs.has_quest_items?(Q_POTION_RECIPE_1, Q_POTION_RECIPE_2, Q_AMBER_SCALE, Q_WIND_SOULSTONE, Q_WIND_SOULSTONE, Q_GLASS_EYE, Q_GLASS_EYE, Q_HORROR_ECTOPLASM, Q_SILENOS_HORN, Q_ANT_SOLDIER_APHID, Q_TYRANTS_CHITIN, Q_BUGBEAR_BLOOD)
        return "30738-09.html"
      end
      if qs.has_quest_items?(Q_MATILDS_ORB) && !qs.has_quest_items?(Q_POTION_RECIPE_1) && !qs.has_quest_items?(Q_POTION_RECIPE_2) && (!qs.has_quest_items?(Q_AMBER_SCALE) || (qs.has_quest_items?(Q_WIND_SOULSTONE) && !qs.has_quest_items?(Q_GLASS_EYE)) || !qs.has_quest_items?(Q_HORROR_ECTOPLASM) || !qs.has_quest_items?(Q_SILENOS_HORN) || !qs.has_quest_items?(Q_ANT_SOLDIER_APHID) || !qs.has_quest_items?(Q_TYRANTS_CHITIN) || !qs.has_quest_items?(Q_BUGBEAR_BLOOD))
        return "30738-12.html"
      end
    when FAIRY_RUPINA
      if qs.get_int(FLAG) == 1
        html = nil
        if Rnd.rand(4) < 4
          qs.give_items(NECKLACE_OF_GRACE, 1)
          qs.set(FLAG, 0)
          html = "30742-01.html"
        else
          case Rnd.rand(4)
          when 0
            qs.give_items(DEMONS_TUNIC_FABRIC, 1)
          when 1
            qs.give_items(DEMONS_HOSE_PATTERN, 1)
          when 2
            qs.give_items(DEMONS_BOOTS_FABRIC, 1)
          when 3
            qs.give_items(DEMONS_GLOVES_FABRIC, 1)
          end


          html = "30742-02.html"
        end

        qs.set(FLAG, 0)
        npc.delete_me
        return html
      end
    when WISDOM_CHEST
      if qs.get_int(FLAG) == 4
        random = Rnd.rand(100)
        html = nil
        if random < 10
          qs.give_items(Q_FOBBIDEN_LOVE_SCROLL, 1)
          html = "30743-02.html"
        elsif random >= 10 && random < 50
          case Rnd.rand(4)
          when 0
            qs.give_items(DEMONS_TUNIC_FABRIC, 1)
          when 1
            qs.give_items(DEMONS_HOSE_PATTERN, 1)
          when 2
            qs.give_items(DEMONS_BOOTS_FABRIC, 1)
          when 3
            qs.give_items(DEMONS_GLOVES_FABRIC, 1)
          end


          html = "30743-03.html"
        elsif random >= 50 && random < 100
          case Rnd.rand(2)
          when 0
            qs.give_items(Q_MUSICNOTE_LOVE, 1)
          when 1
            qs.give_items(Q_MUSICNOTE_BATTLE, 1)
          end


          html = "30743-04.html"
        elsif random >= 85 && random < 95
          case Rnd.rand(4)
          when 0
            qs.give_items(DEMONS_TUNIC, 1)
          when 1
            qs.give_items(DEMONS_HOSE, 1)
          when 2
            qs.give_items(DEMONS_BOOTS, 1)
          when 3
            qs.give_items(DEMONS_GLOVES, 1)
          end


          html = "30743-05.html"
        elsif random >= 95
          case Rnd.rand(2)
          when 0
            qs.give_items(Q_GOLD_CIRCLET, 1)
          when 1
            qs.give_items(Q_SILVER_CIRCLET, 1)
          end


          html = "30743-06.htm"
        end
        qs.set(FLAG, 0)
        npc.delete_me
        return html
      end
    end


    html || get_no_quest_msg(pc)
  end

  def on_spawn(npc)
    case npc.id
    when GRIMA
      start_quest_timer("2336002", 1000 * 200, npc, nil)
      npc.say(NpcString::OH_OH_OH)
    when SUCCUBUS_OF_SEDUCTION
      start_quest_timer("2336003", 1000 * 200, npc, nil)
      npc.say(NpcString::DO_YOU_WANT_US_TO_LOVE_YOU_OH)
    when GREAT_DEMON_KING
      start_quest_timer("2336007", 1000 * 600, npc, nil)
      npc.say(NpcString::WHO_KILLED_MY_UNDERLING_DEVIL)
    when DLORD_ALEXANDROSANCHES
      start_quest_timer("2336004", 1000 * 200, npc, nil)
      npc.say(NpcString::WHO_IS_CALLING_THE_LORD_OF_DARKNESS)
    when ABYSSKING_BONAPARTERIUS
      start_quest_timer("2336005", 1000 * 200, npc, nil)
      npc.say(NpcString::I_AM_A_GREAT_EMPIRE_BONAPARTERIUS)
    when EVILOVERLORD_RAMSEBALIUS
      start_quest_timer("2336006", 1000 * 200, npc, nil)
      npc.say(NpcString::LET_YOUR_HEAD_DOWN_BEFORE_THE_LORD)
    when FAIRY_RUPINA
      start_quest_timer("2336001", 120 * 1000, npc, nil)
      npc.say(NpcString::I_WILL_MAKE_YOUR_LOVE_COME_TRUE_LOVE_LOVE_LOVE)
    when WISDOM_CHEST
      start_quest_timer("2336007", 120 * 1000, npc, nil)
      npc.say(NpcString::I_HAVE_WISDOM_IN_ME_I_AM_THE_BOX_OF_WISDOM)
    end


    super
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    case npc.id
    when FAIRY_RUPINA, GRIMA, SUCCUBUS_OF_SEDUCTION, GREAT_DEMON_KING
      npc.delete_me
    when DLORD_ALEXANDROSANCHES
      npc.say(NpcString::OH_ITS_NOT_AN_OPPONENT_OF_MINE_HA_HA_HA)
      npc.delete_me
    when ABYSSKING_BONAPARTERIUS
      npc.say(NpcString::OH_ITS_NOT_AN_OPPONENT_OF_MINE_HA_HA_HA)
      npc.delete_me
    when EVILOVERLORD_RAMSEBALIUS
      npc.say(NpcString::OH_ITS_NOT_AN_OPPONENT_OF_MINE_HA_HA_HA)
      npc.delete_me
    when WISDOM_CHEST
      npc.say(NpcString::DONT_INTERRUPT_MY_REST_AGAIN)
      npc.say(NpcString::YOURE_A_GREAT_DEVIL_NOW)
      npc.delete_me
    when ALCHEMIST_MATILD
      pc = pc.not_nil!
      qs = get_quest_state!(pc, false)

      if event == "QUEST_ACCEPTED"
        qs.play_sound(Sound::ITEMSOUND_QUEST_ACCEPT)
        qs.start_quest
        qs.memo_state = 1
        qs.set_cond(1)
        qs.show_question_mark(334)
        unless qs.has_quest_items?(Q_ALCHEMY_TEXT)
          qs.give_items(Q_ALCHEMY_TEXT, 1)
        end
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "30738-04.htm"
      end

      case event.to_i
      when 1
        return "30738-03.htm"
      when 2
        qs.take_items(Q_SECRET_BOOK_OF_POTION, -1)
        qs.take_items(Q_ALCHEMY_TEXT, -1)
        qs.give_items(Q_POTION_RECIPE_1, 1)
        qs.give_items(Q_POTION_RECIPE_2, 1)
        qs.memo_state = 2
        qs.set_cond(3, true)
        qs.show_question_mark(334)
        return "30738-07.html"
      when 3
        return "30738-10.html"
      when 4
        if qs.has_quest_items?(Q_AMBER_SCALE, Q_GLASS_EYE, Q_HORROR_ECTOPLASM, Q_SILENOS_HORN, Q_ANT_SOLDIER_APHID, Q_TYRANTS_CHITIN, Q_BUGBEAR_BLOOD, Q_WIND_SOULSTONE, Q_POTION_RECIPE_1, Q_POTION_RECIPE_2)
          qs.give_items(Q_WISH_POTION, 1)
          unless qs.has_quest_items?(Q_MATILDS_ORB)
            qs.give_items(Q_MATILDS_ORB, 1)
          end
          qs.take_items(Q_AMBER_SCALE, 1)
          qs.take_items(Q_GLASS_EYE, 1)
          qs.take_items(Q_HORROR_ECTOPLASM, 1)
          qs.take_items(Q_SILENOS_HORN, 1)
          qs.take_items(Q_ANT_SOLDIER_APHID, 1)
          qs.take_items(Q_TYRANTS_CHITIN, 1)
          qs.take_items(Q_BUGBEAR_BLOOD, 1)
          qs.take_items(Q_WIND_SOULSTONE, 1)
          qs.take_items(Q_POTION_RECIPE_1, -1)
          qs.take_items(Q_POTION_RECIPE_2, -1)
          qs.memo_state = 2
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          qs.set_cond(5)
          qs.show_question_mark(334)
          return "30738-11.html"
        end
      when 5
        if qs.has_quest_items?(Q_WISH_POTION)
          if qs.get_int(I_QUEST0) != 1
            qs.set(I_QUEST0, 0)
          end
          return "30738-13.html"
        end
        return "30738-14.html"
      when 6
        if qs.has_quest_items?(Q_WISH_POTION)
          return "30738-15a.html"
        end
        qs.give_items(Q_POTION_RECIPE_1, 1)
        qs.give_items(Q_POTION_RECIPE_2, 1)
        return "30738-15.html"
      when 7
        if qs.has_quest_items?(Q_WISH_POTION)
          if qs.get_int(EXCHANGE) == -1
            qs.take_items(Q_WISH_POTION, 1)
            qs.set(I_QUEST0, 1)
            qs.set(FLAG, 1)
            start_quest_timer("2336008", 3 * 1000, npc, pc)
            return "30738-16.html"
          end
          return "30738-20.html"
        end
        return "30738-14.html"
      when 8
        if qs.has_quest_items?(Q_WISH_POTION)
          if qs.get_int(EXCHANGE) == -1
            qs.take_items(Q_WISH_POTION, 1)
            qs.set(I_QUEST0, 2)
            qs.set(FLAG, 2)
            start_quest_timer("2336008", 3 * 1000, npc, pc)
            return "30738-17.html"
          end
          return "30738-20.html"
        end
        return "30738-14.html"
      when 9
        if qs.has_quest_items?(Q_WISH_POTION)
          if qs.get_int(EXCHANGE) == -1
            qs.take_items(Q_WISH_POTION, 1)
            qs.set(I_QUEST0, 3)
            qs.set(FLAG, 3)
            start_quest_timer("2336008", 3 * 1000, npc, pc)
            return "30738-18.html"
          end
          return "30738-20.html"
        end
        return "30738-14.html"
      when 10
        if qs.has_quest_items?(Q_WISH_POTION)
          if qs.get_int(EXCHANGE) == -1
            qs.take_items(Q_WISH_POTION, 1)
            qs.set(I_QUEST0, 4)
            qs.set(FLAG, 4)
            start_quest_timer("2336008", 3 * 1000, npc, pc)
            return "30738-19.html"
          end
          return "30738-20.html"
        end
        return "30738-14.html"
      when 2336008
        npc.say(NpcString::OK_EVERYBODY_PRAY_FERVENTLY)
        start_quest_timer("2336009", 4 * 1000, npc, pc)
      when 2336009
        npc.say(NpcString::BOTH_HANDS_TO_HEAVEN_EVERYBODY_YELL_TOGETHER)
        start_quest_timer("2336010", 4 * 1000, npc, pc)
      when 2336010
        npc.say(NpcString::ONE_TWO_MAY_YOUR_DREAMS_COME_TRUE)
        i0 = 0
        case qs.get_int(I_QUEST0)
        when 1
          i0 = Rnd.rand(2)
        when 2..4
          i0 = Rnd.rand(3)
        end

        case i0
        when 0
          case qs.get_int(I_QUEST0)
          when 1
            add_spawn(FAIRY_RUPINA, npc, true, 0, false)
            qs.set("Exchange", 0)
          when 2
            add_spawn(GRIMA, npc, true, 0, false)
            add_spawn(GRIMA, npc, true, 0, false)
            add_spawn(GRIMA, npc, true, 0, false)
            qs.set("Exchange", 0)
          when 3
            qs.give_items(Q_CERTIFICATE_OF_ROYALTY, 1)
            qs.set("Exchange", 0)
          when 4
            add_spawn(WISDOM_CHEST, npc, true, 0, false)
            qs.set("Exchange", 0)
          end

        when 1
          case qs.get_int(I_QUEST0)
          when 1
            add_spawn(SUCCUBUS_OF_SEDUCTION, npc, true, 0, false)
            add_spawn(SUCCUBUS_OF_SEDUCTION, npc, true, 0, false)
            add_spawn(SUCCUBUS_OF_SEDUCTION, npc, true, 0, false)
            add_spawn(SUCCUBUS_OF_SEDUCTION, npc, true, 0, false)
            qs.set("Exchange", 0)
          when 2
            qs.give_adena(10000, true)
            qs.set("Exchange", 0)
          when 3
            add_spawn(DLORD_ALEXANDROSANCHES, npc, true, 0, false)
            qs.set("Exchange", 0)
          when 4
            add_spawn(WISDOM_CHEST, npc, true, 0, false)
            qs.set("Exchange", 0)
          end

        when 2
          case qs.get_int(I_QUEST0)
          when 2
            qs.give_adena(10000, true)
            qs.set("Exchange", 0)
          when 3
            qs.give_items(Q_ANCIENT_CROWN, 1)
            qs.set("Exchange", 0)
          when 4
            add_spawn(WISDOM_CHEST, npc, true, 0, false)
            qs.set("Exchange", 0)
          end

        end

      end

    end


    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_player_from_party(killer, npc)
    if qs
      case npc.id
      when WHISPERING_WIND
        if qs.has_quest_items?(Q_POTION_RECIPE_1, Q_POTION_RECIPE_2) && !qs.has_quest_items?(Q_WIND_SOULSTONE)
          if Rnd.rand(10) == 0
            qs.give_items(Q_WIND_SOULSTONE, 1)
            qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            if qs.has_quest_items?(Q_AMBER_SCALE, Q_GLASS_EYE, Q_HORROR_ECTOPLASM, Q_SILENOS_HORN, Q_ANT_SOLDIER_APHID, Q_TYRANTS_CHITIN, Q_BUGBEAR_BLOOD)
              qs.set_cond(4, true)
              qs.show_question_mark(334)
            else
              qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when ANT_SOLDIER, ANT_WARRIOR_CAPTAIN
        if qs.has_quest_items?(Q_POTION_RECIPE_1, Q_POTION_RECIPE_2) && !qs.has_quest_items?(Q_ANT_SOLDIER_APHID)
          if Rnd.rand(10) == 0
            qs.give_items(Q_ANT_SOLDIER_APHID, 1)
            qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            if qs.has_quest_items?(Q_AMBER_SCALE, Q_WIND_SOULSTONE, Q_GLASS_EYE, Q_HORROR_ECTOPLASM, Q_SILENOS_HORN, Q_ANT_SOLDIER_APHID, Q_TYRANTS_CHITIN, Q_BUGBEAR_BLOOD)
              qs.set_cond(4, true)
              qs.show_question_mark(334)
            else
              qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when SILENOS
        if qs.has_quest_items?(Q_POTION_RECIPE_1, Q_POTION_RECIPE_2) && !qs.has_quest_items?(Q_SILENOS_HORN)
          if Rnd.rand(10) == 0
            qs.give_items(Q_SILENOS_HORN, 1)
            qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            if qs.has_quest_items?(Q_AMBER_SCALE, Q_WIND_SOULSTONE, Q_GLASS_EYE, Q_HORROR_ECTOPLASM, Q_ANT_SOLDIER_APHID, Q_TYRANTS_CHITIN, Q_BUGBEAR_BLOOD)
              qs.set_cond(4, true)
              qs.show_question_mark(334)
            else
              qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when TYRANT, TYRANT_KINGPIN
        if qs.has_quest_items?(Q_POTION_RECIPE_1, Q_POTION_RECIPE_2) && !qs.has_quest_items?(Q_TYRANTS_CHITIN)
          if Rnd.rand(10) == 0
            qs.give_items(Q_TYRANTS_CHITIN, 1)
            qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            if qs.has_quest_items?(Q_AMBER_SCALE, Q_WIND_SOULSTONE, Q_GLASS_EYE, Q_HORROR_ECTOPLASM, Q_SILENOS_HORN, Q_ANT_SOLDIER_APHID, Q_TYRANTS_CHITIN, Q_BUGBEAR_BLOOD)
              qs.set_cond(4, true)
              qs.show_question_mark(334)
            else
              qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when AMBER_BASILISK
        if qs.has_quest_items?(Q_POTION_RECIPE_1, Q_POTION_RECIPE_2) && !qs.has_quest_items?(Q_AMBER_SCALE)
          if Rnd.rand(10) == 0
            qs.give_items(Q_AMBER_SCALE, 1)
            qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            if qs.has_quest_items?(Q_WIND_SOULSTONE, Q_GLASS_EYE, Q_HORROR_ECTOPLASM, Q_SILENOS_HORN, Q_ANT_SOLDIER_APHID, Q_TYRANTS_CHITIN, Q_BUGBEAR_BLOOD)
              qs.set_cond(4, true)
              qs.show_question_mark(334)
            else
              qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when MIST_HORROR_RIPPER
        if qs.has_quest_items?(Q_POTION_RECIPE_1, Q_POTION_RECIPE_2) && !qs.has_quest_items?(Q_HORROR_ECTOPLASM)
          if Rnd.rand(10) == 0
            qs.give_items(Q_HORROR_ECTOPLASM, 1)
            qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            if qs.has_quest_items?(Q_AMBER_SCALE, Q_WIND_SOULSTONE, Q_GLASS_EYE, Q_HORROR_ECTOPLASM, Q_SILENOS_HORN, Q_ANT_SOLDIER_APHID, Q_TYRANTS_CHITIN, Q_BUGBEAR_BLOOD)
              qs.set_cond(4, true)
              qs.show_question_mark(334)
            else
              qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when TURAK_BUGBEAR, TURAK_BUGBEAR_WARRIOR
        if qs.has_quest_items?(Q_POTION_RECIPE_1, Q_POTION_RECIPE_2) && !qs.has_quest_items?(Q_BUGBEAR_BLOOD)
          if Rnd.rand(10) == 0
            qs.give_items(Q_BUGBEAR_BLOOD, 1)
            qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            if qs.has_quest_items?(Q_AMBER_SCALE, Q_WIND_SOULSTONE, Q_GLASS_EYE, Q_HORROR_ECTOPLASM, Q_SILENOS_HORN, Q_ANT_SOLDIER_APHID, Q_TYRANTS_CHITIN, Q_BUGBEAR_BLOOD)
              qs.set_cond(4, true)
              qs.show_question_mark(334)
            else
              qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when GLASS_JAGUAR
        if qs.has_quest_items?(Q_POTION_RECIPE_1, Q_POTION_RECIPE_2) && !qs.has_quest_items?(Q_GLASS_EYE)
          if Rnd.rand(10) == 0
            qs.give_items(Q_GLASS_EYE, 1)
            qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            if qs.has_quest_items?(Q_AMBER_SCALE, Q_WIND_SOULSTONE, Q_GLASS_EYE, Q_HORROR_ECTOPLASM, Q_SILENOS_HORN, Q_ANT_SOLDIER_APHID, Q_TYRANTS_CHITIN, Q_BUGBEAR_BLOOD)
              qs.set_cond(4, true)
              qs.show_question_mark(334)
            else
              qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when GRIMA
        if qs.memo_state?(2) && qs.get_int(FLAG) == 2
          if Rnd.rand(1000) < 33
            if Rnd.rand(1000) == 0
              qs.give_adena(100_000_000, true)
            else
              qs.give_adena(900_000, true)
            end
            qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            qs.set(FLAG, 0)
          end
        end
      when SUCCUBUS_OF_SEDUCTION
        if qs.memo_state?(2) && !qs.has_quest_items?(Q_FOBBIDEN_LOVE_SCROLL) && qs.get_int(FLAG) == 1 && Rnd.rand(1000) < 28
          qs.give_items(Q_FOBBIDEN_LOVE_SCROLL, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
          qs.set(FLAG, 0)
        end
      when GREAT_DEMON_KING
        if qs.memo_state?(2) && qs.get_int(FLAG) == 3
          qs.give_adena(1_406_956, true)
          qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
          qs.set(FLAG, 0)
        end
      when SECRET_KEEPER_TREE
        if qs.memo_state?(1) && !qs.has_quest_items?(Q_SECRET_BOOK_OF_POTION)
          qs.give_items(Q_SECRET_BOOK_OF_POTION, 1)
          qs.set_cond(2, true)
          qs.show_question_mark(334)
          qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      when DLORD_ALEXANDROSANCHES
        if qs.memo_state?(2) && qs.get_int(FLAG) == 3
          npc.say(NpcString::BONAPARTERIUS_ABYSS_KING_WILL_PUNISH_YOU)
          if Rnd.bool
            add_spawn(ABYSSKING_BONAPARTERIUS, npc, true, 0, false)
          else
            case Rnd.rand(4)
            when 0
              qs.give_items(DEMONS_TUNIC_FABRIC, 1)
            when 1
              qs.give_items(DEMONS_HOSE_PATTERN, 1)
            when 2
              qs.give_items(DEMONS_BOOTS_FABRIC, 1)
            when 3
              qs.give_items(DEMONS_GLOVES_FABRIC, 1)
            end

          end
        end
      when ABYSSKING_BONAPARTERIUS
        if qs.memo_state?(2) && qs.get_int(FLAG) == 3
          npc.say(NpcString::REVENGE_IS_OVERLORD_RAMSEBALIUS_OF_THE_EVIL_WORLD)
          if Rnd.bool
            add_spawn(EVILOVERLORD_RAMSEBALIUS, npc, true, 0, false)
          else
            case Rnd.rand(4)
            when 0
              qs.give_items(DEMONS_TUNIC_FABRIC, 1)
            when 1
              qs.give_items(DEMONS_HOSE_PATTERN, 1)
            when 2
              qs.give_items(DEMONS_BOOTS_FABRIC, 1)
            when 3
              qs.give_items(DEMONS_GLOVES_FABRIC, 1)
            end

          end
        end
      when EVILOVERLORD_RAMSEBALIUS
        if qs.memo_state?(2) && qs.get_int(FLAG) == 3
          npc.say(NpcString::OH_GREAT_DEMON_KING)
          if Rnd.bool
            add_spawn(GREAT_DEMON_KING, npc, true, 0, false)
          else
            case Rnd.rand(4)
            when 0
              qs.give_items(DEMONS_TUNIC_FABRIC, 1)
            when 1
              qs.give_items(DEMONS_HOSE_PATTERN, 1)
            when 2
              qs.give_items(DEMONS_BOOTS_FABRIC, 1)
            when 3
              qs.give_items(DEMONS_GLOVES_FABRIC, 1)
            end

          end
        end
      end

    end

    super
  end

  private def get_random_player_from_party(pc, npc)
    qs = pc.get_quest_state(name)

    if qs && qs.started?
      candidates = [qs, qs]
    else
      candidates = [] of QuestState
    end

    if party = pc.party
      party.members.each do |pm|
        qss = pm.get_quest_state(name)
        if qss && qss.started? && Util.in_range?(1500, npc, pm, true)
          candidates << qss
        end
      end
    end

    candidates.sample?(random: Rnd)
  end
end
