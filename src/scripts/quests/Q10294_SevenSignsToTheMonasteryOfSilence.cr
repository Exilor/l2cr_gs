class Scripts::Q10294_SevenSignsToTheMonasteryOfSilence < Quest
  # NPCs
  private ELCADIA = 32784
  private ELCADIA_INSTANCE = 32787
  private ERIS_EVIL_THOUGHTS = 32792
  private SOLINAS_EVIL_THOUGHTS = 32793
  private JUDE_VAN_ETINA = 32797
  private RELIC_GUARDIAN = 32803
  private RELIC_WATCHER1 = 32804
  private RELIC_WATCHER2 = 32805
  private RELIC_WATCHER3 = 32806
  private RELIC_WATCHER4 = 32807
  private ODD_GLOBE = 32815
  private READING_DESK1 = 32821
  private READING_DESK2 = 32822
  private READING_DESK3 = 32823
  private READING_DESK4 = 32824
  private READING_DESK5 = 32825
  private READING_DESK6 = 32826
  private READING_DESK7 = 32827
  private READING_DESK8 = 32828
  private READING_DESK9 = 32829
  private READING_DESK10 = 32830
  private READING_DESK11 = 32831
  private READING_DESK12 = 32832
  private READING_DESK13 = 32833
  private READING_DESK14 = 32834
  private READING_DESK15 = 32835
  private READING_DESK16 = 32836
  private JUDE_EVIL_THOUGHTS = 32888
  # Monsters
  private SOLINA_LAY_BROTHER = 22125
  private GUIDE_SOLINA = 27415
  # Misc
  private MIN_LEVEL = 81
  # Buffs
  private VAMPIRIC_RAGE = SkillHolder.new(6727)
  private RESIST_HOLY = SkillHolder.new(6729)
  private MAGE_BUFFS = {
    SkillHolder.new(6714), # Wind Walk of Elcadia
    SkillHolder.new(6721), # Empower of Elcadia
    SkillHolder.new(6722), # Acumen of Elcadia
    SkillHolder.new(6717)  # Berserker Spirit of Elcadia
  }
  private WARRIOR_BUFFS = {
    SkillHolder.new(6714), # Wind Walk of Elcadia
    SkillHolder.new(6715), # Haste of Elcadia
    SkillHolder.new(6716), # Might of Elcadia
    SkillHolder.new(6717)  # Berserker Spirit of Elcadia
  }

  def initialize
    super(10294, self.class.simple_name, "Seven Signs, To the Monastery of Silence")

    add_first_talk_id(ELCADIA_INSTANCE)
    add_start_npc(ELCADIA, ODD_GLOBE, ELCADIA_INSTANCE, RELIC_GUARDIAN)
    add_talk_id(
      ELCADIA, ELCADIA_INSTANCE, ERIS_EVIL_THOUGHTS, RELIC_GUARDIAN, ODD_GLOBE,
      READING_DESK1, READING_DESK2, READING_DESK3, READING_DESK4, READING_DESK5,
      READING_DESK6, READING_DESK7, READING_DESK8, READING_DESK9,
      READING_DESK10, READING_DESK11, READING_DESK12, READING_DESK13,
      READING_DESK14, READING_DESK15, READING_DESK16, JUDE_VAN_ETINA,
      SOLINAS_EVIL_THOUGHTS, RELIC_WATCHER1, RELIC_WATCHER2, RELIC_WATCHER3,
      RELIC_WATCHER4
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "32784-03.htm", "32784-04.htm"
      html = event
    when "32784-05.html"
      qs.start_quest
      html = event
    when "32792-02.html"
      if qs.cond?(1)
        html = event
      end
    when "32792-03.html"
      if qs.cond?(1)
        qs.set_cond(2, true)
        html = event
      end
    when "32792-04.html", "32792-05.html", "32792-06.html", "32803-02.html",
         "32803-03.html", "32822-02.html", "32804-02.html", "32804-04.html",
         "32804-06.html", "32804-07.html", "32804-08.html", "32804-09.html",
         "32804-10.html", "32805-02.html", "32805-04.html", "32805-06.html",
         "32805-07.html", "32805-08.html", "32805-09.html", "32805-10.html",
         "32806-02.html", "32806-04.html", "32806-06.html", "32806-07.html",
         "32806-08.html", "32806-09.html", "32806-10.html", "32807-02.html",
         "32807-04.html", "32807-06.html", "32807-07.html", "32807-08.html",
         "32807-09.html", "32807-10.html"
      if qs.cond?(2)
        html = event
      end
    when "32792-08.html"
      if qs.cond?(3)
        qs.unset("good1")
        qs.unset("good2")
        qs.unset("good3")
        qs.unset("good4")
        add_exp_and_sp(pc, 25000000, 2500000)
        qs.exit_quest(false, true)
        html = event
      end
    when "BUFF"
      npc = npc.not_nil!
      npc.target = pc
      if pc.mage_class?
        MAGE_BUFFS.each do |sh|
          npc.do_simultaneous_cast(sh)
        end
      else
        WARRIOR_BUFFS.each do |sh|
          npc.do_simultaneous_cast(sh)
        end
      end
    when "RIGHT_BOOK1"
      npc = npc.not_nil!
      qs.set("good1", "1")
      npc.display_effect = 1
      start_quest_timer("SPAWN_MOBS", 22000, npc, pc)
      html = "32821-02.html"
      if has_checked_all_right_books?(qs)
        pc.show_quest_movie(25)
      end
    when "RIGHT_BOOK2"
      npc = npc.not_nil!
      qs.set("good2", "1")
      npc.display_effect = 1
      npc.target = pc
      npc.do_cast(VAMPIRIC_RAGE)
      html = "32821-02.html"
      if has_checked_all_right_books?(qs)
        pc.show_quest_movie(25)
      end
    when "RIGHT_BOOK3"
      npc = npc.not_nil!
      qs.set("good3", "1")
      npc.display_effect = 1
      jude = add_spawn(JUDE_VAN_ETINA, 85783, -253471, -8320, 65, false, 0, false, pc.instance_id)
      jude.target = pc
      jude.do_cast(RESIST_HOLY)
      html = "32821-02.html"
      if has_checked_all_right_books?(qs)
        pc.show_quest_movie(25)
      end
    when "RIGHT_BOOK4"
      npc = npc.not_nil!
      qs.set("good4", "1")
      npc.display_effect = 1
      solina = add_spawn(SOLINAS_EVIL_THOUGHTS, 85793, -247581, -8320, 0, false, 0, false, pc.instance_id)
      solina.target = pc
      solina.do_cast(RESIST_HOLY)
      html = "32821-02.html"
      if has_checked_all_right_books?(qs)
        pc.show_quest_movie(25)
      end
    when "DONE1"
      html = qs.get_int("good1") == 1 ? "32804-05.html" : "32804-03.html"
    when "DONE2"
      html = qs.get_int("good2") == 1 ? "32805-05.html" : "32805-03.html"
    when "DONE3"
      html = qs.get_int("good3") == 1 ? "32806-05.html" : "32806-03.html"
    when "DONE4"
      html = qs.get_int("good4") == 1 ? "32807-05.html" : "32807-03.html"
    when "SPAWN_MOBS"
      add_spawn(JUDE_EVIL_THOUGHTS, 88655, -250591, -8320, 144, false, 0, false, pc.instance_id)
      add_spawn(GUIDE_SOLINA, 88655, -250591, -8320, 144, false, 0, false, pc.instance_id)
      add_spawn(SOLINA_LAY_BROTHER, 88655, -250591, -8320, 144, false, 0, false, pc.instance_id)
      add_spawn(SOLINA_LAY_BROTHER, 88655, -250591, -8320, 144, false, 0, false, pc.instance_id)
    end


    html
  end

  def on_first_talk(npc, pc)
    "32787.html"
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when ELCADIA
      if qs.completed?
        html = "32784-02.html"
      elsif qs.created?
        if pc.level >= MIN_LEVEL && pc.quest_completed?(Q10293_SevenSignsForbiddenBookOfTheElmoreAdenKingdom.simple_name)
          html = "32784-01.htm"
        else
          html = "32784-07.htm"
        end
      elsif qs.started?
        if qs.cond?(1)
          html = "32784-06.html"
        end
      end
    when ERIS_EVIL_THOUGHTS
      case qs.cond
      when 1
        html = "32792-01.html"
      when 2
        html = "32792-04.html"
      when 3
        html = pc.subclass_active? ? "32792-09.html" : "32792-07.html"
      end

    when RELIC_GUARDIAN
      if qs.cond?(2)
        if has_checked_all_right_books?(qs)
          qs.set_cond(3, true)
          html = "32803-04.html"
        else
          html = "32803-01.html"
        end
      elsif qs.cond?(3)
        html = "32803-05.html"
      end
    when ODD_GLOBE
      if qs.cond < 3
        html = "32815-01.html"
      end
    when ELCADIA_INSTANCE
      if qs.cond?(1)
        html = "32787-01.html"
      elsif qs.cond?(2)
        html = "32787-02.html"
      end
    when READING_DESK2, READING_DESK3, READING_DESK4, READING_DESK6,
         READING_DESK7, READING_DESK8, READING_DESK10, READING_DESK11,
         READING_DESK12, READING_DESK14, READING_DESK15, READING_DESK16
      if qs.cond?(2)
        html = "32822-01.html"
      end
    when READING_DESK1
      html = qs.get_int("good1") == 1 ? "32821-03.html" : "32821-01.html"
    when READING_DESK5
      html = qs.get_int("good2") == 1 ? "32821-03.html" : "32825-01.html"
    when READING_DESK9
      html = qs.get_int("good3") == 1 ? "32821-03.html" : "32829-01.html"
    when READING_DESK13
      html = qs.get_int("good4") == 1 ? "32821-03.html" : "32833-01.html"
    when SOLINAS_EVIL_THOUGHTS, JUDE_VAN_ETINA, RELIC_WATCHER1,
         RELIC_WATCHER2, RELIC_WATCHER3, RELIC_WATCHER4
      if qs.cond?(2)
        html = "#{npc.id}-01.html"
      end
    end


    html || get_no_quest_msg(pc)
  end

  private def has_checked_all_right_books?(qs)
    qs.get_int("good1") == 1 && qs.get_int("good2") == 1 &&
    qs.get_int("good3") == 1 && qs.get_int("good4") == 1
  end
end
