class Scripts::Q00423_TakeYourBestShot < Quest
  # NPCs
  private BATRACOS = 32740
  private JOHNNY = 32744
  # Monster
  private TANTA_GUARD = 18862
  # Item
  private SEER_UGOROS_PASS = 15496
  # Misc
  private MIN_LEVEL = 82

  def initialize
    super(423, self.class.simple_name, "Take Your Best Shot!")

    add_start_npc(JOHNNY, BATRACOS)
    add_talk_id(JOHNNY, BATRACOS)
    add_kill_id(TANTA_GUARD)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "32744-06.htm"
      if qs.created? && pc.level >= MIN_LEVEL
        qs.start_quest
        qs.memo_state = 1
        html = event
      end
    when "32744-04.html", "32744-05.htm"
      if !has_quest_items?(pc, SEER_UGOROS_PASS) && pc.level >= MIN_LEVEL
        html = event
      end
    when "32744-07.html"
      html = event
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when TANTA_GUARD
        if qs.memo_state?(1) && !has_quest_items?(killer, SEER_UGOROS_PASS)
          qs.memo_state = 2
          qs.set_cond(2, true)
        end
      else
        # automatically added
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == JOHNNY
        if has_quest_items?(pc, SEER_UGOROS_PASS)
          html = "32744-02.htm"
        else
          if pc.level >= MIN_LEVEL && pc.quest_completed?(Q00249_PoisonedPlainsOfTheLizardmen.simple_name)
            html = "32744-03.htm"
          else
            html = "32744-01.htm"
          end
        end
      elsif npc.id == BATRACOS
        if qs.has_quest_items?(SEER_UGOROS_PASS)
          html = "32740-04.html"
        else
          html = "32740-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when JOHNNY
        if qs.memo_state?(1)
          html = "32744-08.html"
        elsif qs.memo_state?(2)
          html = "32744-09.html"
        end
      when BATRACOS
        if qs.memo_state?(1)
          html = "32740-02.html"
        elsif qs.memo_state?(2)
          give_items(pc, SEER_UGOROS_PASS, 1)
          qs.exit_quest(true, true)
          html = "32740-03.html"
        end
      else
        # automatically added
      end

    end

    html || get_no_quest_msg(pc)
  end
end