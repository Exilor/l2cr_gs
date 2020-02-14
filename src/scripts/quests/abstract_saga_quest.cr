abstract class AbstractSagaQuest < Quest
  private SPAWN_LIST = {} of L2Npc => Int32
  private QUEST_CLASSES = {
    {0x7f}, {0x80,   0x81}, {0x82}, {0x05}, {0x14}, {0x15},
    {0x02}, {0x03}, {0x2e}, {0x30}, {0x33}, {0x34}, {0x08},
    {0x17}, {0x24}, {0x09}, {0x18}, {0x25}, {0x10}, {0x11},
    {0x1e}, {0x0c}, {0x1b}, {0x28}, {0x0e}, {0x1c}, {0x29},
    {0x0d}, {0x06}, {0x22}, {0x21}, {0x2b}, {0x37}, {0x39}
  }

  @npc = [] of Int32
  @items = [] of Int32
  @mob = [] of Int32
  @class_id = [] of Int32
  @prev_class = [] of Int32
  @npc_spawn_locations = [] of Location
  @text = [] of String

  private def find_quest(pc) : QuestState?
    if st = get_quest_state(pc, false)
      if id == 68
        2.times do |q|
          if pc.class_id.to_i == QUEST_CLASSES[1][q]
            return st
          end
        end
      elsif pc.class_id.to_i == QUEST_CLASSES[id - 67][0]
        return st
      end
    end

    nil
  end

  private def find_right_state(npc) : QuestState?
    if tmp = SPAWN_LIST[npc]?
      if pc = L2World.get_player(tmp)
        pc.get_quest_state(name)
      end
    end
  end

  private def get_class_id(pc : L2PcInstance) : Int32
    if pc.class_id.to_i == 0x81
      return @class_id[1]
    end

    @class_id[0]
  end

  private def get_prev_class(pc : L2PcInstance) : Int32
    if pc.class_id.to_i == 0x81
      if @prev_class.size == 1
        return -1
      end

      return @prev_class[1]
    end

    @prev_class[0]
  end

  private def give_halisha_mark(st2)
    if st2.get_int("spawned") == 0
      if st2.get_quest_items_count(@items[3]) >= 700
        st2.take_items(@items[3], 20)
        xx, yy, zz = st2.player.xyz
        archon = st2.add_spawn(@mob[1], xx, yy, zz)
        add_spawn(st2, archon)
        st2.set("spawned", "1")
        st2.start_quest_timer("Archon Hellisha has despawned", 600000, archon)
        auto_chat(archon, @text[13].sub("PLAYERNAME", st2.player.name))
        unless archon.is_a?(L2Attackable)
          raise "#{archon} is not a L2Attackable"
        end
        archon.add_damage_hate(st2.player, 0, 99999)
        archon.set_intention(AI::ATTACK, st2.player, nil)
      else
        st2.give_items(@items[3], Rnd.rand(1..4))
      end
    end
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    npc = npc.not_nil!
    html = nil

    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "0-011.htm", "0-012.htm", "0-013.htm", "0-014.htm", "0-015.htm"
      html = event
    when "accept"
      st.start_quest
      give_items(pc, @items[10], 1)
      html = "0-03.htm"
    when "0-1"
      if pc.level < 76
        html = "0-02.htm"
        if st.created?
          st.exit_quest(true)
        end
      else
        html = "0-05.htm"
      end
    when "0-2"
      if pc.level < 76
        take_items(pc, @items[10], -1)
        st.set_cond(20, true)
        html = "0-08.htm"
      else
        take_items(pc, @items[10], -1)
        add_exp_and_sp(pc, 2299404, 0)
        give_adena(pc, 5000000, true)
        give_items(pc, 6622, 1)
        klass = get_class_id(pc)
        prev_class = get_prev_class(pc)
        pc.class_id = klass
        if !pc.subclass_active? && pc.base_class == prev_class
          pc.base_class = klass
        end
        pc.broadcast_user_info
        cast(npc, pc, 4339, 1)
        st.exit_quest(false)
        html = "0-07.htm"
      end
    when "1-3"
      st.set_cond(3)
      html = "1-05.htm"
    when "1-4"
      st.set_cond(4)
      take_items(pc, @items[0], 1)
      if @items[11] != 0
        take_items(pc, @items[11], 1)
      end
      give_items(pc, @items[1], 1)
      html = "1-06.htm"
    when "2-1"
      st.set_cond(2)
      html = "2-05.htm"
    when "2-2"
      st.set_cond(5)
      take_items(pc, @items[1], 1)
      give_items(pc, @items[4], 1)
      html = "2-06.htm"
    when "3-5"
      html = "3-07.htm"
    when "3-6"
      st.set_cond(11)
      html = "3-02.htm"
    when "3-7"
      st.set_cond(12)
      html = "3-03.htm"
    when "3-8"
      st.set_cond(13)
      take_items(pc, @items[2], 1)
      give_items(pc, @items[7], 1)
      html = "3-08.htm"
    when "4-1"
      html = "4-010.htm"
    when "4-2"
      give_items(pc, @items[9], 1)
      st.set_cond(18, true)
      html = "4-011.htm"
    when "4-3"
      give_items(pc, @items[9], 1)
      st.set_cond(18, true)
      auto_chat(npc, @text[13].sub("PLAYERNAME", pc.name))
      st.set("Quest0", "0")
      cancel_quest_timer("Mob_2 has despawned", npc, pc)
      delete_spawn(st, npc)
      return
    when "5-1"
      st.set_cond(6, true)
      take_items(pc, @items[4], 1)
      cast(npc, pc, 4546, 1)
      html = "5-02.htm"
    when "6-1"
      st.set_cond(8, true)
      st.set("spawned", "0")
      take_items(pc, @items[5], 1)
      cast(npc, pc, 4546, 1)
      html = "6-03.htm"
    when "7-1"
      if st.get_int("spawned") == 1
        html = "7-03.htm"
      elsif st.get_int("spawned") == 0
        mob1 = add_spawn(@mob[0], @npc_spawn_locations[0], false, 0)
        st.set("spawned", "1")
        st.start_quest_timer("Mob_1 Timer 1", 500, mob1)
        st.start_quest_timer("Mob_1 has despawned", 300000, mob1)
        add_spawn(st, mob1)
        html = "7-02.htm"
      else
        html = "7-04.htm"
      end
    when "7-2"
      st.set_cond(10, true)
      take_items(pc, @items[6], 1)
      cast(npc, pc, 4546, 1)
      html = "7-06.htm"
    when "8-1"
      st.set_cond(14, true)
      take_items(pc, @items[7], 1)
      cast(npc, pc, 4546, 1)
      html = "8-02.htm"
    when "9-1"
      st.set_cond(17, true)
      st.set("Quest0", "0")
      st.set("Tab", "0")
      take_items(pc, @items[8], 1)
      cast(npc, pc, 4546, 1)
      html = "9-03.htm"
    when "10-1"
      if st.get_int("Quest0") == 0
        mob3 = add_spawn(@mob[2], @npc_spawn_locations[1], false, 0)
        mob2 = add_spawn(@npc[4], @npc_spawn_locations[2], false, 0)
        add_spawn(st, mob3)
        add_spawn(st, mob2)
        st.set("Mob_2", mob2.l2id.to_s)
        st.set("Quest0", "1")
        st.set("Quest1", "45")
        st.start_repeating_quest_timer("Mob_3 Timer 1", 500, mob3)
        st.start_quest_timer("Mob_3 has despawned", 59000, mob3)
        st.start_quest_timer("Mob_2 Timer 1", 500, mob2)
        st.start_quest_timer("Mob_2 has despawned", 60000, mob2)
        html = "10-02.htm"
      elsif st.get_int("Quest1") == 45
        html = "10-03.htm"
      else
        html = "10-04.htm"
      end
    when "10-2"
      st.set_cond(19, true)
      take_items(pc, @items[9], 1)
      cast(npc, pc, 4546, 1)
      html = "10-06.htm"
    when "11-9"
      st.set_cond(15)
      html = "11-03.htm"
    when "Mob_1 Timer 1"
      auto_chat(npc, @text[0].sub("PLAYERNAME", pc.name))
      return
    when "Mob_1 has despawned"
      auto_chat(npc, @text[1].sub("PLAYERNAME", pc.name))
      st.set("spawned", "0")
      delete_spawn(st, npc)
      return
    when "Archon Hellisha has despawned"
      auto_chat(npc, @text[6].sub("PLAYERNAME", pc.name))
      st.set("spawned", "0")
      delete_spawn(st, npc)
      return
    when "Mob_3 Timer 1"
      mob2 = find_spawn(pc, L2World.find_object(st.get_int("Mob_2")).as(L2Npc)).not_nil!
      if npc.known_list.knows_object?(mob2)
        npc.as(L2Attackable).add_damage_hate(mob2, 0, 99999)
        npc.set_intention(AI::ATTACK, mob2)
        mob2.set_intention(AI::ATTACK, npc)
        auto_chat(npc, @text[14].sub("PLAYERNAME", pc.name))
        cancel_quest_timer("Mob_3 Timer 1", npc, pc)
      end
      return
    when "Mob_3 has despawned"
      auto_chat(npc, @text[15].sub("PLAYERNAME", pc.name))
      st.set("Quest0", "2")
      delete_spawn(st, npc)
      return
    when "Mob_2 Timer 1"
      auto_chat(npc, @text[7].sub("PLAYERNAME", pc.name))
      st.start_quest_timer("Mob_2 Timer 2", 1500, npc)
      if st.get_int("Quest1") == 45
        st.set("Quest1", "0")
      end
      return
    when "Mob_2 Timer 2"
      auto_chat(npc, @text[8].sub("PLAYERNAME", pc.name))
      st.start_quest_timer("Mob_2 Timer 3", 10000, npc)
      return
    when "Mob_2 Timer 3"
      if st.get_int("Quest0") == 0
        st.start_quest_timer("Mob_2 Timer 3", 13000, npc)
        if Rnd.bool
          auto_chat(npc, @text[9].sub("PLAYERNAME", pc.name))
        else
          auto_chat(npc, @text[10].sub("PLAYERNAME", pc.name))
        end
      end
      return
    when "Mob_2 has despawned"
      st.set("Quest1", (st.get_int("Quest1") + 1).to_s)
      if st.get_int("Quest0") == 1 || st.get_int("Quest0") == 2 || st.get_int("Quest1") > 3
        st.set("Quest0", "0")
        # TODO this IF will never be true
        if st.get_int("Quest0") == 1
          auto_chat(npc, @text[11].sub("PLAYERNAME", pc.name))
        else
          auto_chat(npc, @text[12].sub("PLAYERNAME", pc.name))
        end
        delete_spawn(st, npc)
      else
        st.start_quest_timer("Mob_2 has despawned", 1000, npc)
      end

      return
    end

    html
  end

  def on_attack(npc, pc, damage, is_summon)
    if st2 = find_right_state(npc)
      cond = st2.cond
      st = get_quest_state!(pc, false)
      npc_id = npc.id
      if npc_id == @mob[2] && st == st2 && cond == 17
        quest0 = st.get_int("Quest0") + 1
        if quest0 == 1
          auto_chat(npc, @text[16].sub("PLAYERNAME", pc.name))
        end

        if quest0 > 15
          quest0 = 1
          auto_chat(npc, @text[17].sub("PLAYERNAME", pc.name))
          cancel_quest_timer("Mob_3 has despawned", npc, st2.player)
          st.set("Tab", "1")
          delete_spawn(st, npc)
        end

        st.set("Quest0", quest0.to_s)
      elsif npc_id == @mob[1] && cond == 15
        if st != st2 || st == st2 && pc.in_party?
          auto_chat(npc, @text[5].sub("PLAYERNAME", pc.name))
          cancel_quest_timer("Archon Hellisha has despawned", npc, st2.player)
          st2.set("spawned", "0")
          delete_spawn(st2, npc)
        end
      end
    end

    super
  end

  def on_first_talk(npc, pc)
    html = ""
    st = get_quest_state(pc, false)
    npc_id = npc.id
    if st
      if npc_id == @npc[4]
        cond = st.cond
        if cond == 17
          if st2 = find_right_state(npc)
            pc.last_quest_npc_l2id = npc.l2id
            tab = st.get_int("Tab")
            quest0 = st.get_int("Quest0")
            if st == st2
              if tab == 1
                if quest0 == 0
                  html = "4-04.htm"
                elsif quest0 == 1
                  html = "4-06.htm"
                end
              elsif quest0 == 0
                html = "4-01.htm"
              elsif quest0 == 1
                html = "4-03.htm"
              end
            elsif tab == 1
              if quest0 == 0
                html = "4-05.htm"
              elsif quest0 == 1
                html = "4-07.htm"
              end
            elsif quest0 == 0
              html = "4-02.htm"
            end
          end
        elsif cond == 18
          html = "4-08.htm"
        end
      end
    end

    if html.empty?
      npc.show_chat_window(pc)
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    npc_id = npc.id
    st = get_quest_state(pc, false)
    (21646...21652).each do |archon_minion|
      if npc_id == archon_minion
        if party = pc.party
          party_quest_members = [] of QuestState
          party.members.each do |pc1|
            st1 = find_quest(pc1)
            if st1 && pc1.inside_radius?(pc, Config.alt_party_range2, false, false)
              if st1.cond?(15)
                party_quest_members << st1
              end
            end
          end
          unless party_quest_members.empty?
            st2 = party_quest_members.sample(random: Rnd)
            give_halisha_mark(st2)
          end
        else
          if st1 = find_quest(pc)
            if st1.cond?(15)
              give_halisha_mark(st1)
            end
          end
        end

        return super
      end
    end

    archon_hellisha_norm = {
      18212,
      18214,
      18215,
      18216,
      18218
    }
    archon_hellisha_norm.each do |element|
      if npc_id == element
        if st1 = find_quest(pc)
          if st1.cond?(15)
            # This is just a guess....not really sure what it actually says, if anything
            auto_chat(npc, @text[4].sub("PLAYERNAME", st1.player.name))
            st1.give_items(@items[8], 1)
            st1.take_items(@items[3], -1)
            st1.set_cond(16, true)
          end
        end

        return super
      end
    end

    (27214...27217).each do |guardian_angel|
      if npc_id == guardian_angel
        st1 = find_quest(pc)
        if st1 && st1.cond?(6)
          kills = st1.get_int("kills")
          if kills < 9
            st1.set("kills", (kills + 1).to_s)
          else
            st1.give_items(@items[5], 1)
            st.not_nil!.set_cond(7, true)
          end
        end

        return super
      end
    end
    if st && npc_id != @mob[2]
      st2 = find_right_state(npc)
      if st2
        cond = st.cond
        if npc_id == @mob[0] && cond == 8
          unless pc.in_party?
            if st == st2
              auto_chat(npc, @text[12].sub("PLAYERNAME", pc.name))
              give_items(pc, @items[6], 1)
              st.set_cond(9, true)
            end
          end
          cancel_quest_timer("Mob_1 has despawned", npc, st2.player)
          st2.set("spawned", "0")
          delete_spawn(st2, npc)
        elsif npc_id == @mob[1] && cond == 15
          unless pc.in_party?
            if st == st2
              auto_chat(npc, @text[4].sub("PLAYERNAME", pc.name))
              give_items(pc, @items[8], 1)
              take_items(pc, @items[3], -1)
              st.set_cond(16, true)
            else
              auto_chat(npc, @text[5].sub("PLAYERNAME", pc.name))
            end
          end
          cancel_quest_timer("Archon Hellisha has despawned", npc, st2.player)
          st2.set("spawned", "0")
          delete_spawn(st2, npc)
        end
      end
    elsif npc_id == @mob[0]
      if st = find_right_state(npc)
        cancel_quest_timer("Mob_1 has despawned", npc, st.player)
        st.set("spawned", "0")
        delete_spawn(st, npc)
      end
    elsif npc_id == @mob[1]
      if st = find_right_state(npc)
        cancel_quest_timer("Archon Hellisha has despawned", npc, st.player)
        st.set("spawned", "0")
        delete_spawn(st, npc)
      end
    end

    super
  end

  def on_skill_see(npc, pc, skill, targets, is_summon)
    tmp = SPAWN_LIST[npc]?
    if tmp && tmp != pc.l2id
      unless quest_player = L2World.find_object(tmp)
        return
      end

      targets.each do |obj|
        if obj == quest_player || obj == npc
          unless st2 = find_right_state(npc)
            return
          end
          auto_chat(npc, @text[5].sub("PLAYERNAME", pc.name))
          cancel_quest_timer("Archon Hellisha has despawned", npc, st2.player)
          st2.set("spawned", "0")
          delete_spawn(st2, npc)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    html = get_no_quest_msg(pc)
    st = get_quest_state!(pc)
    npc_id = npc.id
    if npc_id == @npc[0] && st.completed?
      html = get_already_completed_msg(pc)
    elsif pc.class_id.to_i == get_prev_class(pc)
      case st.cond
      when 0 # check it's not really -1!
        if npc_id == @npc[0]
          html = "0-01.htm"
        end
      when 1
        if npc_id == @npc[0]
          html = "0-04.htm"
        elsif npc_id == @npc[2]
          html = "2-01.htm"
        end
      when 2
        if npc_id == @npc[2]
          html = "2-02.htm"
        elsif npc_id == @npc[1]
          html = "1-01.htm"
        end
      when 3
        if npc_id == @npc[1] && has_quest_items?(pc, @items[0])
          if @items[11] == 0 || has_quest_items?(pc, @items[11])
            html = "1-03.htm"
          else
            html = "1-02.htm"
          end
        end
      when 4
        if npc_id == @npc[1]
          html = "1-04.htm"
        elsif npc_id == @npc[2]
          html = "2-03.htm"
        end
      when 5
        if npc_id == @npc[2]
          html = "2-04.htm"
        elsif npc_id == @npc[5]
          html = "5-01.htm"
        end
      when 6
        if npc_id == @npc[5]
          html = "5-03.htm"
        elsif npc_id == @npc[6]
          html = "6-01.htm"
        end
      when 7
        if npc_id == @npc[6]
          html = "6-02.htm"
        end
      when 8
        if npc_id == @npc[6]
          html = "6-04.htm"
        elsif npc_id == @npc[7]
          html = "7-01.htm"
        end
      when 9
        if npc_id == @npc[7]
          html = "7-05.htm"
        end
      when 10
        if npc_id == @npc[7]
          html = "7-07.htm"
        elsif npc_id == @npc[3]
          html = "3-01.htm"
        end
      when 11, 12
        if npc_id == @npc[3]
          if has_quest_items?(pc, @items[2])
            html = "3-05.htm"
          else
            html = "3-04.htm"
          end
        end
      when 13
        if npc_id == @npc[3]
          html = "3-06.htm"
        elsif npc_id == @npc[8]
          html = "8-01.htm"
        end
      when 14
        if npc_id == @npc[8]
          html = "8-03.htm"
        elsif npc_id == @npc[11]
          html = "11-01.htm"
        end
      when 15
        if npc_id == @npc[11]
          html = "11-02.htm"
        elsif npc_id == @npc[9]
          html = "9-01.htm"
        end
      when 16
        if npc_id == @npc[9]
          html = "9-02.htm"
        end
      when 17
        if npc_id == @npc[9]
          html = "9-04.htm"
        elsif npc_id == @npc[10]
          html = "10-01.htm"
        end
      when 18
        if npc_id == @npc[10]
          html = "10-05.htm"
        end
      when 19
        if npc_id == @npc[10]
          html = "10-07.htm"
        elsif npc_id == @npc[0]
          html = "0-06.htm"
        end
      when 20
        if npc_id == @npc[0]
          if pc.level >= 76
            html = "0-09.htm"
            unless get_class_id(pc).between?(131, 135) # in Kamael quests, npc wants to chat for a bit before changing class
              st.exit_quest(false)
              add_exp_and_sp(pc, 2299404, 0)
              give_adena(pc, 5000000, true)
              give_items(pc, 6622, 1) # XXX rewardItems?
              class_id = get_class_id(pc)
              prev_class = get_prev_class(pc)
              pc.class_id = class_id
              if !pc.subclass_active? && pc.base_class == prev_class
                pc.base_class = class_id
              end
              pc.broadcast_user_info
              cast(npc, pc, 4339, 1)
            end
          else
            html = "0-010.htm"
          end
        end
      end
    end

    html
  end

  def register_npcs
    add_start_npc(@npc[0])
    add_attack_id(@mob[2], @mob[1])
    add_skill_see_id(@mob[1])
    add_first_talk_id(@npc[4])
    add_talk_id(@npc)
    add_kill_id(@mob)
    quest_item_ids = @items.dup
    quest_item_ids[0] = 0
    quest_item_ids[2] = 0 # remove Ice Crystal and Divine Stone of Wisdom
    register_quest_items(quest_item_ids)
    (21646...21652).each do |archon_minion|
      add_kill_id(archon_minion)
    end
    archon_hellisha_norm = {
      18212,
      18214,
      18215,
      18216,
      18218
    }
    add_kill_id(archon_hellisha_norm)
    (27214...27217).each do |guardian_angel|
      add_kill_id(guardian_angel)
    end
  end

  private def add_spawn(st, mob)
    SPAWN_LIST[mob] =  st.player.l2id
  end

  private def auto_chat(npc, text)
    npc = npc.not_nil!
    npc.broadcast_packet(NpcSay.new(npc.l2id, 0, npc.id, text))
  end

  private def cast(npc, target, skill_id : Int32, level : Int32)
    target = target.not_nil!
    npc = npc.not_nil!
    target.broadcast_packet(MagicSkillUse.new(target, target, skill_id, level, 6000, 1))
    target.broadcast_packet(MagicSkillUse.new(npc, npc, skill_id, level, 6000, 1))
  end

  private def delete_spawn(st, npc)
    if npc && SPAWN_LIST.delete(npc)
      npc.delete_me
    end
  end

  private def find_spawn(pc, npc : L2Npc) : L2Npc?
    if tmp = SPAWN_LIST[npc]?
      if tmp == pc.l2id
        npc
      end
    end
  end
end
