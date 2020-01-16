class Scripts::Q00631_DeliciousTopChoiceMeat < Quest
  # NPC
  private TUNATUN = 31537
  # Items
  private TOP_QUALITY_MEAT = 7546
  private PRIME_MEAT = 15534
  # Misc
  private MIN_LEVEL = 82
  private PRIME_MEAT_COUNT = 120
  # Rewards
  private RECIPE = {
    10373, # Recipe - Icarus Sawsword (60%)
    10374, # Recipe - Icarus Disperser (60%)
    10375, # Recipe - Icarus Spirit (60%)
    10376, # Recipe - Icarus Heavy Arms (60%)
    10377, # Recipe - Icarus Trident (60%)
    10378, # Recipe - Icarus Hammer (60%)
    10379, # Recipe - Icarus Hand (60%)
    10380, # Recipe - Icarus Hall (60%)
    10381  # Recipe - Icarus Spitter (60%)
  }

  private PIECE = {
    10397, # Icarus Sawsword Piece
    10398, # Icarus Disperser Piece
    10399, # Icarus Spirit Piece
    10400, # Icarus Heavy Arms Piece
    10401, # Icarus Trident Piece
    10402, # Icarus Hammer Piece
    10403, # Icarus Hand Piece
    10404, # Icarus Hall Piece
    10405  # Icarus Spitter Piece
  }

  private GOLDEN_SPICE_CRATE = 15482
  private CRYSTAL_SPICE_COMPRESSED_PACK = 15483

  private MOBS_MEAT = {
    18878 => 0.172, # Full Grown Kookaburra
    18879 => 0.334, # Full Grown Kookaburra
    18885 => 0.172, # Full Grown Cougar
    18886 => 0.334, # Full Grown Cougar
    18892 => 0.182, # Full Grown Buffalo
    18893 => 0.349, # Full Grown Buffalo
    18899 => 0.182, # Full Grown Grendel
    18900 => 0.349  # Full Grown Grendel
  }

  def initialize
    super(631, self.class.simple_name, "Delicious Top Choice Meat")

    add_start_npc(TUNATUN)
    add_talk_id(TUNATUN)
    add_kill_id(MOBS_MEAT.keys)
    register_quest_items(TOP_QUALITY_MEAT, PRIME_MEAT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "quest_accept"
      if pc.level >= MIN_LEVEL
        st.start_quest
        html = "31537-02.html"
      else
        html = "31537-03.html"
      end
    when "31537-06.html"
      if st.cond?(2)
        if get_quest_items_count(pc, PRIME_MEAT) >= PRIME_MEAT_COUNT
          case Rnd.rand(10)
          when 0
            st.reward_items(RECIPE.sample(random: Rnd), 1)
          when 1
            st.reward_items(PIECE.sample(random: Rnd), 1)
          when 2
            st.reward_items(PIECE.sample(random: Rnd), 2)
          when 3
            st.reward_items(PIECE.sample(random: Rnd), 3)
          when 4
            st.reward_items(PIECE.sample(random: Rnd), Rnd.rand(5) + 2)
          when 5
            st.reward_items(PIECE.sample(random: Rnd), Rnd.rand(7) + 2)
          when 6
            st.reward_items(GOLDEN_SPICE_CRATE, 1)
          when 7
            st.reward_items(GOLDEN_SPICE_CRATE, 2)
          when 8
            st.reward_items(CRYSTAL_SPICE_COMPRESSED_PACK, 1)
          when 9
            st.reward_items(CRYSTAL_SPICE_COMPRESSED_PACK, 2)
          end
          st.exit_quest(true, true)
          html = event
        end
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if st = get_random_party_member_state(pc, 1, 3, npc)
      if st.give_item_randomly(npc, PRIME_MEAT, 1, PRIME_MEAT_COUNT, MOBS_MEAT[npc.id], true)
        st.set_cond(2, true)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if st.created?
      html = "31537-01.htm"
    elsif st.started?
      if st.cond?(1)
        if st.get_quest_items_count(PRIME_MEAT) < PRIME_MEAT_COUNT
          html = "31537-04.html"
        end
      elsif st.cond?(2)
        if st.get_quest_items_count(PRIME_MEAT) >= PRIME_MEAT_COUNT
          html = "31537-05.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
