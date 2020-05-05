class L2DuskPriestInstance < L2SignsPriestInstance
  def instance_type : InstanceType
    InstanceType::L2DuskPriestInstance
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
    gnosis_owner = SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_GNOSIS)
    cabal = SevenSigns.instance.get_player_cabal(pc.l2id)
    seal_validation_period = SevenSigns.instance.seal_validation_period?
    comp_results_period = SevenSigns.instance.comp_results_period?
    recruit_period = SevenSigns.instance.current_period
    comp_winner = SevenSigns.instance.cabal_highest_score

    case cabal
    when SevenSigns::CABAL_DUSK
      if comp_results_period
        file_name += "dusk_priest_5.htm"
      elsif recruit_period == 0
        file_name += "dusk_priest_6.htm"
      elsif seal_validation_period
        if comp_winner = SevenSigns::CABAL_DUSK
          if comp_winner != gnosis_owner
            file_name += "dusk_priest_2c.htm"
          else
            file_name += "dusk_priest_2a.htm"
          end
        elsif comp_winner == SevenSigns::CABAL_NULL
          file_name += "dusk_priest_2d.htm"
        else
          file_name += "dusk_priest_2b.htm"
        end
      else
        file_name += "dusk_priest_1b.htm"
      end
    when SevenSigns::CABAL_DAWN
      if seal_validation_period
        file_name += "dusk_priest_3a.htm"
      else
        file_name += "dusk_priest_3b.htm"
      end
    else
      if comp_results_period
        file_name += "dusk_priest_5.htm"
      elsif recruit_period == 0
        file_name += "dusk_priest_6.htm"
      elsif seal_validation_period
        if comp_winner == SevenSigns::CABAL_DUSK
          file_name += "dusk_priest_4.htm"
        elsif comp_winner == SevenSigns::CABAL_NULL
          file_name += "dusk_priest_2d.htm"
        else
          file_name += "dusk_priest_2b.htm"
        end
      else
        file_name += "dusk_priest_1a.htm"
      end
    end

    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, file_name)
    html["%objectId%"] = l2id
    pc.send_packet(html)
  end
end
