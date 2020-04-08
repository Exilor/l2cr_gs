class Scripts::Q00421_LittleWingsBigAdventure < Quest
  # NPCs
  private CRONOS = 30610
  private MIMYU = 30747
  # Items
  private DRAGONFLUTE_OF_WIND = 3500
  private DRAGONFLUTE_OF_STAR = 3501
  private DRAGONFLUTE_OF_TWILIGHT = 3502
  private FAIRY_LEAF = 4325
  # Monsters
  private TREE_OF_WIND = 27185
  private TREE_OF_STAR = 27186
  private TREE_OF_TWILIGHT = 27187
  private TREE_OF_ABYSS = 27188
  private SOUL_OF_TREE_GUARDIAN = 27189
  # Skills
  private CURSE_OF_MIMYU = SkillHolder.new(4167)
  private DRYAD_ROOT = SkillHolder.new(1201, 33)
  private VICIOUS_POISON = SkillHolder.new(4243)
  # Rewards
  private DRAGON_BUGLE_OF_WIND = 4422
  private DRAGON_BUGLE_OF_STAR = 4423
  private DRAGON_BUGLE_OF_TWILIGHT = 4424
  # Misc
  private MIN_PLAYER_LVL = 45
  private MIN_HACHLING_LVL = 55

  private NPC_DATA = {
    TREE_OF_WIND => NpcData.new(NpcString::HEY_YOUVE_ALREADY_DRUNK_THE_ESSENCE_OF_WIND, 2, 1, 270),
    TREE_OF_STAR => NpcData.new(NpcString::HEY_YOUVE_ALREADY_DRUNK_THE_ESSENCE_OF_A_STAR, 4, 2, 400),
    TREE_OF_TWILIGHT => NpcData.new(NpcString::HEY_YOUVE_ALREADY_DRUNK_THE_ESSENCE_OF_DUSK, 8, 4, 150),
    TREE_OF_ABYSS => NpcData.new(NpcString::HEY_YOUVE_ALREADY_DRUNK_THE_ESSENCE_OF_THE_ABYSS, 16, 8, 270)
  }

  private record NpcData, message : NpcString, memo_state_mod : Int32,
    memo_state_value : Int32, min_hits : Int32

  def initialize
    super(421, self.class.simple_name, "Little Wing's Big Adventure")

    add_start_npc(CRONOS)
    add_talk_id(CRONOS, MIMYU)
    add_attack_id(NPC_DATA.keys)
    add_kill_id(NPC_DATA.keys)
    register_quest_items(FAIRY_LEAF)
  end

  def on_adv_event(event, npc, pc)
    if event == "DESPAWN_GUARDIAN"
      if npc
        npc.delete_me
      end

      return super
    end

    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "30610-05.htm"
      if qs.created?
        if get_quest_items_count(pc, DRAGONFLUTE_OF_WIND, DRAGONFLUTE_OF_STAR, DRAGONFLUTE_OF_TWILIGHT) == 1
          flute = get_flute(pc)

          if flute.enchant_level < MIN_HACHLING_LVL
            html = "30610-06.html"
          else
            qs.start_quest
            qs.memo_state = 100
            qs.set("fluteObjectId", flute.l2id)
            html = event
          end
        else
          html = "30610-06.html"
        end
      end
    when "30747-04.html"
      summon = pc.summon

      if summon.nil?
        html = "30747-02.html"
      elsif summon.control_l2id != qs.get_int("fluteObjectId")
        html = "30747-03.html"
      else
        html = event
      end
    when "30747-05.html"
      summon = pc.summon

      if summon.nil?
        html = "30747-06.html"
      elsif summon.control_l2id != qs.get_int("fluteObjectId")
        html = "30747-06.html"
      else
        give_items(pc, FAIRY_LEAF, 4)
        qs.set_cond(2, true)
        qs.memo_state = 0
        html = event
      end
    when "30747-07.html", "30747-08.html", "30747-09.html", "30747-10.html"
      html = event
    else
      # automatically added
    end


    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when CRONOS
      case qs.state
      when State::CREATED
        flute_count = get_quest_items_count(pc, DRAGONFLUTE_OF_WIND, DRAGONFLUTE_OF_STAR, DRAGONFLUTE_OF_TWILIGHT)
        if flute_count == 0
          return get_no_quest_msg(pc) # this quest does not show up if no flute in inventory
        end

        if pc.level < MIN_PLAYER_LVL
          html = "30610-01.htm"
        elsif flute_count > 1
          html = "30610-02.htm"
        elsif get_flute(pc).enchant_level < MIN_HACHLING_LVL
          html = "30610-03.html"
        else
          html = "30610-04.htm"
        end
      when State::STARTED
        html = "30610-07.html"
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # automatically added
      end

    when MIMYU
      case qs.memo_state
      when 100
        qs.memo_state = 200
        html = "30747-01.html"
      when 200
        summon = pc.summon

        if summon.nil?
          html = "30747-02.html"
        elsif summon.control_l2id != qs.get_int("fluteObjectId")
          html = "30747-03.html"
        else
          html = "30747-04.html"
        end
      when 0
        html = "30747-07.html"
      when 1..14
        if has_quest_items?(pc, FAIRY_LEAF)
          html = "30747-11.html"
        end
      when 15
        unless has_quest_items?(pc, FAIRY_LEAF)
          summon = pc.summon

          if summon.nil?
            html = "30747-12.html"
          elsif summon.control_l2id == qs.get_int("fluteObjectId")
            qs.memo_state = 16
            html = "30747-13.html"
          else
            html = "30747-14.html"
          end
        end
      when 16
        unless has_quest_items?(pc, FAIRY_LEAF)
          if pc.has_summon?
            html = "30747-15.html"
          else
            flute_count = get_quest_items_count(pc, DRAGONFLUTE_OF_WIND, DRAGONFLUTE_OF_STAR, DRAGONFLUTE_OF_TWILIGHT)

            if flute_count > 1
              html = "30747-17.html"
            elsif flute_count == 1
              flute = get_flute(pc)

              if flute.l2id == qs.get_int("fluteObjectId")
                # TODO what if the hatchling has items in his inventory?
                # Should they be transfered to the strider or given to the player?
                case flute.id
                when DRAGONFLUTE_OF_WIND
                  take_items(pc, DRAGONFLUTE_OF_WIND, -1)
                  give_items(pc, DRAGON_BUGLE_OF_WIND, 1)
                when DRAGONFLUTE_OF_STAR
                  take_items(pc, DRAGONFLUTE_OF_STAR, -1)
                  give_items(pc, DRAGON_BUGLE_OF_STAR, 1)
                when DRAGONFLUTE_OF_TWILIGHT
                  take_items(pc, DRAGONFLUTE_OF_TWILIGHT, -1)
                  give_items(pc, DRAGON_BUGLE_OF_TWILIGHT, 1)
                else
                  # automatically added
                end


                qs.exit_quest(true, true)
                html = "30747-16.html"
              else
                npc.target = pc
                npc.do_cast(CURSE_OF_MIMYU.skill)
                html = "30747-18.html"
              end
            end
          end
        end
      else
        # automatically added
      end

    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end

  def on_attack(npc, attacker, damage, is_summon)
    qs = get_quest_state(attacker, false)
    if qs && qs.cond?(2)
      if is_summon
        data = NPC_DATA[npc.id]
        if qs.memo_state % data.memo_state_mod < data.memo_state_value
          smn = attacker.summon
          if smn && smn.control_l2id == qs.get_int("fluteObjectId")
            hits = qs.get_int("hits") + 1
            qs.set("hits", hits)

            if hits < data.min_hits
              if npc.id == TREE_OF_ABYSS && Rnd.rand(100) < 2
                npc.target = attacker
                npc.do_cast(DRYAD_ROOT.skill)
              end
            elsif Rnd.rand(100) < 2
              if has_quest_items?(attacker, FAIRY_LEAF)
                npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::GIVE_ME_A_FAIRY_LEAF))
                take_items(attacker, FAIRY_LEAF, 1)
                qs.memo_state = qs.memo_state + data.memo_state_value
                qs.unset("hits")
                play_sound(attacker, Sound::ITEMSOUND_QUEST_MIDDLE)

                if qs.memo_state == 15
                  qs.set_cond(3)
                end
              end
            end
          end
        else
          case Rnd.rand(3)
          when 0
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::WHY_DO_YOU_BOTHER_ME_AGAIN))
          when 1
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, data.message))
          when 2
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::LEAVE_NOW_BEFORE_YOU_INCUR_THE_WRATH_OF_THE_GUARDIAN_GHOST))
          else
            # automatically added
          end

        end
      elsif Rnd.rand(100) < 30
        npc.target = attacker
        npc.do_cast(VICIOUS_POISON.skill)
      end
    elsif npc.current_hp < (npc.max_hp * 0.67) && Rnd.rand(100) < 30
      npc.target = attacker
      npc.do_cast(VICIOUS_POISON.skill)
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if Util.in_range?(1500, killer, npc, true)
      20.times do |i|
        guardian = add_spawn(SOUL_OF_TREE_GUARDIAN, npc)
        start_quest_timer("DESPAWN_GUARDIAN", 300_000, guardian, nil)
        if i == 0
          npc.target = killer
          npc.do_cast(VICIOUS_POISON.skill)
        end

        npc.set_intention(AI::ATTACK, killer)
      end
    end

    super
  end

  private def get_flute(pc)
    if has_quest_items?(pc, DRAGONFLUTE_OF_WIND)
      flute_item_id = DRAGONFLUTE_OF_WIND
    elsif has_quest_items?(pc, DRAGONFLUTE_OF_STAR)
      flute_item_id = DRAGONFLUTE_OF_STAR
    else
      flute_item_id = DRAGONFLUTE_OF_TWILIGHT
    end

    pc.inventory.get_item_by_item_id(flute_item_id).not_nil!
  end
end