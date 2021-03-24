module BypassHandler::Festival
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    unless npc = target.as?(L2FestivalGuideInstance)
      return false
    end

    command = command.downcase

    if command.starts_with?(commands[1])
      val = command.from(13).to_i
      npc.show_chat_window(pc, val, nil, true)
      return true
    end

    val = command[9].to_i
    case val
    when 1 # Participate
      if SevenSigns.instance.seal_validation_period?
        npc.show_chat_window(pc, 2, "a", false)
        return true
      end

      if SevenSignsFestival.instance.festival_initialized?
        pc.send_message("You cannot sign up while a festival is in progress.")
        return true
      end

      unless party = pc.party
        npc.show_chat_window(pc, 2, "b", false)
        return true
      end

      unless party.leader?(pc)
        npc.show_chat_window(pc, 2, "c", false)
        return true
      end

      if party.size < Config.alt_festival_min_player
        npc.show_chat_window(pc, 2, "b", false)
        return true
      end

      if pc.level == SevenSignsFestival.instance.get_max_level_for_festival(npc.festival_type)
        npc.show_chat_window(pc, 2, "d", false)
        return true
      end

      if pc.festival_participant?
        SevenSignsFestival.instance.set_participants(npc.festival_oracle, npc.festival_type, party)
        npc.show_chat_window(pc, 2, "f", false)
        return true
      end

      npc.show_chat_window(pc, 1, nil, false)
    when 2 # Seal stones
      stone_type = command.from(11).to_i
      stone_count = npc.get_stone_count(stone_type)
      if stone_count <= 0
        return false
      end

      unless pc.destroy_item_by_item_id("SevenSigns", stone_type, stone_count.to_i64, npc, true)
        return false
      end

      SevenSignsFestival.instance.set_participants(npc.festival_oracle, npc.festival_type, pc.party)
      SevenSignsFestival.instance.add_accumulated_bonus(npc.festival_type, stone_type, stone_count)

      npc.show_chat_window(pc, 2, "e", false)
    when 3 # Register score
      if SevenSigns.instance.seal_validation_period?
        npc.show_chat_window(pc, 3, "a", false)
        return true
      end

      if SevenSignsFestival.instance.festival_in_progress?
        pc.send_message("You cannot register a score while a festival is in progress.")
        return true
      end

      unless pc.in_party?
        npc.show_chat_window(pc, 3, "b", false)
        return true
      end

      prev_participants = SevenSignsFestival.instance.get_previous_participants(npc.festival_oracle, npc.festival_type)

      unless prev_participants && prev_participants.includes?(pc.l2id)
        npc.show_chat_window(pc, 3, "b", false)
        return true
      end

      if pc.l2id != prev_participants[0]
        npc.show_chat_window(pc, 3, "b", false)
        return true
      end

      blood_offerings = pc.inventory.get_item_by_item_id(SevenSignsFestival::FESTIVAL_OFFERING_ID)
      unless blood_offerings
        pc.send_message("You do not have any blood offerings to contribute.")
        return true
      end

      offering_score = blood_offerings.count * SevenSignsFestival::FESTIVAL_OFFERING_VALUE
      unless pc.destroy_item("SevenSigns", blood_offerings, npc, false)
        return true
      end

      is_highest_score = SevenSignsFestival.instance.set_final_score(pc, npc.festival_oracle, npc.festival_type, offering_score)
      sm = SystemMessage.contrib_score_increased_s1
      sm.add_long(offering_score)
      pc.send_packet(sm)
      if is_highest_score
        npc.show_chat_window(pc, 3, "c", false)
      else
        npc.show_chat_window(pc, 3, "d", false)
      end
    when 4 # Current high scores
      str = String.build(500) do |io|
        io << "<html><body>Festival Guide:<br>These are the top scores of the week, for the "

        dawn_data = SevenSignsFestival.instance.get_highest_score_data(SevenSigns::CABAL_DAWN, npc.festival_type)
        dusk_data = SevenSignsFestival.instance.get_highest_score_data(SevenSigns::CABAL_DUSK, npc.festival_type)
        overall_data = SevenSignsFestival.instance.get_overall_highest_score_data(npc.festival_type)

        dawn_score = dawn_data.get_i32("score")
        dusk_score = dusk_data.get_i32("score")
        overall_score = 0

        if overall_data
          overall_score = overall_data.get_i32("score")
        end

        io << SevenSignsFestival.instance.get_festival_name(npc.festival_type)
        io << " festival.<br>"

        if dawn_score > 0
          io << "Dawn: "
          calculate_date(dawn_data.get_string("date"), io)
          io << ". Score"
          io << dawn_score
          io << "<br>"
          io << dawn_data.get_string("members")
          io << "<br>"
        else
          io << "Dawn: No record exists. Score 0<br>"
        end

        if dusk_score > 0
          io << "Dusk: "
          calculate_date(dusk_data.get_string("date"), io)
          io << ". Score"
          io << dusk_score
          io << "<br>"
          io << dusk_data.get_string("members")
          io << "<br>"
        else
          io << "Dusk: No record exists. Score 0<br>"
        end

        if overall_score > 0 && overall_data
          if overall_data.get_string("cabal") == "dawn"
            cabal_str = "Children of Dawn"
          else
            cabal_str = "Children of Dusk"
          end

          io << "Consecutive top scores: "
          calculate_date(overall_data.get_string("date"), io)
          io << ". Score "
          io << overall_score
          io << "<br>Affilated side: "
          io << cabal_str
          io << "<br>"
          io << overall_data.get_string("members")
          io << "<br>"
        else
          io << "Consecutive top scores: No record exists. Score 0<br>"
        end

        io << "<a action=\"bypass -h npc_"
        io << npc.l2id
        io << "_Chat 0\">Go back.</a></body></html>"
      end

      html = NpcHtmlMessage.new(npc.l2id)
      html.html = str
      pc.send_packet(html)
    when 8 # Increase challenge
      unless party = pc.party
        return true
      end

      unless SevenSignsFestival.instance.festival_in_progress?
        return true
      end

      unless party.leader?(pc)
        npc.show_chat_window(pc, 8, "a", false)
        return true
      end

      if SevenSignsFestival.instance.increase_challenge(npc.festival_oracle, npc.festival_type)
        npc.show_chat_window(pc, 8, "b", false)
      else
        npc.show_chat_window(pc, 8, "c", false)
      end
    when 9 # Leave
      unless party = pc.party
        return true
      end

      if party.leader?(pc)
        SevenSignsFestival.instance.update_participants(pc, nil)
      else
        if party.size > Config.alt_festival_min_player
          party.remove_party_member(pc, L2Party::MessageType::Expelled)
        else
          pc.send_message("Only the party leader can leave a festival when a party has minimum number of members.")
        end
      end
    when 0 # Distribute accumulated bonus
      unless SevenSigns.instance.seal_validation_period?
        pc.send_message("Bonuses cannot be paid during the competition period.")
        return true
      end

      if SevenSignsFestival.instance.distrib_accumulated_bonus(pc) > 0
        npc.show_chat_window(pc, 0, "a", false)
      else
        npc.show_chat_window(pc, 0, "b", false)
      end
    else
      npc.show_chat_window(pc, val, nil, false)
    end

    true
  rescue e
    error e
    false
  end

  private def calculate_date(ms_from_epoch, io)
    ms = ms_from_epoch.to_i64
    cal = Calendar.new
    cal.ms = ms
    io << cal.year << '/' << cal.month << '/' << cal.day
  end

  def commands : Enumerable(String)
    {"festival", "festivaldesc"}
  end
end
