class Scripts::Q00406_PathOfTheElvenKnight < Quest
  # NPCs
  private BLACKSMITH_KLUTO = 30317
  private MASTER_SORIUS = 30327
  # Items
  private SORIUS_LETTER = 1202
  private KLUTO_BOX = 1203
  private TOPAZ_PIECE = 1205
  private EMERALD_PIECE = 1206
  private KLUTO_MEMO = 1276
  # Reward
  private ELVEN_KNIGHT_BROOCH = 1204
  # Misc
  private MIN_LEVEL = 18
  # Mobs
  private OL_MAHUM_NOVICE = 20782
  private MONSTER_DROPS = {
    20035 => ItemChanceHolder.new(TOPAZ_PIECE, 70), # Tracker Skeleton
    20042 => ItemChanceHolder.new(TOPAZ_PIECE, 70), # Tracker Skeleton Leader
    20045 => ItemChanceHolder.new(TOPAZ_PIECE, 70), # Skeleton Scout
    20051 => ItemChanceHolder.new(TOPAZ_PIECE, 70), # Skeleton Bowman
    20054 => ItemChanceHolder.new(TOPAZ_PIECE, 70), # Ruin Spartoi
    20060 => ItemChanceHolder.new(TOPAZ_PIECE, 70), # Salamander Noble
    OL_MAHUM_NOVICE => ItemChanceHolder.new(EMERALD_PIECE, 50) # Ol Mahum Novice
  }

  def initialize
    super(406, self.class.simple_name, "Path Of The Elven Knight")

    add_start_npc(MASTER_SORIUS)
    add_talk_id(MASTER_SORIUS, BLACKSMITH_KLUTO)
    add_kill_id(MONSTER_DROPS.keys)
    register_quest_items(
      SORIUS_LETTER, KLUTO_BOX, TOPAZ_PIECE, EMERALD_PIECE, KLUTO_MEMO
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if !pc.class_id.elven_fighter?
        if pc.class_id.elven_knight?
          html = "30327-02a.htm"
        else
          html = "30327-02.htm"
        end
      elsif pc.level < MIN_LEVEL
        html = "30327-03.htm"
      elsif has_quest_items?(pc, ELVEN_KNIGHT_BROOCH)
        html = "30327-04.htm"
      else
        html = "30327-05.htm"
      end
    when "30327-06.htm"
      qs.start_quest
      html = event
    when "30317-02.html"
      take_items(pc, SORIUS_LETTER, 1)
      unless has_quest_items?(pc, KLUTO_MEMO)
        give_items(pc, KLUTO_MEMO, 1)
      end
      qs.set_cond(4, true)
      html = event
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    reward = MONSTER_DROPS[npc.id]
    req_item_id = KLUTO_BOX
    cond = 2
    check = !has_quest_items?(killer, req_item_id)
    if npc.id == OL_MAHUM_NOVICE
      req_item_id = KLUTO_MEMO
      cond = 5
      check = has_quest_items?(killer, req_item_id)
    end

    if qs && qs.started? && Util.in_range?(1500, npc, killer, false)
      if check && get_quest_items_count(killer, reward.id) < 20 && Rnd.rand(100) < reward.chance
        give_items(killer, reward)
        if get_quest_items_count(killer, reward.id) == 20
          qs.set_cond(cond, true)
        else
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created? || qs.completed?
      if npc.id == MASTER_SORIUS
        html = "30327-01.htm"
      end
    elsif qs.started?
      case npc.id
      when MASTER_SORIUS
        if !has_quest_items?(pc, KLUTO_BOX)
          if !has_quest_items?(pc, TOPAZ_PIECE)
            html = "30327-07.html"
          elsif has_quest_items?(pc, TOPAZ_PIECE) && get_quest_items_count(pc, TOPAZ_PIECE) < 20
            html = "30327-08.html"
          elsif !has_at_least_one_quest_item?(pc, KLUTO_MEMO, SORIUS_LETTER) && get_quest_items_count(pc, TOPAZ_PIECE) >= 20
            unless has_quest_items?(pc, SORIUS_LETTER)
              give_items(pc, SORIUS_LETTER, 1)
            end
            qs.set_cond(3, true)
            html = "30327-09.html"
          elsif get_quest_items_count(pc, TOPAZ_PIECE) >= 20 && has_at_least_one_quest_item?(pc, SORIUS_LETTER, KLUTO_MEMO)
            html = "30327-11.html"
          end
        else
          give_adena(pc, 163800, true)
          unless has_quest_items?(pc, ELVEN_KNIGHT_BROOCH)
            give_items(pc, ELVEN_KNIGHT_BROOCH, 1)
          end
          level = pc.level
          if level >= 20
            add_exp_and_sp(pc, 320534, 23152)
          elsif level == 19
            add_exp_and_sp(pc, 456128, 29850)
          else
            add_exp_and_sp(pc, 591724, 33328)
          end
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          html = "30327-10.html"
        end
      when BLACKSMITH_KLUTO
        if !has_quest_items?(pc, KLUTO_BOX)
          if has_quest_items?(pc, SORIUS_LETTER) && get_quest_items_count(pc, TOPAZ_PIECE) >= 20
            html = "30317-01.html"
          elsif !has_quest_items?(pc, EMERALD_PIECE) && has_quest_items?(pc, KLUTO_MEMO) && get_quest_items_count(pc, TOPAZ_PIECE) >= 20
            html = "30317-03.html"
          elsif has_quest_items?(pc, KLUTO_MEMO, EMERALD_PIECE) && get_quest_items_count(pc, TOPAZ_PIECE) >= 20 && get_quest_items_count(pc, EMERALD_PIECE) < 20
            html = "30317-04.html"
          elsif has_quest_items?(pc, KLUTO_MEMO) && get_quest_items_count(pc, TOPAZ_PIECE) >= 20 && get_quest_items_count(pc, EMERALD_PIECE) >= 20
            unless has_quest_items?(pc, KLUTO_BOX)
              give_items(pc, KLUTO_BOX, 1)
            end
            take_items(pc, TOPAZ_PIECE, -1)
            take_items(pc, EMERALD_PIECE, -1)
            take_items(pc, KLUTO_MEMO, 1)
            qs.set_cond(6, true)
            html = "30317-05.html"
          end
        elsif has_quest_items?(pc, KLUTO_BOX)
          html = "30317-06.html"
        end
      end

    end

    html || get_no_quest_msg(pc)
  end
end
