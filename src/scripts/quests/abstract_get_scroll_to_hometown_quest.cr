abstract class AbstractGetScrollToHometownQuest < Quest
  # Npcs
  private GALLADUCCI = 30097
  private GENTLER = 30094
  private SANDRA = 30090
  private DUSTIN = 30116
  # Items
  private MARK_OF_TRAVELER = 7570
  private GALLADUCCIS_ORDER_1 = 7563
  private GALLADUCCIS_ORDER_2 = 7564
  private GALLADUCCIS_ORDER_3 = 7565
  private PURIFIED_MAGIC_NECKLACE = 7566
  private GEMSTONE_POWDER = 7567
  private MAGIC_SWORD_HILT = 7568
  # Misc
  private MIN_LVL = 3
  # Reward
  private SCROLL_OF_ESCAPE_TALKING_ISLAND_VILLAGE = 7554
  private SCROLL_OF_ESCAPE_ELVEN_VILLAGE = 7555
  private SCROLL_OF_ESCAPE_DARK_ELF_VILLAGE = 7556
  private SCROLL_OF_ESCAPE_ORC_VILLAGE = 7557
  private SCROLL_OF_ESCAPE_DWARVEN_VILLAGE = 7558

  private NPC_ITEMS = {
    GENTLER => ItemHolder.new(1, GALLADUCCIS_ORDER_1.to_i64),
    SANDRA  => ItemHolder.new(3, GALLADUCCIS_ORDER_2.to_i64),
    DUSTIN  => ItemHolder.new(5, GALLADUCCIS_ORDER_3.to_i64)
  }

  def initialize(id, name, desc)
    super

    add_start_npc(GALLADUCCI)
    add_talk_id(GALLADUCCI)
    add_talk_id(NPC_ITEMS.keys)
    register_quest_items(
      GALLADUCCIS_ORDER_1, GALLADUCCIS_ORDER_2, GALLADUCCIS_ORDER_3,
      PURIFIED_MAGIC_NECKLACE, GEMSTONE_POWDER, MAGIC_SWORD_HILT
    )
  end

  abstract def scroll_item_id# : Int32
  abstract def parent_quest_name# : String

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30097-04.htm"
      if st.created?
        st.start_quest
        st.give_items(GALLADUCCIS_ORDER_1, 1)
      end
    when "30094-02.html"
      return check(st, 1, GALLADUCCIS_ORDER_1, MAGIC_SWORD_HILT, event) || "30094-03.html"
    when "30097-07.html"
      return check(st, 2, MAGIC_SWORD_HILT, GALLADUCCIS_ORDER_2, event) || "30097-08.html"
    when "30090-02.html"
      return check(st, 3, GALLADUCCIS_ORDER_2, GEMSTONE_POWDER, event) || "30090-03.html"
    when "30097-11.html"
      return check(st, 4, GEMSTONE_POWDER, GALLADUCCIS_ORDER_3, event) || "30097-12.html"
    when "30116-02.html"
      return check(st, 5, GALLADUCCIS_ORDER_3, PURIFIED_MAGIC_NECKLACE, event) || "30116-03.html"
    when "30097-15.html"
      if st.cond?(6) && st.has_quest_items?(PURIFIED_MAGIC_NECKLACE)
        st.give_items(scroll_item_id, 1)
        st.exit_quest(false, true)
      else
        return "30097-16.html"
      end
    else
      # [automatically added else]
    end


    event
  end

  private def check(st, cond, item1, item2, html)
    if st.cond?(cond) && st.has_quest_items?(item1)
      st.take_items(item1, 1)
      st.give_items(item2, 1)
      st.set_cond(cond + 1, true)
      html
    end
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when GALLADUCCI
      case st.state
      when State::CREATED
        if pc.level < MIN_LVL
          html = "30097-03.html"
        else
          requirement = pc.quest_completed?(parent_quest_name)
          if requirement && st.has_quest_items?(MARK_OF_TRAVELER)
            html = "30097-01.htm"
          else
            html = "30097-02.html"
          end
        end
      when State::STARTED
        case st.cond
        when 1
          html = "30097-05.html"
        when 2
          if st.has_quest_items?(MAGIC_SWORD_HILT)
            html = "30097-06.html"
          end
        when 3
          html = "30097-09.html"
        when 4
          if st.has_quest_items?(GEMSTONE_POWDER)
            html = "30097-10.html"
          end
        when 5
          html = "30097-13.html"
        when 6
          if st.has_quest_items?(PURIFIED_MAGIC_NECKLACE)
            html = "30097-14.html"
          end
        else
          # [automatically added else]
        end

      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    when GENTLER, SANDRA, DUSTIN
      if st.started?
        i = NPC_ITEMS[npc.id]
        cond = i.id
        if st.cond?(cond)
          item_id = i.count.to_i
          if st.has_quest_items?(item_id)
            html = "#{npc.id}-01.html"
          end
        elsif st.cond?(cond + 1)
          html = "#{npc.id}-04.html"
        end
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
