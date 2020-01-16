class Scripts::VarkaSilenosSupport < AbstractNpcAI
  private struct BuffData
    getter cost

    initializer skill_id : Int32, cost : Int32

    def skill
      SkillData[@skill_id, 1]
    end
  end

  # NPCs
  private ASHAS  = 31377 # Hierarch
  private NARAN  = 31378 # Messenger
  private UDAN   = 31379 # Buffer
  private DIYABU = 31380 # Grocer
  private HAGOS  = 31381 # Warehouse Keeper
  private SHIKON = 31382 # Trader
  private TERANU = 31383 # Teleporter
  # Items
  private SEED = 7187
  private VARKA_MARKS = {
    7221, # Mark of Varka's Alliance - Level 1
    7222, # Mark of Varka's Alliance - Level 2
    7223, # Mark of Varka's Alliance - Level 3
    7224, # Mark of Varka's Alliance - Level 4
    7225  # Mark of Varka's Alliance - Level 5
  }
  # Misc
  private BUFFS = {
    1 => BuffData.new(4359, 2), # Focus: Requires 2 Nepenthese Seeds
    2 => BuffData.new(4360, 2), # Death Whisper: Requires 2 Nepenthese Seeds
    3 => BuffData.new(4345, 3), # Might: Requires 3 Nepenthese Seeds
    4 => BuffData.new(4355, 3), # Acumen: Requires 3 Nepenthese Seeds
    5 => BuffData.new(4352, 3), # Berserker: Requires 3 Nepenthese Seeds
    6 => BuffData.new(4354, 3), # Vampiric Rage: Requires 3 Nepenthese Seeds
    7 => BuffData.new(4356, 6), # Empower: Requires 6 Nepenthese Seeds
    8 => BuffData.new(4357, 6)  # Haste: Requires 6 Nepenthese Seeds
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_first_talk_id(ASHAS, NARAN, UDAN, DIYABU, HAGOS, SHIKON, TERANU)
    add_talk_id(UDAN, HAGOS, TERANU)
    add_start_npc(HAGOS, TERANU)
  end

  private def get_alliance_level(pc)
    i = VARKA_MARKS.index { |mark| has_quest_items?(pc, mark) }
    i ? -(i + 1) : 0
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc

    if event.num? && (buff = BUFFS[event.to_i]?)
      if get_quest_items_count(pc, SEED) >= buff.cost
        take_items(pc, SEED, buff.cost)
        npc.target = pc
        npc.do_cast(buff.skill)
        npc.set_current_hp_mp(npc.max_hp.to_f, npc.max_mp.to_f)
      else
        html = "31379-02.html"
      end
    elsif event == "Teleport"
      lvl = get_alliance_level(pc)
      if lvl == -4
        html = "31383-04.html"
      elsif lvl == -5
        html = "31383-05.html"
      end
    end

    html
  end

  def on_first_talk(npc, pc)
    lvl = get_alliance_level(pc)

    case npc.id
    when ASHAS
      html = (lvl < 0) ? "31377-friend.html" : "31377-no.html"
    when NARAN
      html = (lvl < 0) ? "31378-friend.html" : "31378-no.html"
    when UDAN
      html = (lvl < 0) ? (lvl > -3) ? "31379-01.html" : "31379-04.html" : "31379-03.html"
    when DIYABU
      html = (lvl < 0) ? "31380-friend.html" : "31380-no.html"
    when HAGOS
      html = (lvl < 0) ? (lvl == -1) ? "31381-01.html" : "31381-02.html" : "31381-no.html"
    when SHIKON
      case lvl
      when -1, -2
        html = "31382-01.html"
      when -3, -4
        html = "31382-02.html"
      when -5
        html = "31382-03.html"
      else
        html = "31382-no.html"
      end
    when TERANU
      case lvl
      when -1..-3
        html = "31383-01.html"
      when -4
        html = "31383-02.html"
      when -5
        html = "31383-03.html"
      else
        html = "31383-no.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
