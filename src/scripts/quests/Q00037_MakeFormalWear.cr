class Scripts::Q00037_MakeFormalWear < Quest
  # NPCs
  private ALEXIS = 30842
  private LEIKAR = 31520
  private JEREMY = 31521
  private MIST = 31627
  # Items
  private FORMAL_WEAR = 6408
  private MYSTERIOUS_CLOTH = 7076
  private JEWEL_BOX = 7077
  private SEWING_KIT = 7078
  private DRESS_SHOES_BOX = 7113
  private BOX_OF_COOKIES = 7159
  private ICE_WINE = 7160
  private SIGNET_RING = 7164
  # Misc
  private MIN_LEVEL = 60

  def initialize
    super(37, self.class.simple_name, "Make Formal Wear")

    add_start_npc(ALEXIS)
    add_talk_id(ALEXIS, JEREMY, LEIKAR, MIST)
    register_quest_items(SIGNET_RING, ICE_WINE, BOX_OF_COOKIES)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "30842-03.htm"
      st.start_quest
    when "31520-02.html"
      st.give_items(SIGNET_RING, 1)
      st.set_cond(2, true)
    when "31521-02.html"
      st.give_items(ICE_WINE, 1)
      st.set_cond(3, true)
    when "31627-02.html"
      unless st.has_quest_items?(ICE_WINE)
        return get_no_quest_msg(pc)
      end
      st.take_items(ICE_WINE, 1)
      st.set_cond(4, true)
    when "31521-05.html"
      st.give_items(BOX_OF_COOKIES, 1)
      st.set_cond(5, true)
    when "31520-05.html"
      unless st.has_quest_items?(BOX_OF_COOKIES)
        return get_no_quest_msg(pc)
      end
      st.take_items(BOX_OF_COOKIES, 1)
      st.set_cond(6, true)
    when "31520-08.html"
      unless st.has_quest_items?(SEWING_KIT, JEWEL_BOX, MYSTERIOUS_CLOTH)
        return "31520-09.html"
      end
      st.take_items(SEWING_KIT, 1)
      st.take_items(JEWEL_BOX, 1)
      st.take_items(MYSTERIOUS_CLOTH, 1)
      st.set_cond(7, true)
    when "31520-12.html"
      unless st.has_quest_items?(DRESS_SHOES_BOX)
        return "31520-13.html"
      end
      st.take_items(DRESS_SHOES_BOX, 1)
      st.give_items(FORMAL_WEAR, 1)
      st.exit_quest(false, true)
    else
      html = nil
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when ALEXIS
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30842-01.htm" : "30842-02.html"
      when State::STARTED
        if st.cond?(1)
          html = "30842-04.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    when LEIKAR
      if st.started?
        case st.cond
        when 1
          html = "31520-01.html"
        when 2
          html = "31520-03.html"
        when 5
          html = "31520-04.html"
        when 6
          if st.has_quest_items?(SEWING_KIT, JEWEL_BOX, MYSTERIOUS_CLOTH)
            html = "31520-06.html"
          else
            html =  "31520-07.html"
          end
        when 7
          if st.has_quest_items?(DRESS_SHOES_BOX)
            html = "31520-10.html"
          else
            html =  "31520-11.html"
          end
        else
          # [automatically added else]
        end

      end
    when JEREMY
      if st.started?
        case st.cond
        when 2
          html = "31521-01.html"
        when 3
          html = "31521-03.html"
        when 4
          html = "31521-04.html"
        when 5
          html = "31521-06.html"
        else
          # [automatically added else]
        end

      end
    when MIST
      if st.started?
        case st.cond
        when 3
          html = "31627-01.html"
        when 4
          html = "31627-03.html"
        else
          # [automatically added else]
        end

      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
