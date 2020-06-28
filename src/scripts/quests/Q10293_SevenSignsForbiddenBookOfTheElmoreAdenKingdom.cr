class Scripts::Q10293_SevenSignsForbiddenBookOfTheElmoreAdenKingdom < Quest
  # NPCs
  private SOPHIA1 = 32596
  private ELCADIA = 32784
  private ELCADIA_INSTANCE = 32785
  private PILE_OF_BOOKS1 = 32809
  private PILE_OF_BOOKS2 = 32810
  private PILE_OF_BOOKS3 = 32811
  private PILE_OF_BOOKS4 = 32812
  private PILE_OF_BOOKS5 = 32813
  private SOPHIA2 = 32861
  private SOPHIA3 = 32863
  # Item
  private SOLINAS_BIOGRAPHY = 17213
  # Misc
  private MIN_LEVEL = 81

  def initialize
    super(10293, self.class.simple_name, "Seven Signs, Forbidden Book of the Elmore-Aden Kingdom")

    add_first_talk_id(SOPHIA3)
    add_start_npc(ELCADIA)
    add_talk_id(
      ELCADIA, ELCADIA_INSTANCE, SOPHIA1, SOPHIA2, SOPHIA3, PILE_OF_BOOKS1,
      PILE_OF_BOOKS2, PILE_OF_BOOKS3, PILE_OF_BOOKS4, PILE_OF_BOOKS5
    )
    register_quest_items(SOLINAS_BIOGRAPHY)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "32784-03.htm", "32784-05.html", "32861-13.html", "32863-02.html",
         "32863-03.html"
      html = event
    when "32784-04.html"
      qs.start_quest
      html = event
    when "32784-07.html", "32784-08.html"
      if qs.cond?(8)
        html = event
      end
    when "REWARD"
      if pc.subclass_active?
        html = "32784-10.html"
      else
        add_exp_and_sp(pc, 15000000, 1500000)
        qs.exit_quest(false, true)
        html = "32784-09.html"
      end
    when "32785-02.html"
      if qs.cond?(1)
        html = event
      end
    when "32785-07.html"
      if qs.cond?(4)
        qs.set_cond(5, true)
        html = event
      end
    when "32596-03.html", "32596-04.html"
      if qs.cond >= 1 && qs.cond < 8
        html = event
      end
    when "32861-02.html", "32861-03.html"
      if qs.cond?(1)
        html = event
      end
    when "32861-04.html"
      if qs.cond?(1)
        qs.set_cond(2, true)
        html = event
      end
    when "32861-07.html"
      if qs.cond?(3)
        html = event
      end
    when "32861-08.html"
      if qs.cond?(3)
        qs.set_cond(4, true)
        html = event
      end
    when "32861-11.html"
      if qs.cond?(5)
        qs.set_cond(6, true)
        html = event
      end
    when "32809-02.html"
      if qs.cond?(6)
        qs.set_cond(7, true)
        give_items(pc, SOLINAS_BIOGRAPHY, 1)
        html = event
      end
    when "32810-02.html", "32811-02.html", "32812-02.html", "32813-02.html"
      if qs.cond?(6)
        html = event
      end
    end


    html
  end

  def on_first_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.cond >= 1 && qs.cond < 8
      html = "32863-01.html"
    else
      html = "32863-04.html"
    end

    html || get_no_quest_msg(pc)
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when ELCADIA
      if qs.completed?
        html = "32784-02.html"
      elsif qs.created?
        if pc.level >= MIN_LEVEL && pc.quest_completed?(Q10292_SevenSignsGirlOfDoubt.simple_name)
          html = "32784-01.htm"
        else
          html = "32784-11.htm"
        end
      elsif qs.started?
        if qs.cond?(1)
          html = "32784-06.html"
        elsif qs.cond?(8)
          html = "32784-07.html"
        end
      end
    when ELCADIA_INSTANCE
      case qs.cond
      when 1
        html = "32785-01.html"
      when 2
        html = "32785-04.html"
        qs.set_cond(3, true)
      when 3
        html = "32785-05.html"
      when 4
        html = "32785-06.html"
      when 5
        html = "32785-08.html"
      when 6
        html = "32785-09.html"
      when 7
        qs.set_cond(8, true)
        html = "32785-11.html"
      when 8
        html = "32785-12.html"
      end

    when SOPHIA1
      if qs.started?
        if qs.cond >= 1 && qs.cond < 8
          html = "32596-01.html"
        else
          html = "32596-05.html"
        end
      end
    when SOPHIA2
      case qs.cond
      when 1
        html = "32861-01.html"
      when 2
        html = "32861-05.html"
      when 3
        html = "32861-06.html"
      when 4
        html = "32861-09.html"
      when 5
        html = "32861-10.html"
      when 6, 7
        html = "32861-12.html"
      when 8
        html = "32861-14.html"
      end

    when PILE_OF_BOOKS1
      if qs.cond?(6)
        html = "32809-01.html"
      end
    when PILE_OF_BOOKS2
      if qs.cond?(6)
        html = "32810-01.html"
      end
    when PILE_OF_BOOKS3
      if qs.cond?(6)
        html = "32811-01.html"
      end
    when PILE_OF_BOOKS4
      if qs.cond?(6)
        html = "32812-01.html"
      end
    when PILE_OF_BOOKS5
      if qs.cond?(6)
        html = "32813-01.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
