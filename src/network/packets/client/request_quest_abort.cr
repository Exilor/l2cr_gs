class Packets::Incoming::RequestQuestAbort < GameClientPacket
  @quest_id = 0

  private def read_impl
    @quest_id = d
  end

  private def run_impl
    return unless pc = active_char

    unless q = QuestManager.get_quest(@quest_id)
      warn { "No quest with id #{@quest_id} found." }
      return
    end

    if qs = pc.get_quest_state(q.name)
      qs.exit_quest(true)
      send_packet(QuestList.new)
    else
      warn { "No QuestState for quest #{q.name} and player #{pc.name}." }
    end
  end
end
