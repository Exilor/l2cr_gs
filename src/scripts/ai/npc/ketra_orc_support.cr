class Scripts::KetraOrcSupport < AbstractNpcAI
  private struct BuffData
    getter cost

    initializer skill_id : Int32, cost : Int32

    def skill
      SkillData[@skill_id, 1]
    end
  end

  # NPCs
  private KADUN  = 31370 # Hierarch
  private WAHKAN = 31371 # Messenger
  private ASEFA  = 31372 # Soul Guide
  private ATAN   = 31373 # Grocer
  private JAFF   = 31374 # Warehouse Keeper
  private JUMARA = 31375 # Trader
  private KURFA  = 31376 # Gate Keeper
  # Items
  private HORN = 7186
  private KETRA_MARKS = {
    7211, # Mark of Ketra's Alliance - Level 1
    7212, # Mark of Ketra's Alliance - Level 2
    7213, # Mark of Ketra's Alliance - Level 3
    7214, # Mark of Ketra's Alliance - Level 4
    7215  # Mark of Ketra's Alliance - Level 5
  }
  # Misc
  private BUFFS = {
    1 => BuffData.new(4359, 2), # Focus: Requires 2 Buffalo Horns
    2 => BuffData.new(4360, 2), # Death Whisper: Requires 2 Buffalo Horns
    3 => BuffData.new(4345, 3), # Might: Requires 3 Buffalo Horns
    4 => BuffData.new(4355, 3), # Acumen: Requires 3 Buffalo Horns
    5 => BuffData.new(4352, 3), # Berserker: Requires 3 Buffalo Horns
    6 => BuffData.new(4354, 3), # Vampiric Rage: Requires 3 Buffalo Horns
    7 => BuffData.new(4356, 6), # Empower: Requires 6 Buffalo Horns
    8 => BuffData.new(4357, 6)  # Haste: Requires 6 Buffalo Horns
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_first_talk_id(KADUN, WAHKAN, ASEFA, ATAN, JAFF, JUMARA, KURFA)
    add_talk_id(ASEFA, KURFA, JAFF)
    add_start_npc(KURFA, JAFF)
  end

  private def get_alliance_level(pc)
    i = KETRA_MARKS.index { |mark| has_quest_items?(pc, mark) }
    i ? i &+ 1 : 0
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc

    if event.number? && (buff = BUFFS[event.to_i]?)
      if get_quest_items_count(pc, HORN) >= buff.cost
        take_items(pc, HORN, buff.cost)
        npc.target = pc
        npc.do_cast(buff.skill)
        npc.set_current_hp_mp(npc.max_hp.to_f, npc.max_mp.to_f)
      else
        html = "31372-02.html"
      end
    elsif event == "Teleport"
      lvl = get_alliance_level(pc)
      if lvl == 4
        html = "31376-04.html"
      elsif lvl == 5
        html = "31376-05.html"
      end
    end

    html
  end

  def on_first_talk(npc, pc)
    lvl = get_alliance_level(pc)

    case npc.id
    when KADUN
      html = (lvl > 0) ? "31370-friend.html" : "31370-no.html"
    when WAHKAN
      html = (lvl > 0) ? "31371-friend.html" : "31371-no.html"
    when ASEFA
      html = (lvl > 0) ? (lvl < 3) ? "31372-01.html" : "31372-04.html" : "31372-03.html"
    when ATAN
      html = (lvl > 0) ? "31373-friend.html" : "31373-no.html"
    when JAFF
      html = (lvl > 0) ? (lvl == 1) ? "31374-01.html" : "31374-02.html" : "31374-no.html"
    when JUMARA
      case lvl
      when 1, 2
        html = "31375-01.html"
      when 3, 4
        html = "31375-02.html"
      when 5
        html = "31375-03.html"
      else
        html = "31375-no.html"
      end
    when KURFA
      case lvl
      when 1..3
        html = "31376-01.html"
      when 4
        html = "31376-02.html"
      when 5
        html = "31376-03.html"
      else
        html = "31376-no.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
