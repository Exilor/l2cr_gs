class L2SepulcherNpcInstance < L2Npc
  private HTML_FILE_PATH = "data/html/SepulcherNpc/"
  private HALLS_KEY = 7260

  @close_task : Runnable::DelayedTask?
  @spawn_next_mysterious_box_task : Runnable::DelayedTask?
  @spawn_monster_task : Runnable::DelayedTask?

  def initialize(template : L2NpcTemplate)
    super

    self.show_summon_animation = true
    if task = @close_task
      task.cancel
      @close_task = nil
    end
    if task = @spawn_next_mysterious_box_task
      task.cancel
      @spawn_next_mysterious_box_task = nil
    end
    if task = @spawn_monster_task
      task.cancel
      @spawn_monster_task = nil
    end
  end

  def instance_type : InstanceType
    InstanceType::L2SepulcherNpcInstance
  end

  def on_spawn
    super
    self.show_summon_animation = false
  end

  def delete_me : Bool
    if task = @close_task
      task.cancel
      @close_task = nil
    end
    if task = @spawn_next_mysterious_box_task
      task.cancel
      @spawn_next_mysterious_box_task = nil
    end
    if task = @spawn_monster_task
      task.cancel
      @spawn_monster_task = nil
    end

    super
  end

  def get_html_path(npc_id, val)
    if val == 0
      "#{HTML_FILE_PATH}#{npc_id}.htm"
    else
      "#{HTML_FILE_PATH}#{npc_id}-#{val}.htm"
    end
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    unless can_target?(pc)
      return
    end

    if self != pc.target
      if Config.debug
        debug "New target selected: #{l2id}."
      end

      pc.target = self
    elsif interact
      if auto_attackable?(pc) && !looks_dead?
        if (pc.z - z).abs < 400
          pc.set_intention(AI::ATTACK, self)
        else
          pc.action_failed
        end
      end

      if !auto_attackable?(pc)
        if !can_interact?(pc)
          pc.set_intention(AI::INTERACT, self)
        else
          sa = SocialAction.new(l2id, Rnd.rand(8))
          broadcast_packet(sa)
          do_action(pc)
        end
      end
    end

    pc.action_failed
  end

  private def do_action(pc : L2PcInstance)
    if dead?
      pc.action_failed
      return
    end

    case id
    when 31468..31487
      self.invul = false
      reduce_current_hp(max_hp + 1.0, pc, nil)
      if task = @spawn_monster_task
        task.cancel
      end
      task = SpawnMonster.new(id)
      @spawn_monster_task = ThreadPoolManager.schedule_effect(task, 3500)
    when 31455..31467
      self.invul = false
      reduce_current_hp(max_hp + 1.0, pc, nil)
      if party = pc.party?
        unless party.leader?(pc)
          pc = party.leader
        end
      end
      pc.add_item("Quest", HALLS_KEY, 1, pc, true)
    else
      if has_listener?(EventType::ON_NPC_QUEST_START)
        pc.last_quest_npc_l2id = l2id
      end

      if has_listener?(EventType::ON_NPC_FIRST_TALK)
        OnNpcFirstTalk.new(self, pc).async(self)
      else
        show_chat_window(pc, 0)
      end
    end

    pc.action_failed
  end

  def show_chat_window(pc, val)
    filename = get_html_path(id, val)
    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, filename)
    html["%objectId%"] = l2id
    pc.send_packet(html)
    pc.action_failed
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    if busy?
      html = NpcHtmlMessage.new(l2id)
      html.set_file(pc, "data/html/npcbusy.htm")
      html["%busymessage%"] = busy_message
      html["%npcname%"] = name
      html["%playername%"] = pc.name
      pc.send_packet(html)
    elsif command.starts_with?("Chat")
      val = 0
      begin
        val = command.from(5).to_i
      rescue e
        warn e
      end

      show_chat_window(pc, val)
    elsif command.starts_with?("open_gate")
      halls_key = pc.inventory.get_item_by_item_id(HALLS_KEY)

      if halls_key.nil?
        show_html_file(pc, "Gatekeeper-no.htm")
      elsif FourSepulchersManager.attack_time?
        case id
        when 31929, 31934, 31939, 31944
          FourSepulchersManager.spawn_shadow(id)
          # in java, here goes a "default:" not preceeded by a "break"
        end

        open_next_door(id)
        if party = pc.party?
          party.members.each do |m|
            if it = m.inventory.get_item_by_item_id(HALLS_KEY)
              m.destroy_item_by_item_id("Quest", HALLS_KEY, it.count, m, true)
            end
          end
        else
          pc.destroy_item_by_item_id("Quest", HALLS_KEY, halls_key.count, pc, true)
        end
      end
    else
      super
    end
  end

  def open_next_door(npc_id : Int32)
    door_id = FourSepulchersManager.hall_gatekeepers[npc_id]
    DoorData.get_door!(door_id).open_me

    @close_task.try &.cancel
    task = CloseNextDoor.new(door_id)
    @close_task = ThreadPoolManager.schedule_effect(task, 10000)
    @spawn_next_mysterious_box_task.try &.cancel
    task = SpawnNextMysteriousBoxTask.new(npc_id)
    @spawn_next_mysterious_box_task = ThreadPoolManager.schedule_effect(task, 0)
  end

  def say_in_shout(msg : NpcString)
    cs = CreatureSay.new(0, Packets::Incoming::Say2::NPC_SHOUT, name, msg)
    L2World.players.each do |pc|
      if Util.in_range?(15000, pc, self, true)
        pc.send_packet(cs)
      end
    end
  end

  def show_html_file(pc : L2PcInstance, file : String)
    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, "data/html/SepulcherNpc/" + file)
    html["%npcname%"] = name
    pc.send_packet(html)
  end

  private struct CloseNextDoor
    include Runnable
    include Loggable

    initializer door_id: Int32

    def run
      DoorData.get_door!(@door_id).close_me
    rescue e
      error e
    end
  end

  private struct SpawnNextMysteriousBoxTask
    include Runnable

    initializer npc_id: Int32

    def run
      FourSepulchersManager.spawn_mysterious_box(@npc_id)
    end
  end

  private struct SpawnMonster
    include Runnable

    initializer npc_id: Int32

    def run
      FourSepulchersManager.spawn_monster(@npc_id)
    end
  end
end
