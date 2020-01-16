class Scripts::Q00235_MimirsElixir < Quest
  # NPCs
  private JOAN = 30718
  private LADD = 30721
  private ALCHEMISTS_MIXING_URN = 31149
  # Items
  private STAR_OF_DESTINY = 5011
  private MAGISTERS_MIXING_STONE = 5905
  private BLOOD_FIRE = 6318
  private MIMIRS_ELIXIR = 6319
  private PURE_SILVER = 6320
  private TRUE_GOLD = 6321
  private SAGES_STONE = 6322
  # Reward
  private ENCHANT_WEAPON_A = 729
  # Misc
  private MIN_LEVEL = 75
  # Skill
  private QUEST_MIMIRS_ELIXIR = SkillHolder.new(4339)
  # Mobs
  private MOBS = {
    20965 => QuestItemHolder.new(SAGES_STONE, 4, 1), # chimera_piece
    21090 => QuestItemHolder.new(BLOOD_FIRE, 7, 1)   # bloody_guardian
  }

  def initialize
    super(235, self.class.simple_name, "Mimir's Elixir")

    add_start_npc(LADD)
    add_talk_id(LADD, JOAN, ALCHEMISTS_MIXING_URN)
    add_kill_id(MOBS.keys)
    register_quest_items(
      MAGISTERS_MIXING_STONE, BLOOD_FIRE, MIMIRS_ELIXIR, TRUE_GOLD, SAGES_STONE
    )
  end

  def check_party_member(pc, npc) : Bool
    return false unless st = get_quest_state(pc, false)
    return st.memo_state?(3) || st.memo_state?(6)
  end

  def on_adv_event(event, npc, player)
    npc = npc.not_nil!

    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    html = nil
    case event
    when "30721-02.htm", "30721-03.htm", "30721-04.htm", "30721-05.htm"
      html = event
    when "30721-06.htm"
      st.memo_state = 1
      st.start_quest
      html = event
    when "30721-12.html"
      if st.memo_state?(1)
        st.memo_state = 2
        st.set_cond(2)
        html = event
      end
    when "30721-15.html"
      if st.memo_state?(5)
        give_items(player, MAGISTERS_MIXING_STONE, 1)
        st.memo_state = 6
        st.set_cond(6)
        html = event
      end
    when "30721-18.html"
      if st.memo_state?(8)
        html = event
      end
    when "30721-19.html"
      if st.memo_state?(8)
        if has_quest_items?(player, MAGISTERS_MIXING_STONE, MIMIRS_ELIXIR)
          npc.target = player
          npc.do_cast(QUEST_MIMIRS_ELIXIR)
          take_items(player, STAR_OF_DESTINY, -1)
          reward_items(player, ENCHANT_WEAPON_A, 1)
          st.exit_quest(false, true)
          player.send_packet(SocialAction.new(player.l2id, 3))
          html = event
        end
      end
    when "30718-02.html"
      if st.memo_state?(2)
        html = event
      end
    when "30718-03.html"
      if st.memo_state?(2)
        st.memo_state = 3
        st.set_cond(3, true)
        html = event
      end
    when "30718-06.html"
      if st.memo_state?(4) && has_quest_items?(player, SAGES_STONE)
        give_items(player, TRUE_GOLD, 1)
        take_items(player, SAGES_STONE, -1)
        st.memo_state = 5
        st.set_cond(5, true)
        html = event
      end
    when "31149-02.html", "31149-05.html", "31149-07.html", "31149-09.html",
         "31149-10.html"
      if st.memo_state?(7)
        html = event
      end
    when "PURE_SILVER"
      if st.memo_state?(7)
        if has_quest_items?(player, PURE_SILVER)
          html = "31149-04.html"
        else
          html = "31149-03.html"
        end
      end
    when "TRUE_GOLD"
      if st.memo_state?(7)
        if has_quest_items?(player, TRUE_GOLD)
          html = "31149-06.html"
        else
          html = "31149-03.html"
        end
      end
    when "BLOOD_FIRE"
      if st.memo_state?(7)
        if has_quest_items?(player, BLOOD_FIRE)
          html = "31149-08.html"
        else
          html = "31149-03.html"
        end
      end
    when "31149-11.html"
      if st.memo_state?(7)
        if has_quest_items?(player, BLOOD_FIRE, PURE_SILVER, TRUE_GOLD)
          give_items(player, MIMIRS_ELIXIR, 1)
          take_items(player, -1, {BLOOD_FIRE, PURE_SILVER, TRUE_GOLD})
          st.memo_state = 8
          st.set_cond(8, true)
          html = event
        end
      end
    end

    html
  end

  def on_kill(npc, player, is_summon)
    if Rnd.rand(5) == 0
      if winner = get_random_party_member(player, npc)
        item = MOBS[npc.id]
        if give_item_randomly(winner, npc, item.id, item.count, item.count, 1.0, true)
          st = winner.get_quest_state(name).not_nil!
          st.memo_state = item.chance
          st.set_cond(item.chance)
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    if st.created?
      if npc.id == LADD
        if player.race.kamael?
          html = "30721-09.html"
        elsif player.level < MIN_LEVEL
          html = "30721-08.html"
        else
          if has_quest_items?(player, STAR_OF_DESTINY)
            html = "30721-01.htm"
          else
            html = "30721-07.html"
          end
        end
      end
    elsif st.started?
      case npc.id
      when LADD
        case st.memo_state
        when 1
          if has_quest_items?(player, PURE_SILVER)
            html = "30721-11.html"
          else
            html = "30721-10.html"
          end
        when 2..4
          html = "30721-13.html"
        when 5
          html = "30721-14.html"
        when 6, 7
          html = "30721-16.html"
        when 8
          html = "30721-17.html"
        end
      when JOAN
        case st.memo_state
        when 2
          html = "30718-01.html"
        when 3
          html = "30718-04.html"
        when 4
          html = "30718-05.html"
        end
      when ALCHEMISTS_MIXING_URN
        if st.memo_state?(7) && has_quest_items?(player, MAGISTERS_MIXING_STONE)
          html = "31149-01.html"
        end
      end
    elsif st.completed?
      if npc.id == LADD
        html = get_already_completed_msg(player)
      end
    end

    html || get_no_quest_msg(player)
  end
end
