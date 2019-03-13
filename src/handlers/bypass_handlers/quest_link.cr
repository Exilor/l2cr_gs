module BypassHandler::QuestLink
  extend self
  extend BypassHandler

  private MAX_QUEST_COUNT = 40
  private TO_LEAD_AND_BE_LED = 118
  private THE_LEADER_AND_THE_FOLLOWER = 123

  def use_bypass(command, pc, target)
    debug "#use_bypass \"#{command}\", #{pc}, #{target}"
    quest = command.from(5).strip
    if quest.empty?
      unless target.is_a?(L2Npc)
        raise "#{target}:#{target.class} is not a L2Npc."
      end
      show_quest_window(pc, target)
    else
      if quest_name_end = quest.index(' ')
        pc.process_quest_event(
          quest[0...quest_name_end],
          quest.from(quest_name_end).strip
        )
      else
        unless target.is_a?(L2Npc)
          raise "#{target}:#{target.class} is not a L2Npc."
        end
        show_quest_window(pc, target, quest)
      end
    end

    true
  end

  private def show_quest_choose_window(pc, npc, quests)
    debug "#show_quest_choose_window pc: #{pc.name}, npc: #{npc.name}, quests: #{quests.map(&.class)}"

    str = String.build(150) do |sb|
      sb << "<html><body>"
      state = ""
      color = ""
      quest_id = -1

      quests.each do |quest|
        qs = pc.get_quest_state(quest.name)
        if !qs || qs.created?
          state = quest.custom? ? "" : "01"
          if quest.can_start_quest?(pc)
            color = "bbaa88"
          else
            color = "a62f31"
          end
        elsif qs.started?
          state = quest.custom? ? " (In Progress)" : "02"
          color = "ffdd66"
        elsif qs.completed?
          state = quest.custom? ? " (Done)" : "03"
          color = "787878"
        end

        sb << "<a action=\"bypass -h npc_#{npc.l2id}_Quest #{quest.name}\">"
        sb << "<font color=\"#{color}\">["

        if quest.custom?
          sb << "#{quest.descr}#{state}"
        else
          quest_id = quest.id
          if quest_id > 10000
            quest_id -= 5000
          elsif quest_id == 146
            quest_id = 640
          end
          sb << "<fstring>#{quest_id}#{state}</fstring>"
        end
        sb << "]</font></a><br>"

        if pc.apprentice > 0 && L2World.get_player(pc.apprentice)
          if quest_id == TO_LEAD_AND_BE_LED
            sb << "<a action=\"bypass -h Quest Q00118_ToLeadAndBeLed sponsor\"><font color=\""
            sb << color
            sb << "\">[<fstring>"
            sb << quest_id << state
            sb << "</fstring> (Sponsor)]</font></a><br>"
          end

          if quest_id == THE_LEADER_AND_THE_FOLLOWER
            sb << "<a action=\"bypass -h Quest Q00123_TheLeaderAndTheFollower sponsor\"><font color=\""
            sb << color
            sb << "\">[<fstring>"
            sb << quest_id << state
            sb << "</fstring> (Sponsor)]</font></a><br>"
          end
        end
      end

      sb << "</body></html>"
    end

    npc.insert_l2id_and_show_chat_window(pc, str)
  end

  private def get_quests_for_talk(pc, npc_id)
    states = [] of QuestState

    unless template = NpcData[npc_id]?
      warn "#{pc} requested quests for talk on non existing npc #{npc_id}."
      return states
    end

    template.get_listeners(EventType::ON_NPC_TALK).each do |listener|
      if quest = listener.owner.as?(Quest)
        if quest.visible_in_quest_window?
          if st = pc.get_quest_state(quest.name)
            states << st
          end
        else
          debug "#{quest} is not visible in the quest window."
        end
      end
    end

    debug "#get_quests_for_talk: no quests." if states.empty?

    states
  end

  private def show_quest_window(pc, npc, quest_id = nil) # quest_id: String
    debug "#show_quest_window #{pc}, #{npc}, #{quest_id}"
    return show_quest_window_2(pc, npc) unless quest_id

    q = QuestManager.get_quest(quest_id)
    qs = pc.get_quest_state(quest_id)

    if q
      if (q.id >= 1 && q.id < 20000) && ((pc.weight_penalty >= 3) || !pc.inventory_under_90?(true))
        pc.send_packet(SystemMessageId::INVENTORY_LESS_THAN_80_PERCENT)
        return
      end

      unless qs
        if q.id >= 1 && q.id < 20000
          # too many active quests
          if pc.all_active_quests.size >= MAX_QUEST_COUNT
            html = NpcHtmlMessage.new(npc.l2id)
            html.set_file(pc, "data/html/fullquest.html")
            pc.send_packet(html)
            return
          end
        end
      end

      q.notify_talk(npc, pc)
    else
      content = Quest.get_no_quest_msg(pc)
    end

    if content
      npc.insert_l2id_and_show_chat_window(pc, content)
    end

    pc.action_failed
  end

  private def show_quest_window_2(pc, npc)
    debug "#show_quest_window_2 #{pc}, #{npc}"
    condition_meet = false
    options = Set(Quest).new
    quests = get_quests_for_talk(pc, npc.id)
    debug "Checking the quest conditions for #{npc.name} (#{quests.size} quests)."
    quests.each do |state|
      quest = state.quest
      if !quest
        warn "#{pc} requested incorrect quest state for non existing quest #{state.quest_name}."
        next
      end

      if 0 <= quest.id <= 20_000
        options << quest
        if quest.can_start_quest?(pc)
          condition_meet = true
        else
          debug "#{pc.name} can't start quest #{quest}"
        end
      end
    end

    quest_start_listeners = npc.get_listeners(EventType::ON_NPC_QUEST_START)
    # debug "#{quest_start_listeners.size} ON_NPC_QUEST_START listeners: #{quest_start_listeners.map(&.owner).map &.name}"
    quest_start_listeners.each do |listener|

      if quest = listener.owner.as?(Quest)
        if quest.visible_in_quest_window?
          if 0 <= quest.id <= 20_000
            options << quest
            if quest.can_start_quest?(pc)
              condition_meet = true
            else
              debug "#{pc.name} can't start quest #{quest}"
            end
          end
        else
          debug "#{quest} is not visible in the quest window."
        end
      end
    end

    if options.empty?
      debug "No quests found."
    else
      debug "Found quests: #{options.map &.name}"
    end

    if !condition_meet
      debug "Conditions not met."
      show_quest_window(pc, npc, "")
    elsif options.size > 1 || pc.apprentice > 0 && L2World.get_player(pc.apprentice) && options.any? { |q| q.id == TO_LEAD_AND_BE_LED }
      show_quest_choose_window(pc, npc, options)
    elsif options.size == 1
      debug "Found 1 quest."
      show_quest_window(pc, npc, options.first.name)
    else
      show_quest_window(pc, npc, "")
    end
  end

  def commands
    {"Quest"}
  end
end
