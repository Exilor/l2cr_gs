class Scripts::Q00060_GoodWorksReward < Quest
  # NPCs
  private GROCER_HELVETIA = 30081
  private BLACK_MARKETEER_OF_MAMMON = 31092
  private BLUEPRINT_SELLER_DAEGER = 31435
  private MARK = 32487
  # Items
  private BLOODY_CLOTH_FRAGMENT = 10867
  private HELVETIAS_ANTIDOTE = 10868
  # Reward
  private MARK_OF_CHALLENGER = 2627
  private MARK_OF_DUTY = 2633
  private MARK_OF_SEEKER = 2673
  private MARK_OF_SCHOLAR = 2674
  private MARK_OF_PILGRIM = 2721
  private MARK_OF_TRUST = 2734
  private MARK_OF_DUELIST = 2762
  private MARK_OF_SEARCHER = 2809
  private MARK_OF_HEALER = 2820
  private MARK_OF_REFORMER = 2821
  private MARK_OF_MAGUS = 2840
  private MARK_OF_MAESTRO = 2867
  private MARK_OF_WARSPIRIT = 2879
  private MARK_OF_GUILDSMAN = 3119
  private MARK_OF_LIFE = 3140
  private MARK_OF_FATE = 3172
  private MARK_OF_GLORY = 3203
  private MARK_OF_PROSPERITY = 3238
  private MARK_OF_CHAMPION = 3276
  private MARK_OF_SAGITTARIUS = 3293
  private MARK_OF_WITCHCRAFT = 3307
  private MARK_OF_SUMMONER = 3336
  private MARK_OF_LORD = 3390
  # Quest Monster
  private PURSUER = 27340
  # Misc
  private MIN_LEVEL = 39
  private ONE_MILLION = 1000000
  private TWO_MILLION = 2000000
  private THREE_MILLION = 3000000

  def initialize
    super(60, self.class.simple_name, "Good Work's Reward")

    add_start_npc(BLUEPRINT_SELLER_DAEGER)
    add_talk_id(
      BLUEPRINT_SELLER_DAEGER, GROCER_HELVETIA, BLACK_MARKETEER_OF_MAMMON, MARK
    )
    add_kill_id(PURSUER)
    add_spawn_id(PURSUER)
    register_quest_items(BLOODY_CLOTH_FRAGMENT, HELVETIAS_ANTIDOTE)
  end

  def on_adv_event(event, npc, pc)
    if event == "DESPAWN"
      npc = npc.not_nil!
      npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::YOU_HAVE_GOOD_LUCK_I_SHALL_RETURN))
      if npc0 = npc.variables.get_object("npc0", L2Npc?)
        npc0.variables["SPAWNED"] = false
      end
      npc.delete_me
      return super
    end

    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31435-07.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        html = event
      end
    when "31435-02.htm"
      html = event
    when "31435-10.html"
      if qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(4, true)
        html = event
      end
    when "31435-14.html"
      if qs.memo_state?(8)
        qs.memo_state = 9
        qs.set_cond(9, true)
        html = event
      end
    when "30081-02.html"
      if qs.memo_state?(4)
        html = event
      end
    when "30081-03.html"
      if qs.memo_state?(4)
        take_items(pc, BLOODY_CLOTH_FRAGMENT, -1)
        qs.memo_state = 5
        qs.set_cond(5, true)
        html = event
      end
    when "30081-05.html"
      memo_state = qs.memo_state
      if memo_state >= 5 && memo_state <= 6
        if get_quest_items_count(pc, Inventory::ADENA_ID) >= THREE_MILLION
          give_items(pc, HELVETIAS_ANTIDOTE, 1)
          take_items(pc, Inventory::ADENA_ID, THREE_MILLION)
          qs.memo_state = 7
          qs.set_cond(7, true)
          html = event
        else
          qs.memo_state = 6
          qs.set_cond(6, true)
          html = "30081-06.html"
        end
      end
    when "30081-07.html"
      if qs.memo_state?(5)
        qs.memo_state = 6
        qs.set_cond(6, true)
        html = event
      end
    when "REPLY_1"
      if qs.memo_state?(10)
        if pc.quest_completed?(Q00211_TrialOfTheChallenger.simple_name) || pc.quest_completed?(Q00212_TrialOfDuty.simple_name) || pc.quest_completed?(Q00213_TrialOfTheSeeker.simple_name) || pc.quest_completed?(Q00214_TrialOfTheScholar.simple_name) || pc.quest_completed?(Q00215_TrialOfThePilgrim.simple_name) || pc.quest_completed?(Q00216_TrialOfTheGuildsman.simple_name)
          if pc.quest_completed?(Q00217_TestimonyOfTrust.simple_name) || pc.quest_completed?(Q00218_TestimonyOfLife.simple_name) || pc.quest_completed?(Q00219_TestimonyOfFate.simple_name) || pc.quest_completed?(Q00220_TestimonyOfGlory.simple_name) || pc.quest_completed?(Q00221_TestimonyOfProsperity.simple_name)

            if pc.quest_completed?(Q00222_TestOfTheDuelist.simple_name) || pc.quest_completed?(Q00223_TestOfTheChampion.simple_name) || pc.quest_completed?(Q00224_TestOfSagittarius.simple_name) || pc.quest_completed?(Q00225_TestOfTheSearcher.simple_name) || pc.quest_completed?(Q00226_TestOfTheHealer.simple_name) || pc.quest_completed?(Q00227_TestOfTheReformer.simple_name) || pc.quest_completed?(Q00228_TestOfMagus.simple_name) || pc.quest_completed?(Q00229_TestOfWitchcraft.simple_name) || pc.quest_completed?(Q00230_TestOfTheSummoner.simple_name) || pc.quest_completed?(Q00231_TestOfTheMaestro.simple_name) || pc.quest_completed?(Q00232_TestOfTheLord.simple_name) || pc.quest_completed?(Q00233_TestOfTheWarSpirit.simple_name)
              qs.set_memo_state_ex(1, 3)
            else
              qs.set_memo_state_ex(1, 2)
            end
          elsif pc.quest_completed?(Q00222_TestOfTheDuelist.simple_name) || pc.quest_completed?(Q00223_TestOfTheChampion.simple_name) || pc.quest_completed?(Q00224_TestOfSagittarius.simple_name) || pc.quest_completed?(Q00225_TestOfTheSearcher.simple_name) || pc.quest_completed?(Q00226_TestOfTheHealer.simple_name) || pc.quest_completed?(Q00227_TestOfTheReformer.simple_name) || pc.quest_completed?(Q00228_TestOfMagus.simple_name) || pc.quest_completed?(Q00229_TestOfWitchcraft.simple_name) || pc.quest_completed?(Q00230_TestOfTheSummoner.simple_name) || pc.quest_completed?(Q00231_TestOfTheMaestro.simple_name) || pc.quest_completed?(Q00232_TestOfTheLord.simple_name) || pc.quest_completed?(Q00233_TestOfTheWarSpirit.simple_name)
            qs.set_memo_state_ex(1, 2)
          else
            qs.set_memo_state_ex(1, 1)
          end
        elsif pc.quest_completed?(Q00217_TestimonyOfTrust.simple_name) || pc.quest_completed?(Q00218_TestimonyOfLife.simple_name) || pc.quest_completed?(Q00219_TestimonyOfFate.simple_name) || pc.quest_completed?(Q00220_TestimonyOfGlory.simple_name) || pc.quest_completed?(Q00221_TestimonyOfProsperity.simple_name)
          if pc.quest_completed?(Q00222_TestOfTheDuelist.simple_name) || pc.quest_completed?(Q00223_TestOfTheChampion.simple_name) || pc.quest_completed?(Q00224_TestOfSagittarius.simple_name) || pc.quest_completed?(Q00225_TestOfTheSearcher.simple_name) || pc.quest_completed?(Q00226_TestOfTheHealer.simple_name) || pc.quest_completed?(Q00227_TestOfTheReformer.simple_name) || pc.quest_completed?(Q00228_TestOfMagus.simple_name) || pc.quest_completed?(Q00229_TestOfWitchcraft.simple_name) || pc.quest_completed?(Q00230_TestOfTheSummoner.simple_name) || pc.quest_completed?(Q00231_TestOfTheMaestro.simple_name) || pc.quest_completed?(Q00232_TestOfTheLord.simple_name) || pc.quest_completed?(Q00233_TestOfTheWarSpirit.simple_name)
            qs.set_memo_state_ex(1, 2)
          else
            qs.set_memo_state_ex(1, 1)
          end
        elsif pc.quest_completed?(Q00222_TestOfTheDuelist.simple_name) || pc.quest_completed?(Q00223_TestOfTheChampion.simple_name) || pc.quest_completed?(Q00224_TestOfSagittarius.simple_name) || pc.quest_completed?(Q00225_TestOfTheSearcher.simple_name) || pc.quest_completed?(Q00226_TestOfTheHealer.simple_name) || pc.quest_completed?(Q00227_TestOfTheReformer.simple_name) || pc.quest_completed?(Q00228_TestOfMagus.simple_name) || pc.quest_completed?(Q00229_TestOfWitchcraft.simple_name) || pc.quest_completed?(Q00230_TestOfTheSummoner.simple_name) || pc.quest_completed?(Q00231_TestOfTheMaestro.simple_name) || pc.quest_completed?(Q00232_TestOfTheLord.simple_name) || pc.quest_completed?(Q00233_TestOfTheWarSpirit.simple_name)
          qs.set_memo_state_ex(1, 1)
        end
        html = "31092-02.html"
      end
    when "REPLY_2"
      if qs.memo_state?(10)
        if qs.get_memo_state_ex(1) >= 3
          html = "31092-03b.html"
        elsif qs.get_memo_state_ex(1) >= 1
          html = "31092-03.html"
        else
          html = "31092-03a.html"
        end
      end
    when "REPLY_3"
      if qs.memo_state?(10)
        if qs.get_memo_state_ex(1) >= 3
          give_items(pc, Inventory::ADENA_ID, THREE_MILLION)
          html = "31092-04a.html"
        elsif qs.get_memo_state_ex(1) == 2
          give_items(pc, Inventory::ADENA_ID, TWO_MILLION)
          html = "31092-04b.html"
        elsif qs.get_memo_state_ex(1) == 1
          give_items(pc, Inventory::ADENA_ID, ONE_MILLION)
          html = "31092-04b.html"
        end
        qs.exit_quest(false, true)
      end
    when "REPLY_4"
      if qs.memo_state?(10)
        case pc.class_id
        when ClassId::WARRIOR
          return "31092-05.html"
        when ClassId::KNIGHT
          return "31092-06.html"
        when ClassId::ROGUE
          return "31092-07.html"
        when ClassId::WIZARD
          return "31092-08.html"
        when ClassId::CLERIC
          return "31092-09.html"
        when ClassId::ELVEN_KNIGHT
          return "31092-10.html"
        when ClassId::ELVEN_SCOUT
          return "31092-11.html"
        when ClassId::ELVEN_WIZARD
          return "31092-12.html"
        when ClassId::ORACLE
          return "31092-13.html"
        when ClassId::PALUS_KNIGHT
          return "31092-14.html"
        when ClassId::ASSASSIN
          return "31092-15.html"
        when ClassId::DARK_WIZARD
          return "31092-16.html"
        when ClassId::SHILLIEN_ORACLE
          return "31092-17.html"
        when ClassId::ORC_RAIDER
          return "31092-18.html"
        when ClassId::ORC_MONK
          return "31092-19.html"
        when ClassId::ORC_SHAMAN
          return "31092-20.html"
        when ClassId::SCAVENGER
          return "31092-21.html"
        when ClassId::ARTISAN
          return "31092-22.html"
        else
          # [automatically added else]
        end

        qs.exit_quest(false, true)
      end
    when "REPLY_5"
      if pc.in_category?(CategoryType::SECOND_CLASS_GROUP)
        case pc.class_id
        when ClassId::WARRIOR
          return "31092-05a.html"
        when ClassId::KNIGHT
          return "31092-06a.html"
        when ClassId::ROGUE
          return "31092-07a.html"
        when ClassId::WIZARD
          return "31092-08a.html"
        when ClassId::CLERIC
          return "31092-09a.html"
        when ClassId::ELVEN_KNIGHT
          return "31092-10a.html"
        when ClassId::ELVEN_SCOUT
          return "31092-11a.html"
        when ClassId::ELVEN_WIZARD
          return "31092-12a.html"
        when ClassId::ORACLE
          return "31092-13a.html"
        when ClassId::PALUS_KNIGHT
          return "31092-14a.html"
        when ClassId::ASSASSIN
          return "31092-15a.html"
        when ClassId::DARK_WIZARD
          return "31092-16a.html"
        when ClassId::SHILLIEN_ORACLE
          return "31092-17a.html"
        when ClassId::ORC_RAIDER
          return "31092-18a.html"
        when ClassId::ORC_MONK
          return "31092-19a.html"
        when ClassId::ORC_SHAMAN
          return "31092-20a.html"
        when ClassId::SCAVENGER
          return "31092-21a.html"
        when ClassId::ARTISAN
          return "31092-22a.html"
        else
          # [automatically added else]
        end

      end
    when "REPLY_6"
      if pc.class_id.warrior?
        unless has_quest_items?(pc, MARK_OF_CHALLENGER)
          give_items(pc, MARK_OF_CHALLENGER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_TRUST)
          give_items(pc, MARK_OF_TRUST, 1)
        end
        unless has_quest_items?(pc, MARK_OF_DUELIST)
          give_items(pc, MARK_OF_DUELIST, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_7"
      if pc.class_id.warrior?
        unless has_quest_items?(pc, MARK_OF_CHALLENGER)
          give_items(pc, MARK_OF_CHALLENGER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_TRUST)
          give_items(pc, MARK_OF_TRUST, 1)
        end
        unless has_quest_items?(pc, MARK_OF_CHAMPION)
          give_items(pc, MARK_OF_CHAMPION, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_8"
      if pc.class_id.knight?
        unless has_quest_items?(pc, MARK_OF_DUTY)
          give_items(pc, MARK_OF_DUTY, 1)
        end
        unless has_quest_items?(pc, MARK_OF_TRUST)
          give_items(pc, MARK_OF_TRUST, 1)
        end
        unless has_quest_items?(pc, MARK_OF_HEALER)
          give_items(pc, MARK_OF_HEALER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_9"
      if pc.class_id.knight?
        unless has_quest_items?(pc, MARK_OF_DUTY)
          give_items(pc, MARK_OF_DUTY, 1)
        end
        unless has_quest_items?(pc, MARK_OF_TRUST)
          give_items(pc, MARK_OF_TRUST, 1)
        end
        unless has_quest_items?(pc, MARK_OF_WITCHCRAFT)
          give_items(pc, MARK_OF_WITCHCRAFT, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_10"
      if pc.class_id.rogue?
        unless has_quest_items?(pc, MARK_OF_SEEKER)
          give_items(pc, MARK_OF_SEEKER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_TRUST)
          give_items(pc, MARK_OF_TRUST, 1)
        end
        unless has_quest_items?(pc, MARK_OF_SEARCHER)
          give_items(pc, MARK_OF_SEARCHER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_11"
      if pc.class_id.rogue?
        unless has_quest_items?(pc, MARK_OF_SEEKER)
          give_items(pc, MARK_OF_SEEKER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_TRUST)
          give_items(pc, MARK_OF_TRUST, 1)
        end
        unless has_quest_items?(pc, MARK_OF_SAGITTARIUS)
          give_items(pc, MARK_OF_SAGITTARIUS, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_12"
      if pc.class_id.wizard?
        unless has_quest_items?(pc, MARK_OF_SCHOLAR)
          give_items(pc, MARK_OF_SCHOLAR, 1)
        end
        unless has_quest_items?(pc, MARK_OF_TRUST)
          give_items(pc, MARK_OF_TRUST, 1)
        end
        unless has_quest_items?(pc, MARK_OF_MAGUS)
          give_items(pc, MARK_OF_MAGUS, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_13"
      if pc.class_id.wizard?
        unless has_quest_items?(pc, MARK_OF_SCHOLAR)
          give_items(pc, MARK_OF_SCHOLAR, 1)
        end
        unless has_quest_items?(pc, MARK_OF_TRUST)
          give_items(pc, MARK_OF_TRUST, 1)
        end
        unless has_quest_items?(pc, MARK_OF_WITCHCRAFT)
          give_items(pc, MARK_OF_WITCHCRAFT, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_14"
      if pc.class_id.wizard?
        unless has_quest_items?(pc, MARK_OF_SCHOLAR)
          give_items(pc, MARK_OF_SCHOLAR, 1)
        end
        unless has_quest_items?(pc, MARK_OF_TRUST)
          give_items(pc, MARK_OF_TRUST, 1)
        end
        unless has_quest_items?(pc, MARK_OF_SUMMONER)
          give_items(pc, MARK_OF_SUMMONER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_15"
      if pc.class_id.cleric?
        unless has_quest_items?(pc, MARK_OF_PILGRIM)
          give_items(pc, MARK_OF_PILGRIM, 1)
        end
        unless has_quest_items?(pc, MARK_OF_TRUST)
          give_items(pc, MARK_OF_TRUST, 1)
        end
        unless has_quest_items?(pc, MARK_OF_HEALER)
          give_items(pc, MARK_OF_HEALER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_16"
      if pc.class_id.cleric?
        unless has_quest_items?(pc, MARK_OF_PILGRIM)
          give_items(pc, MARK_OF_PILGRIM, 1)
        end
        unless has_quest_items?(pc, MARK_OF_TRUST)
          give_items(pc, MARK_OF_TRUST, 1)
        end
        unless has_quest_items?(pc, MARK_OF_REFORMER)
          give_items(pc, MARK_OF_REFORMER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_17"
      if pc.class_id.elven_knight?
        unless has_quest_items?(pc, MARK_OF_DUTY)
          give_items(pc, MARK_OF_DUTY, 1)
        end
        unless has_quest_items?(pc, MARK_OF_LIFE)
          give_items(pc, MARK_OF_LIFE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_HEALER)
          give_items(pc, MARK_OF_HEALER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_18"
      if pc.class_id.elven_knight?
        unless has_quest_items?(pc, MARK_OF_CHALLENGER)
          give_items(pc, MARK_OF_CHALLENGER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_LIFE)
          give_items(pc, MARK_OF_LIFE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_DUELIST)
          give_items(pc, MARK_OF_DUELIST, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_19"
      if pc.class_id.elven_scout?
        unless has_quest_items?(pc, MARK_OF_SEEKER)
          give_items(pc, MARK_OF_SEEKER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_LIFE)
          give_items(pc, MARK_OF_LIFE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_SEARCHER)
          give_items(pc, MARK_OF_SEARCHER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_20"
      if pc.class_id.elven_scout?
        unless has_quest_items?(pc, MARK_OF_SEEKER)
          give_items(pc, MARK_OF_SEEKER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_LIFE)
          give_items(pc, MARK_OF_LIFE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_SAGITTARIUS)
          give_items(pc, MARK_OF_SAGITTARIUS, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_21"
      if pc.class_id.elven_wizard?
        unless has_quest_items?(pc, MARK_OF_SCHOLAR)
          give_items(pc, MARK_OF_SCHOLAR, 1)
        end
        unless has_quest_items?(pc, MARK_OF_LIFE)
          give_items(pc, MARK_OF_LIFE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_MAGUS)
          give_items(pc, MARK_OF_MAGUS, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_22"
      if pc.class_id.elven_wizard?
        unless has_quest_items?(pc, MARK_OF_SCHOLAR)
          give_items(pc, MARK_OF_SCHOLAR, 1)
        end
        unless has_quest_items?(pc, MARK_OF_LIFE)
          give_items(pc, MARK_OF_LIFE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_SUMMONER)
          give_items(pc, MARK_OF_SUMMONER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_23"
      if pc.class_id.oracle?
        unless has_quest_items?(pc, MARK_OF_PILGRIM)
          give_items(pc, MARK_OF_PILGRIM, 1)
        end
        unless has_quest_items?(pc, MARK_OF_LIFE)
          give_items(pc, MARK_OF_LIFE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_HEALER)
          give_items(pc, MARK_OF_HEALER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_24"
      if pc.class_id.palus_knight?
        unless has_quest_items?(pc, MARK_OF_DUTY)
          give_items(pc, MARK_OF_DUTY, 1)
        end
        unless has_quest_items?(pc, MARK_OF_FATE)
          give_items(pc, MARK_OF_FATE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_WITCHCRAFT)
          give_items(pc, MARK_OF_WITCHCRAFT, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_25"
      if pc.class_id.palus_knight?
        unless has_quest_items?(pc, MARK_OF_CHALLENGER)
          give_items(pc, MARK_OF_CHALLENGER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_FATE)
          give_items(pc, MARK_OF_FATE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_DUELIST)
          give_items(pc, MARK_OF_DUELIST, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_26"
      if pc.class_id.assassin?
        unless has_quest_items?(pc, MARK_OF_SEEKER)
          give_items(pc, MARK_OF_SEEKER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_FATE)
          give_items(pc, MARK_OF_FATE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_SEARCHER)
          give_items(pc, MARK_OF_SEARCHER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_27"
      if pc.class_id.assassin?
        unless has_quest_items?(pc, MARK_OF_SEEKER)
          give_items(pc, MARK_OF_SEEKER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_FATE)
          give_items(pc, MARK_OF_FATE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_SAGITTARIUS)
          give_items(pc, MARK_OF_SAGITTARIUS, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_28"
      if pc.class_id.dark_wizard?
        unless has_quest_items?(pc, MARK_OF_SCHOLAR)
          give_items(pc, MARK_OF_SCHOLAR, 1)
        end
        unless has_quest_items?(pc, MARK_OF_FATE)
          give_items(pc, MARK_OF_FATE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_MAGUS)
          give_items(pc, MARK_OF_MAGUS, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_29"
      if pc.class_id.dark_wizard?
        unless has_quest_items?(pc, MARK_OF_SCHOLAR)
          give_items(pc, MARK_OF_SCHOLAR, 1)
        end
        unless has_quest_items?(pc, MARK_OF_FATE)
          give_items(pc, MARK_OF_FATE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_SUMMONER)
          give_items(pc, MARK_OF_SUMMONER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_30"
      if pc.class_id.shillien_oracle?
        unless has_quest_items?(pc, MARK_OF_PILGRIM)
          give_items(pc, MARK_OF_PILGRIM, 1)
        end
        unless has_quest_items?(pc, MARK_OF_FATE)
          give_items(pc, MARK_OF_FATE, 1)
        end
        unless has_quest_items?(pc, MARK_OF_REFORMER)
          give_items(pc, MARK_OF_REFORMER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_31"
      if pc.class_id.orc_raider?
        unless has_quest_items?(pc, MARK_OF_CHALLENGER)
          give_items(pc, MARK_OF_CHALLENGER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_GLORY)
          give_items(pc, MARK_OF_GLORY, 1)
        end
        unless has_quest_items?(pc, MARK_OF_CHAMPION)
          give_items(pc, MARK_OF_CHAMPION, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_32"
      if pc.class_id.orc_monk?
        unless has_quest_items?(pc, MARK_OF_CHALLENGER)
          give_items(pc, MARK_OF_CHALLENGER, 1)
        end
        unless has_quest_items?(pc, MARK_OF_GLORY)
          give_items(pc, MARK_OF_GLORY, 1)
        end
        unless has_quest_items?(pc, MARK_OF_DUELIST)
          give_items(pc, MARK_OF_DUELIST, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_33"
      if pc.class_id.orc_shaman?
        unless has_quest_items?(pc, MARK_OF_PILGRIM)
          give_items(pc, MARK_OF_PILGRIM, 1)
        end
        unless has_quest_items?(pc, MARK_OF_GLORY)
          give_items(pc, MARK_OF_GLORY, 1)
        end
        unless has_quest_items?(pc, MARK_OF_LORD)
          give_items(pc, MARK_OF_LORD, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_34"
      if pc.class_id.orc_shaman?
        unless has_quest_items?(pc, MARK_OF_PILGRIM)
          give_items(pc, MARK_OF_PILGRIM, 1)
        end
        unless has_quest_items?(pc, MARK_OF_GLORY)
          give_items(pc, MARK_OF_GLORY, 1)
        end
        unless has_quest_items?(pc, MARK_OF_WARSPIRIT)
          give_items(pc, MARK_OF_WARSPIRIT, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_35"
      if pc.class_id.scavenger?
        unless has_quest_items?(pc, MARK_OF_GUILDSMAN)
          give_items(pc, MARK_OF_GUILDSMAN, 1)
        end
        unless has_quest_items?(pc, MARK_OF_PROSPERITY)
          give_items(pc, MARK_OF_PROSPERITY, 1)
        end
        unless has_quest_items?(pc, MARK_OF_SEARCHER)
          give_items(pc, MARK_OF_SEARCHER, 1)
        end
        html = "31092-25.html"
      end
    when "REPLY_36"
      if pc.class_id.artisan?
        unless has_quest_items?(pc, MARK_OF_GUILDSMAN)
          give_items(pc, MARK_OF_GUILDSMAN, 1)
        end
        unless has_quest_items?(pc, MARK_OF_PROSPERITY)
          give_items(pc, MARK_OF_PROSPERITY, 1)
        end
        unless has_quest_items?(pc, MARK_OF_MAESTRO)
          give_items(pc, MARK_OF_MAESTRO, 1)
        end
        html = "31092-25.html"
      end
    when "32487-04.html"
      if qs.memo_state?(1)
        npc = npc.not_nil!
        if !npc.variables.get_bool("SPAWNED", false)
          npc.variables["SPAWNED"] = true
          npc.variables["PLAYER_ID"] =  pc.l2id
          pursuer = add_spawn(PURSUER, pc.x + 50, pc.y + 50, pc.z, 0, false, 0)
          pursuer.variables["PLAYER_ID"] = pc.l2id
          pursuer.variables["npc0"] = npc
          pursuer.variables["pc0"] = pc
          add_attack_desire(pursuer, pc)
          html = event
        else
          html = "32487-05.html"
        end
      end
    when "32487-10.html"
      npc = npc.not_nil!
      if qs.memo_state?(7)
        take_items(pc, HELVETIAS_ANTIDOTE, 1)
        qs.memo_state = 8
        qs.set_cond(8, true)
        if npc.variables.get_bool("SPAWNED", true)
          npc.variables["SPAWNED"] = false
        end
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      if qs.memo_state?(1)
        if killer.player?
          if killer.l2id == npc.variables.get_i32("PLAYER_ID", 0)
            qs.memo_state = 2
            qs.set_cond(2, true)
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::YOU_ARE_STRONG_THIS_WAS_A_MISTAKE))
          else
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::WHO_ARE_YOU_TO_JOIN_IN_THE_BATTLE_HOW_UPSETTING))
          end
        end
      end

      if npc0 = npc.variables.get_object("npc0", L2Npc?)
        npc0.variables["SPAWNED"] = false
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == BLUEPRINT_SELLER_DAEGER
        if !pc.race.kamael?
          if pc.in_category?(CategoryType::SECOND_CLASS_GROUP)
            html = pc.level >= MIN_LEVEL ? "31435-01.htm" : "31435-03.htm"
          else
            html = "31435-04.htm"
          end
        else
          html = "31435-06.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when BLUEPRINT_SELLER_DAEGER
        if memo_state <= 2
          html = "31435-08.html"
        elsif memo_state == 3
          html = "31435-09.html"
        elsif memo_state == 4
          html = "31435-11.html"
        elsif memo_state > 4 && memo_state < 8
          html = "31435-12.html"
        elsif memo_state == 8
          html = "31435-13.html"
        elsif memo_state == 9
          qs.memo_state = 10
          qs.set_cond(10, true)
          html = "31435-15.html"
        elsif memo_state == 10
          html = "31435-16.html"
        end
      when GROCER_HELVETIA
        if memo_state == 4
          html = "30081-01.html"
        elsif memo_state == 5
          html = "30081-04.html"
        elsif memo_state == 6
          html = "30081-08.html"
        elsif memo_state == 7
          if !has_quest_items?(pc, HELVETIAS_ANTIDOTE)
            give_items(pc, HELVETIAS_ANTIDOTE, 1)
            html = "30081-09.html"
          else
            html = "30081-10.html"
          end
        end
      when BLACK_MARKETEER_OF_MAMMON
        if memo_state == 10
          if pc.in_category?(CategoryType::SECOND_CLASS_GROUP)
            qs.set_memo_state_ex(1, 0)
            html = "31092-01.html"
          else
            give_items(pc, Inventory::ADENA_ID, THREE_MILLION)
            qs.exit_quest(false, true)
            html = "31092-01a.html"
          end
        end
      when MARK
        if memo_state == 1
          if !npc.variables.get_bool("SPAWNED", false)
            html = "32487-01.html"
          elsif npc.variables.get_bool("SPAWNED", true) && npc.variables.get_i32("PLAYER_ID", 0) == pc.l2id
            html = "32487-03.html"
          elsif npc.variables.get_bool("SPAWNED", true)
            html = "32487-02.html"
          end
        elsif memo_state == 2
          give_items(pc, BLOODY_CLOTH_FRAGMENT, 1)
          qs.memo_state = 3
          qs.set_cond(3, true)
          html = "32487-06.html"
        elsif memo_state >= 3 && memo_state < 7
          html = "32487-07.html"
        elsif memo_state == 7
          html = "32487-09.html"
        end
      else
        # [automatically added else]
      end

    elsif qs.completed?
      if npc.id == BLUEPRINT_SELLER_DAEGER
        html = get_already_completed_msg(pc)
      elsif npc.id == BLACK_MARKETEER_OF_MAMMON
        if pc.in_category?(CategoryType::SECOND_CLASS_GROUP)
          html = "31092-23.html"
        else
          html = "31092-24.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_spawn(npc)
    start_quest_timer("DESPAWN", 60000, npc, nil)
    if pc = npc.variables.get_object("pc0", L2PcInstance?)
      npc_str = NpcString::S1_I_MUST_KILL_YOU_BLAME_YOUR_OWN_CURIOSITY
      say = NpcSay.new(npc, Say2::NPC_ALL, npc_str)
      say.add_string_parameter(pc.appearance.visible_name)
      npc.broadcast_packet(say)
    end

    super
  end
end
