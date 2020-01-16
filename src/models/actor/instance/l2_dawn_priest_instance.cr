require "./l2_signs_priest_instance"

class L2DawnPriestInstance < L2SignsPriestInstance
  def instance_type : InstanceType
    InstanceType::L2DawnPriestInstance
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    if command.starts_with?("Chat")
      show_chat_window(pc)
    else
      super
    end
  end

  def show_chat_window(pc : L2PcInstance)
    pc.action_failed
    file_name = SevenSigns::SEVEN_SIGNS_HTML_PATH
    gnosis_owner = SevenSigns.get_seal_owner(SevenSigns::SEAL_GNOSIS)
    cabal = SevenSigns.get_player_cabal(pc.l2id)
    seal_validation_period = SevenSigns.seal_validation_period?
    comp_results_period = SevenSigns.comp_results_period?
    recruit_period = SevenSigns.current_period
    comp_winner = SevenSigns.cabal_highest_score

    case cabal
    when SevenSigns::CABAL_DAWN
      if comp_results_period
        file_name += "dawn_priest_5.htm"
      elsif recruit_period == 0
        file_name += "dawn_priest_6.htm"
      elsif seal_validation_period
        if comp_winner = SevenSigns::CABAL_DAWN
          if comp_winner != gnosis_owner
            file_name += "dawn_priest_2c.htm"
          else
            file_name += "dawn_priest_2a.htm"
          end
        elsif comp_winner == SevenSigns::CABAL_NULL
          file_name += "dawn_priest_2d.htm"
        else
          file_name += "dawn_priest_2b.htm"
        end
      else
        file_name += "dawn_priest_1b.htm"
      end
    when SevenSigns::CABAL_DUSK
      if seal_validation_period
        file_name += "dawn_priest_3a.htm"
      else
        file_name += "dawn_priest_3b.htm"
      end
    else
      if comp_results_period
        file_name += "dawn_priest_5.htm"
      elsif recruit_period == 0
        file_name += "dawn_priest_6.htm"
      elsif seal_validation_period
        if comp_winner == SevenSigns::CABAL_DAWN
          file_name += "dawn_priest_4.htm"
        elsif comp_winner == SevenSigns::CABAL_NULL
          file_name += "dawn_priest_2d.htm"
        else
          file_name += "dawn_priest_2b.htm"
        end
      else
        file_name += "dawn_priest_1a.htm"
      end
    end

    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, file_name)
    html["%objectId%"] = l2id
    pc.send_packet(html)
  end
end
