class Scripts::Q00350_EnhanceYourWeapon < Quest
  include XMLReader

  class AbsorbCrystalType < EnumClass
    add(LAST_HIT)
    add(FULL_PARTY)
    add(PARTY_ONE_RANDOM)
    add(PARTY_RANDOM)
  end

  private record LevelingInfo, absorb_crystal_type : AbsorbCrystalType,
    is_skill_needed : Bool, chance : Int32
  private record SoulCrystal, level : Int32, item_id : Int32,
    leveled_item_id : Int32

  # NPCs
  private STARTING_NPCS = {
    30115,
    30856,
    30194
  }
  # Items
  private RED_SOUL_CRYSTAL0_ID = 4629
  private GREEN_SOUL_CRYSTAL0_ID = 4640
  private BLUE_SOUL_CRYSTAL0_ID = 4651

  private SOUL_CRYSTALS = {} of Int32 => SoulCrystal
  # <npcid, <level, LevelingInfo>>
  private NPC_LEVELING_INFO = {} of Int32 => Hash(Int32, LevelingInfo)

  def initialize
    super(350, self.class.simple_name, "Enhance Your Weapon")

    load

    add_start_npc(STARTING_NPCS)
    add_talk_id(STARTING_NPCS)

    NPC_LEVELING_INFO.each_key do |npc_id|
      add_skill_see_id(npc_id)
      add_kill_id(npc_id)
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    st = get_quest_state!(pc, false)
    if event.ends_with?("-04.htm")
      st.start_quest
    elsif event.ends_with?("-09.htm")
      st.give_items(RED_SOUL_CRYSTAL0_ID, 1)
    elsif event.ends_with?("-10.htm")
      st.give_items(GREEN_SOUL_CRYSTAL0_ID, 1)
    elsif event.ends_with?("-11.htm")
      st.give_items(BLUE_SOUL_CRYSTAL0_ID, 1)
    elsif event.casecmp?("exit.htm")
      st.exit_quest(true)
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    if npc.attackable? && NPC_LEVELING_INFO.has_key?(npc.id)
      level_soul_crystal(npc.as(L2Attackable), killer)
    end

    nil
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    super

    debug { "#on_skill_see(npc: #{npc}, caster: #{caster}, skill: #{skill}, targets: #{targets})" }

    if skill.nil? || skill.id != 2096
      return
    elsif caster.nil? || caster.dead?
      return
    end

    return unless npc.is_a?(L2Attackable)

    if npc.dead? || !NPC_LEVELING_INFO.has_key?(npc.id)
      return
    end

    debug { "Adding #{caster} to the absorber's list of #{npc}." }
    npc.add_absorber(caster)

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.state == State::CREATED
      st.set("cond", "0")
    end

    if st.get_int("cond") == 0
      html = "#{npc.id}-01.htm"
    elsif check(st)
      html = "#{npc.id}-03.htm"
    elsif !st.has_quest_items?(RED_SOUL_CRYSTAL0_ID)
      unless st.has_quest_items?(GREEN_SOUL_CRYSTAL0_ID)
        unless st.has_quest_items?(BLUE_SOUL_CRYSTAL0_ID)
          html = "#{npc.id}-21.htm"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def check(st)
    (4629...4665).any? { |i| st.has_quest_items?(i) }
  end

  private def exchange_crystal(pc, mob, take_id, give_id, broke)
    item = pc.inventory.destroy_item_by_item_id("SoulCrystal", take_id, 1, pc, mob)
    if item
      # Prepare inventory update packet
      iu = InventoryUpdate.new
      iu.add_removed_item(item)

      # Add new crystal to the killer's inventory
      item = pc.inventory.add_item("SoulCrystal", give_id, 1, pc, mob).not_nil!
      iu.add_item(item)

      # Send a sound event and text message to the pc
      if broke
        pc.send_packet(SystemMessageId::SOUL_CRYSTAL_BROKE)
      else
        pc.send_packet(SystemMessageId::SOUL_CRYSTAL_ABSORBING_SUCCEEDED)
      end

      # Send system message
      sms = SystemMessage.earned_item_s1
      sms.add_item_name(give_id)
      pc.send_packet(sms)

      # Send inventory update packet
      pc.send_packet(iu)
    end
  end

  private def get_sc_for_player(pc) : SoulCrystal?
    st = pc.get_quest_state(Q00350_EnhanceYourWeapon.simple_name)
    if st.nil? || !st.started?
      return
    end

    inv = pc.inventory.items
    ret = nil
    inv.each do |item|
      item_id = item.id
      unless SOUL_CRYSTALS.has_key?(item_id)
        next
      end

      if ret
        return
      end
      ret = SOUL_CRYSTALS[item_id]
    end

    ret
  end

  private def party_leveling_monster?(npc_id)
    NPC_LEVELING_INFO[npc_id].each_value do |li|
      unless li.absorb_crystal_type.last_hit?
        return true
      end
    end

    false
  end

  private def level_crystal(pc, sc, mob)
    if sc.nil? || !NPC_LEVELING_INFO.has_key?(mob.id)
      return
    end

    unless sc
      return
    end

    # If the crystal level is way too high for this mob, say that we can't increase it
    unless NPC_LEVELING_INFO[mob.id].has_key?(sc.level)
      pc.send_packet(SystemMessageId::SOUL_CRYSTAL_ABSORBING_REFUSED)
      return
    end

    if Rnd.rand(100) <= NPC_LEVELING_INFO[mob.id][sc.level].chance
      exchange_crystal(pc, mob, sc.item_id, sc.leveled_item_id, false)
    else
      pc.send_packet(SystemMessageId::SOUL_CRYSTAL_ABSORBING_FAILED)
    end
  end

  private def level_soul_crystal(mob, killer)
    unless killer
      mob.reset_absorb_list
      return
    end

    pcs = {} of L2PcInstance => SoulCrystal
    max_sc_level = 0

    if party_leveling_monster?(mob.id) && (party = killer.party)
      party.members.each do |pl|
        unless sc = get_sc_for_player(pl)
          next
        end

        pcs[pl] = sc
        if max_sc_level < sc.level && NPC_LEVELING_INFO[mob.id].has_key?(sc.level)
          max_sc_level = sc.level
        end
      end
    else
      if sc = get_sc_for_player(killer)
        pcs[killer] = sc
        if max_sc_level < sc.level && NPC_LEVELING_INFO[mob.id].has_key?(sc.level)
          max_sc_level = sc.level
        end
      end
    end
    # Init some useful vars
    unless main_lvl_info = NPC_LEVELING_INFO.dig?(mob.id, max_sc_level)
      return
    end

    # If this mob is not require skill, then skip some checkings
    if main_lvl_info.is_skill_needed
      # Fail if this L2Attackable isn't absorbed or there's no one in its ABSORBERS_LIST
      unless mob.absorbed?
        mob.reset_absorb_list
        return
      end

      # Fail if the killer isn't in the ABSORBERS_LIST of this L2Attackable and mob is not boss
      ai = mob.absorbers_list[killer.l2id]?
      success = true
      if ai.nil? || ai.l2id != killer.l2id
        success = false
      end

      # Check if the soul crystal was used when HP of this L2Attackable wasn't higher than half of it
      if ai && ai.absorbed_hp > mob.max_hp / 2.0
        success = false
      end

      unless success
        mob.reset_absorb_list
        return
      end
    end

    case main_lvl_info.absorb_crystal_type
    when AbsorbCrystalType::PARTY_ONE_RANDOM
      # This is a naive method for selecting a random member. It gets any random party member and
      # then checks if the member has a valid crystal. It does not select the random party member
      # among those who have crystals, only. However, this might actually be correct (same as retail).
      if party = killer.party
        lucky = party.members.sample(random: Rnd)
        level_crystal(lucky, pcs[lucky], mob)
      else
        level_crystal(killer, pcs[killer], mob)
      end
    when AbsorbCrystalType::PARTY_RANDOM
      if party = killer.party
        lucky_party = party.members.dup
        while Rnd.rand(100) < 33 && !lucky_party.empty?
          lucky = lucky_party.sample(random: Rnd)
          lucky_party.delete_first(lucky)
          if pcs.has_key?(lucky)
            level_crystal(lucky, pcs[lucky], mob)
          end
        end
      elsif Rnd.rand(100) < 33
        level_crystal(killer, pcs[killer], mob)
      end
    when AbsorbCrystalType::FULL_PARTY
      if party = killer.party
        party.members.each do |pl|
          level_crystal(pl, pcs[pl], mob)
        end
      else
        level_crystal(killer, pcs[killer], mob)
      end
    when AbsorbCrystalType::LAST_HIT
      level_crystal(killer, pcs[killer], mob)
    else
      # automatically added
    end

  end

  private def load
    parse_datapack_file("levelUpCrystalData.xml")
    info { "Loaded #{SOUL_CRYSTALS.size} Soul Crystal data." }
    info { "Loaded #{NPC_LEVELING_INFO.size} NPC Leveling info data." }
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |list|
      list.each_element do |n|
        case n.name.casecmp
        when "crystal"
          n.find_element("item") do |d|
            item_id = d["itemId"].to_i
            level = d["level"].to_i
            leveled_item_id = d["leveledItemId"].to_i

            sc = SoulCrystal.new(level, item_id, leveled_item_id)
            SOUL_CRYSTALS[item_id] = sc
          end
        when "npc"
          n.find_element("item") do |d|
            npc_id = d["npcId"].to_i

            temp = {} of Int32 => LevelingInfo

            d.each_element do |cd|
              skill_needed = false
              chance = 5
              absorb_type = AbsorbCrystalType::LAST_HIT

              if cd.name.casecmp?("detail")
                if tmp = cd["absorbType"]?
                  absorb_type = AbsorbCrystalType.parse(tmp)
                end
                if tmp = cd["chance"]?
                  chance = tmp.to_i
                end
                if tmp = cd["skill"]?
                  skill_needed = Bool.new(tmp)
                end

                att1 = cd["maxLevel"]?
                att2 = cd["levelList"]?

                unless att1 || att2
                  raise "Missing maxlevel/levelList in NPC List (npc_id: #{npc_id})."
                end

                info = LevelingInfo.new(absorb_type, skill_needed, chance)

                if att1
                  max_level = att1.to_i
                  max_level.times do |i|
                    temp[i] = info
                  end
                elsif att2
                  st = att2.split(',')
                  st.each do |token|
                    value = token.strip.to_i
                    temp[value] = info
                  end
                end
              end
            end

            if temp.empty?
              raise "No leveling info for npc id #{npc_id}."
            end

            NPC_LEVELING_INFO[npc_id] = temp
          end
        else
          # automatically added
        end

      end
    end
  end
end