class TerritoryWarSuperClass < Quest
  private FOR_THE_SAKE_SCRIPTS = {} of Int32 => TerritoryWarSuperClass
  private PROTECT_THE_SCRIPTS  = {} of Int32 => TerritoryWarSuperClass
  private KILL_THE_SCRIPTS     = {} of Int32 => TerritoryWarSuperClass

  @catapult_id = 0
  @leader_ids = [] of Int32
  @guard_ids = [] of Int32
  @npc_string = [] of NpcString
  @npc_ids = [] of Int32
  @random_min = 0
  @random_max = 0

  protected getter territory_id = 0
  protected getter class_ids = [] of Int32

  def initialize(quest_id : Int32, name : String, description : String)
    super

    if quest_id < 0
      add_skill_see_id(36590)

      # Calculate next TW date
      cal = Calendar.new

      next_siege_date = GlobalVariablesManager.instance.get_i64(TerritoryWarManager::GLOBAL_VARIABLE, 0)
      if next_siege_date > Time.ms
        cal.ms = next_siege_date
      else
        # Check if territory war date was in the past
        if cal.before?(Time.now)
          cal.ms = Time.ms
        end

        owned = CastleManager.has_owned_castle?
        cal.day_of_week = owned ? Calendar::SATURDAY : Calendar::SUNDAY
        cal.hour = owned ? 20 : 22
        cal.minute = 0
        cal.second = 0
        if cal.before?(Time.now)
          cal.add(:WEEK, 2)
        end
        GlobalVariablesManager.instance[TerritoryWarManager::GLOBAL_VARIABLE] = cal.ms
      end
      TerritoryWarManager.tw_start_time_in_millis = cal.ms
      info { "Siege date: #{cal.time}." }
    end
  end

  def get_territory_id_for_this_npc_id(npc_id : Int32) : Int32
    0
  end

  private def handle_kill_the_quest(pc : L2PcInstance)
    st = get_quest_state(pc, false)
    st ||= new_quest_state(pc)
    kill = 1
    max = 10
    if !st.completed?
      if !st.started?
        st.state = State::STARTED
        st.set_cond(1)
        st.set("kill", "1")
        max = Rnd.rand(@random_min..@random_max)
        st.set("max", max.to_s)
      else
        kill = st.get_int("kill") &+ 1
        max = st.get_int("max")
      end
      if kill >= max
        TerritoryWarManager.give_tw_quest_point(pc)
        add_exp_and_sp(pc, 534_000, 51_000)
        st.set("doneDate", Calendar.new.day_of_year.to_s)
        st.exit_quest(true)
        pc.send_packet(ExShowScreenMessage.new(@npc_string[1], 2, 10_000))
      else
        st.set("kill", kill.to_s)

        message = ExShowScreenMessage.new(@npc_string[0], 2, 10_000)
        message.add_string_parameter(max.to_s)
        message.add_string_parameter(kill.to_s)
        pc.send_packet(message)
      end
    elsif st.get_int("doneDate") != Calendar.new.day_of_year
      st.state = State::STARTED
      st.set_cond(1)
      st.set("kill", "1")
      max = Rnd.rand(@random_min..@random_max)
      st.set("max", max.to_s)

      message = ExShowScreenMessage.new(@npc_string[0], 2, 10_000)
      message.add_string_parameter(max.to_s)
      message.add_string_parameter(kill.to_s)
      pc.send_packet(message)
    elsif pc.gm?
      pc.send_message("Cleaning #{name} Territory War quest by force.")
      st.state = State::STARTED
      st.set_cond(1)
      st.set("kill", "1")
      max = Rnd.rand(@random_min..@random_max)
      st.set("max", max.to_s)

      message = ExShowScreenMessage.new(@npc_string[0], 2, 10_000)
      message.add_string_parameter(max.to_s)
      message.add_string_parameter(kill.to_s)
      pc.send_packet(message)
    end
  end

  def on_attack(npc : L2Npc, pc : L2PcInstance, damage : Int32, is_summon : Bool) : String?
    if npc.current_hp == npc.max_hp && @npc_ids.includes?(npc.id)
      territory_id = get_territory_id_for_this_npc_id(npc.id)
      if territory_id.between?(81, 89)
        L2World.players.each do |pl|
          if pl.siege_side == territory_id
            st = pl.get_quest_state(name)
            st ||= new_quest_state(pl)
            unless st.started?
              st.set_state(State::STARTED, false)
              st.set_cond(1)
            end
          end
        end
      end
    end

    super
  end

  def on_death(killer : L2Character, victim : L2Character, qs : QuestState) : String
    if killer == victim || victim.is_a?(L2PcInstance) || victim.level < 61
      return ""
    end
    acting_pc = killer.acting_player
    if acting_pc && qs.player
      if party = acting_pc.party
        party.members.each do |pl|
          if pl.siege_side == qs.player.siege_side || pl.siege_side == 0 || !Util.in_range?(2000, killer, pl, false)
            next
          end
          if pl == acting_pc
            handle_steps_for_honor(acting_pc)
            handle_become_mercenary_quest(acting_pc, false)
          end
          handle_kill_the_quest(pl)
        end
      elsif acting_pc.siege_side != qs.player.siege_side
        if acting_pc.siege_side > 0
          handle_kill_the_quest(acting_pc)
          handle_steps_for_honor(acting_pc)
          handle_become_mercenary_quest(acting_pc, false)
        end
      end
      TerritoryWarManager.give_tw_point(acting_pc, qs.player.siege_side, 1)
    end

    ""
  end

  def on_enter_world(pc : L2PcInstance) : String?
    territory_id = TerritoryWarManager.get_registered_territory_id(pc)
    if territory_id > 0
      territory_quest = FOR_THE_SAKE_SCRIPTS[territory_id]
      st = pc.get_quest_state(territory_quest.name)
      st ||= territory_quest.new_quest_state(pc)
      st.set_state(State::STARTED, false)
      st.set_cond(1)

      if pc.level >= 61
        if killthe = KILL_THE_SCRIPTS[pc.class_id.to_i]?
          st = pc.get_quest_state(killthe.name)
          st ||= killthe.new_quest_state(pc)
          pc.add_notify_quest_of_death(st)
        else
          warn { "TerritoryWar: Missing Kill the quest for player #{pc} whose class id: #{pc.class_id.to_i}" }
        end
      end
    end

    nil
  end

  def on_kill(npc : L2Npc, killer : L2PcInstance, is_summon : Bool) : String?
    manager = TerritoryWarManager
    if npc.id == @catapult_id
      manager.territory_catapult_destroyed(@territory_id &- 80)
      manager.give_tw_point(killer, @territory_id, 4)
      manager.announce_to_participants(ExShowScreenMessage.new(@npc_string[0], 2, 10_000), 135_000, 13_500)
      handle_become_mercenary_quest(killer, true)
    elsif @leader_ids.includes?(npc.id)
      manager.give_tw_point(killer, @territory_id, 3)
    end

    if killer.siege_side != @territory_id && TerritoryWarManager.get_territory(killer.siege_side &- 80)
      manager.get_territory(killer.siege_side &- 80).not_nil!.quest_done[0] &+= 1
    end

    super
  end

  def on_skill_see(npc : L2Npc, caster : L2PcInstance, skill : Skill, targets : Array(L2Object), is_summon : Bool) : String?
    if targets.includes?(npc)
      if skill.id == 845
        if TerritoryWarManager.get_hq_for_clan(caster.clan.not_nil!) != npc
          return super
        end
        npc.delete_me
        TerritoryWarManager.set_hq_for_clan(caster.clan.not_nil!, nil)
      elsif skill.id == 847
        if TerritoryWarManager.get_hq_for_territory(caster.siege_side) != npc
          return super
        end
        unless ward = TerritoryWarManager.get_territory_ward(caster)
          return super
        end
        if caster.siege_side &- 80 == ward.owner_castle_id
          TerritoryWarManager.get_territory(ward.owner_castle_id).not_nil!.owned_ward.each do |ward_spawn|
            ward_spawn = ward_spawn.not_nil!
            if ward_spawn.id == ward.territory_id
              ward_spawn.npc = ward_spawn.npc.spawn.do_spawn
              ward.unspawn_me
              ward.npc = ward_spawn.npc
            end
          end
        else
          ward.unspawn_me
          ward.npc = TerritoryWarManager.add_territory_ward(ward.territory_id, caster.siege_side &- 80, ward.owner_castle_id, true)
          ward.owner_castle_id = caster.siege_side &- 80
          TerritoryWarManager.get_territory(caster.siege_side &- 80).not_nil!.quest_done[1] &+= 1
        end
      end
    end

    super
  end

  def register_kill_ids
    add_kill_id(@catapult_id)
    @leader_ids.each { |mob_id| add_kill_id(mob_id) }
    @guard_ids.each { |mob_id| add_kill_id(mob_id) }
  end

  def on_enter_world=(val : Bool)
    super

    L2World.players.each do |pc|
      if pc.siege_side > 0
        unless territory_quest = FOR_THE_SAKE_SCRIPTS[pc.siege_side]?
          next
        end

        if pc.has_quest_state?(territory_quest.name)
          st = pc.get_quest_state!(territory_quest.name)
        else
          st = territory_quest.new_quest_state(pc)
        end

        if val
          st.set_state(State::STARTED, false)
          st.set_cond(1)

          if pc.level >= 61
            if killthe = KILL_THE_SCRIPTS[pc.class_id.to_i]?
              st = pc.get_quest_state(killthe.name)
              st ||= killthe.new_quest_state(pc)
              pc.add_notify_quest_of_death(st)
            else
              warn { "TerritoryWar: Missing Kill the quest for player #{pc} whose class id: #{pc.class_id.to_i}." }
            end
          end
        else
          st.exit_quest(false)
          PROTECT_THE_SCRIPTS.each_value do |q|
            if st = pc.get_quest_state(q.name)
              st.exit_quest(false)
            end
          end

          if killthe = KILL_THE_SCRIPTS[pc.class_index]?
            if st = pc.get_quest_state(killthe.name)
              pc.remove_notify_quest_of_death(st)
            end
          end
        end
      end
    end
  end

  private def handle_become_mercenary_quest(pc, catapult)
    enemy_count = 10
    catapult_count = 1
    st = pc.get_quest_state(Scripts::Q00147_PathtoBecominganEliteMercenary.simple_name)
    if st && st.completed?
      st = pc.get_quest_state(Scripts::Q00148_PathtoBecominganExaltedMercenary.simple_name)
      enemy_count = 30
      catapult_count = 2
    end

    if st && st.started?
      cond = st.cond
      if catapult
        if cond == 1 || cond == 2
          count = st.get_int("catapult") &+ 1
          st.set("catapult", count.to_s)
          if count >= catapult_count
            st.set_cond(cond == 1 ? 3 : 4)
          end
        end
      elsif cond == 1 || cond == 3
        kills = st.get_int("kills") &+ 1
        st.set("kills", kills.to_s)
        if kills >= enemy_count
          st.set_cond(cond == 1 ? 2 : 4)
        end
      end
    end
  end

  private def handle_steps_for_honor(pc)
    sfh = pc.get_quest_state(Scripts::Q00176_StepsForHonor.simple_name)
    if sfh && sfh.started?
      cond = sfh.cond
      if cond == 1 || cond == 3 || cond == 5 || cond == 7
        kills = sfh.get_int("kills") &+ 1
        sfh.set("kills", kills)
        if cond == 1 && kills >= 9
          sfh.set_cond(2)
          sfh.set("kills", "0")
        elsif cond == 3 && kills >= 18
          sfh.set_cond(4)
          sfh.set("kills", "0")
        elsif cond == 5 && kills >= 27
          sfh.set_cond(6)
          sfh.set("kills", "0")
        elsif cond == 7 && kills >= 36
          sfh.set_cond(8)
          sfh.unset("kills")
        end
      end
    end
  end

  def self.load
    TerritoryWarSuperClass.new(-1, simple_name, "Territory War Superclass")

    # "For The Sake" quests
    gludio = Q00717_ForTheSakeOfTheTerritoryGludio.new
    FOR_THE_SAKE_SCRIPTS[gludio.territory_id] = gludio

    dion = Q00718_ForTheSakeOfTheTerritoryDion.new
    FOR_THE_SAKE_SCRIPTS[dion.territory_id] = dion

    giran = Q00719_ForTheSakeOfTheTerritoryGiran.new
    FOR_THE_SAKE_SCRIPTS[giran.territory_id] = giran

    oren = Q00720_ForTheSakeOfTheTerritoryOren.new
    FOR_THE_SAKE_SCRIPTS[oren.territory_id] = oren

    aden = Q00721_ForTheSakeOfTheTerritoryAden.new
    FOR_THE_SAKE_SCRIPTS[aden.territory_id] = aden

    innadril = Q00722_ForTheSakeOfTheTerritoryInnadril.new
    FOR_THE_SAKE_SCRIPTS[innadril.territory_id] = innadril

    goddard = Q00723_ForTheSakeOfTheTerritoryGoddard.new
    FOR_THE_SAKE_SCRIPTS[goddard.territory_id] = goddard

    rune = Q00724_ForTheSakeOfTheTerritoryRune.new
    FOR_THE_SAKE_SCRIPTS[rune.territory_id] = rune

    schuttgart = Q00725_ForTheSakeOfTheTerritorySchuttgart.new
    FOR_THE_SAKE_SCRIPTS[schuttgart.territory_id] = schuttgart

    # "Protect the" quests
    catapult = Q00729_ProtectTheTerritoryCatapult.new
    PROTECT_THE_SCRIPTS[catapult.id] = catapult

    supplies = Q00730_ProtectTheSuppliesSafe.new
    PROTECT_THE_SCRIPTS[supplies.id] = supplies

    military = Q00731_ProtectTheMilitaryAssociationLeader.new
    PROTECT_THE_SCRIPTS[military.id] = military

    religious = Q00732_ProtectTheReligiousAssociationLeader.new
    PROTECT_THE_SCRIPTS[religious.id] = religious

    economic = Q00733_ProtectTheEconomicAssociationLeader.new
    PROTECT_THE_SCRIPTS[economic.id] = economic


    # Kill quests
    knights = Q00734_PierceThroughAShield.new
    knights.class_ids.each do |i|
      KILL_THE_SCRIPTS[i] = knights
    end
    warriors = Q00735_MakeSpearsDull.new
    warriors.class_ids.each do |i|
      KILL_THE_SCRIPTS[i] = warriors
    end
    wizards = Q00736_WeakenTheMagic.new
    wizards.class_ids.each do |i|
      KILL_THE_SCRIPTS[i] = wizards
    end
    priests = Q00737_DenyBlessings.new
    priests.class_ids.each do |i|
      KILL_THE_SCRIPTS[i] = priests
    end
    keys = Q00738_DestroyKeyTargets.new
    keys.class_ids.each do |i|
      KILL_THE_SCRIPTS[i] = keys
    end
  end
end
