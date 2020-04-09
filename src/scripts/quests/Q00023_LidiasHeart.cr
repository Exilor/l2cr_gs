class Scripts::Q00023_LidiasHeart < Quest
  # NPCs
  private HIGH_PRIEST_INNOCENTIN = 31328
  private TRADER_VIOLET = 31386
  private TOMBSTONE = 31523
  private GHOST_OF_VON_HELLMANN = 31524
  private BROKEN_BOOKSHELF = 31526
  private BOX = 31530
  # Items
  private LIDIAS_DIARY = 7064
  private SILVER_KEY = 7149
  private SILVER_SPEAR = 7150
  # Reward
  private MAP_FOREST_OF_THE_DEAD = 7063
  private LIDIAS_HAIRPIN = 7148
  # Misc
  private MIN_LEVEL = 64
  # Locations
  private GHOST_SPAWN = Location.new(51432, -54570, -3136)

  def initialize
    super(23, self.class.simple_name, "Lidia's Heart")

    add_start_npc(HIGH_PRIEST_INNOCENTIN)
    add_talk_id(
      HIGH_PRIEST_INNOCENTIN, TRADER_VIOLET, TOMBSTONE, GHOST_OF_VON_HELLMANN,
      BROKEN_BOOKSHELF, BOX
    )
    add_spawn_id(GHOST_OF_VON_HELLMANN)
    register_quest_items(LIDIAS_DIARY, SILVER_KEY, SILVER_SPEAR)
  end

  def on_adv_event(event, npc, pc)
    if event == "DESPAWN"
      npc = npc.not_nil!
      if npc0 = npc.variables.get_object("npc0", L2Npc?)
        npc0.variables["SPAWNED"] = false
      end
      npc.delete_me
      return super
    end

    return unless pc
    qs = get_quest_state(pc, false)
    if qs.nil?
      return
    end

    case event
    when "ACCEPT"
      if pc.level < MIN_LEVEL
        html = "31328-02.htm"
      else
        unless has_quest_items?(pc, MAP_FOREST_OF_THE_DEAD)
          give_items(pc, MAP_FOREST_OF_THE_DEAD, 1)
        end
        give_items(pc, SILVER_KEY, 1)
        qs.start_quest
        qs.memo_state = 1
        html = "31328-03.htm"
      end
    when "31328-05.html", "31328-06.html", "31328-10.html", "31328-11.html",
         "31328-16.html", "31328-17.html", "31328-18.html", "31524-03.html",
         "31526-04.html", "31526-05.html", "31526-07a.html", "31526-09.html"
      html = event
    when "31328-07.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = event
      end
    when "31328-12.html"
      if qs.memo_state?(5) || qs.memo_state?(6)
        qs.memo_state = 6
        qs.set_cond(5)
        html = event
      end
    when "31328-13.html"
      if qs.memo_state?(5) || qs.memo_state?(6)
        qs.memo_state = 7
        html = event
      end
    when "31328-19.html"
      play_sound(pc, Sound::AMBSOUND_MT_CREAK)
      html = event
    when "31328-20.html"
      if qs.memo_state?(7)
        qs.memo_state = 8
        qs.set_cond(6)
        html = event
      end
    when "31328-21.html"
      qs.set_cond(5)
      html = event
    when "31523-02.html"
      if qs.memo_state?(8) || qs.memo_state?(9)
        npc = npc.not_nil!
        play_sound(pc, Sound::SKILLSOUND_HORROR_02)
        if !npc.variables.get_bool("SPAWNED", false)
          npc.variables["SPAWNED"] = true
          ghost = add_spawn(npc, GHOST_OF_VON_HELLMANN, GHOST_SPAWN, false, 0)
          ghost.variables["npc0"] = npc
          html = event
        else
          html = "31523-03.html"
        end
      end
    when "31523-06.html"
      if qs.memo_state?(9)
        give_items(pc, SILVER_KEY, 1)
        qs.memo_state = 10
        qs.set_cond(8)
        html = event
      end
    when "31524-02.html"
      play_sound(pc, Sound::CHRSOUND_MHFIGHTER_CRY)
      html = event
    when "31524-04.html"
      if qs.memo_state?(8)
        take_items(pc, LIDIAS_DIARY, 1)
        qs.memo_state = 9
        qs.set_cond(7)
        html = event
      end
    when "31526-02.html"
      if qs.memo_state?(2) && has_quest_items?(pc, SILVER_KEY)
        take_items(pc, SILVER_KEY, -1)
        qs.memo_state = 3
        html = event
      end
    when "31526-06.html"
      unless has_quest_items?(pc, LIDIAS_HAIRPIN)
        give_items(pc, LIDIAS_HAIRPIN, 1)
      end
      qs.memo_state += 1
      if has_quest_items?(pc, LIDIAS_DIARY)
        qs.set_cond(4)
      end
      html = event
    when "31526-08.html"
      play_sound(pc, Sound::ITEMSOUND_ARMOR_LEATHER)
      html = event
    when "31526-10.html"
      play_sound(pc, Sound::AMBSOUND_EG_DRON)
      html = event
    when "31526-11.html"
      give_items(pc, LIDIAS_DIARY, 1)
      qs.memo_state += 1
      if has_quest_items?(pc, LIDIAS_HAIRPIN)
        qs.set_cond(4)
      end
      html = event
    when "31530-02.html"
      if qs.memo_state?(11) && has_quest_items?(pc, SILVER_KEY)
        give_items(pc, SILVER_SPEAR, 1)
        take_items(pc, SILVER_KEY, -1)
        play_sound(pc, Sound::ITEMSOUND_WEAPON_SPEAR)
        qs.set_cond(10)
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == HIGH_PRIEST_INNOCENTIN
        if pc.quest_completed?(Q00022_TragedyInVonHellmannForest.simple_name)
          html = "31328-01.htm"
        else
          html = "31328-01a.html"
        end
      end
    elsif qs.started?
      case npc.id
      when HIGH_PRIEST_INNOCENTIN
        case qs.memo_state
        when 1
          html = "31328-04.html"
        when 2
          html = "31328-08.html"
        when 5
          html = "31328-09.html"
        when 6
          html = "31328-14.html"
        when 7
          html = "31328-15.html"
        when 8
          qs.set_cond(6, true)
          html = "31328-22.html"
        else
          # [automatically added else]
        end

      when TRADER_VIOLET
        case qs.memo_state
        when 10
          if has_quest_items?(pc, SILVER_KEY)
            qs.memo_state = 11
            qs.set_cond(9, true)
            html = "31386-01.html"
          end
        when 11
          if !has_quest_items?(pc, SILVER_SPEAR)
            html = "31386-02.html"
          else
            give_adena(pc, 350000, true)
            add_exp_and_sp(pc, 456893, 42112)
            qs.exit_quest(false, true)
            html = "31386-03.html"
          end
        else
          # [automatically added else]
        end

      when TOMBSTONE
        case qs.memo_state
        when 8
          html = "31523-01.html"
        when 9
          html = "31523-04.html"
        when 10
          html = "31523-05.html"
        else
          # [automatically added else]
        end

      when GHOST_OF_VON_HELLMANN
        memo_state = qs.memo_state
        if memo_state == 8
          html = "31524-01.html"
        elsif memo_state == 9
          unless has_quest_items?(pc, SILVER_KEY)
            html = "31524-05.html"
          end
        elsif memo_state == 9 || memo_state == 10
          if has_quest_items?(pc, SILVER_KEY)
            qs.memo_state = 10
            html = "31524-06.html"
          end
        end
      when BROKEN_BOOKSHELF
        case qs.memo_state
        when 2
          if has_quest_items?(pc, SILVER_KEY)
            qs.set_cond(3, true)
            html = "31526-01.html"
          end
        when 3
          html = "31526-03.html"
        when 4
          if has_quest_items?(pc, LIDIAS_HAIRPIN)
            html = "31526-07.html"
          elsif has_quest_items?(pc, LIDIAS_DIARY)
            html = "31526-12.html"
          end
        when 5
          if has_quest_items?(pc, LIDIAS_HAIRPIN, LIDIAS_DIARY)
            html = "31526-13.html"
          end
        else
          # [automatically added else]
        end

      when BOX
        if qs.memo_state == 11
          if has_quest_items?(pc, SILVER_KEY)
            html = "31530-01.html"
          elsif has_quest_items?(pc, SILVER_SPEAR)
            html = "31530-03.html"
          end
        end
      else
        # [automatically added else]
      end

    elsif qs.completed?
      if npc.id == HIGH_PRIEST_INNOCENTIN
        html = get_already_completed_msg(pc)
      elsif npc.id == TRADER_VIOLET
        unless q24 = pc.get_quest_state(Q00024_InhabitantsOfTheForestOfTheDead.simple_name)
          html = "31386-04.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_spawn(npc)
    start_quest_timer("DESPAWN", 300_000, npc, nil)
    npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::WHO_AWOKE_ME))

    super
  end
end
