class Scripts::CabalBuffer < AbstractNpcAI
  private DISTANCE_TO_WATCH_OBJECT = 900

  ORATOR_MSG = {
    NpcString::THE_DAY_OF_JUDGMENT_IS_NEAR,
    NpcString::THE_PROPHECY_OF_DARKNESS_HAS_BEEN_FULFILLED,
    NpcString::AS_FORETOLD_IN_THE_PROPHECY_OF_DARKNESS_THE_ERA_OF_CHAOS_HAS_BEGUN,
    NpcString::THE_PROPHECY_OF_DARKNESS_HAS_COME_TO_PASS
  }

  PREACHER_MSG = {
    NpcString::THIS_WORLD_WILL_SOON_BE_ANNIHILATED,
    NpcString::ALL_IS_LOST_PREPARE_TO_MEET_THE_GODDESS_OF_DEATH,
    NpcString::ALL_IS_LOST_THE_PROPHECY_OF_DESTRUCTION_HAS_BEEN_FULFILLED,
    NpcString::THE_END_OF_TIME_HAS_COME_THE_PROPHECY_OF_DESTRUCTION_HAS_BEEN_FULFILLED
  }

  private ORATOR_FIGTER = 4364
  private ORATOR_MAGE = 4365
  private PREACHER_FIGTER = 4361
  private PREACHER_MAGE = 4362

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_first_talk_id(SevenSigns::ORATOR_NPC_ID, SevenSigns::PREACHER_NPC_ID)
    add_spawn_id(SevenSigns::ORATOR_NPC_ID, SevenSigns::PREACHER_NPC_ID)
  end

  def on_first_talk(npc, pc)
    # return nil
  end

  def on_spawn(npc)
    ThreadPoolManager.schedule_general(CabalAI.new(self, npc), 3000)
    ThreadPoolManager.schedule_general(Talk.new(self, npc), 60_000)
    super
  end

  private struct Talk
    initializer owner : CabalBuffer, npc : L2Npc

    def call
      if @npc.decayed?
        return
      end

      if @npc.id == SevenSigns::PREACHER_NPC_ID
        messages = ORATOR_MSG
      else
        messages = PREACHER_MSG
      end

      @owner.broadcast_say(@npc, messages.sample(random: Rnd), nil, -1)
      ThreadPoolManager.schedule_general(self, 60_000)
    end
  end

  private struct CabalAI
    initializer owner : CabalBuffer, npc : L2Npc

    def call
      unless @npc.visible?
        return
      end

      winner = loser = false

      winning_cabal = SevenSigns.cabal_highest_score
      losing_cabal = SevenSigns::CABAL_NULL
      if winning_cabal == SevenSigns::CABAL_DAWN
        losing_cabal = SevenSigns::CABAL_DUSK
      elsif winning_cabal == SevenSigns::CABAL_DUSK
        losing_cabal = SevenSigns::CABAL_DAWN
      end

      @npc.known_list.known_players.each_value do |pc|
        if pc.invul?
          next
        end

        player_cabal = SevenSigns.get_player_cabal(pc.l2id)

        if player_cabal == winning_cabal && player_cabal != SevenSigns::CABAL_NULL && @npc.id == SevenSigns::ORATOR_NPC_ID
          if !pc.mage_class?
            if handle_cast(pc, ORATOR_FIGTER)
              if @owner.get_abnormal_level(pc, ORATOR_FIGTER) == 2
                @owner.broadcast_say(@npc, NpcString::S1_I_GIVE_YOU_THE_BLESSING_OF_PROPHECY, pc.name, 500)
              else
                @owner.broadcast_say(@npc, NpcString::I_BESTOW_UPON_YOU_A_BLESSING, nil, 1)
              end
              winner = true
              next
            end
          else
            if handle_cast(pc, ORATOR_MAGE)
              if @owner.get_abnormal_level(pc, ORATOR_MAGE) == 2
                @owner.broadcast_say(@npc, NpcString::S1_I_BESTOW_UPON_YOU_THE_AUTHORITY_OF_THE_ABYSS, pc.name, 500)
              else
                @owner.broadcast_say(@npc, NpcString::HERALD_OF_THE_NEW_ERA_OPEN_YOUR_EYES, nil, 1)
              end
              winner = true
              next
            end
          end
        elsif player_cabal == losing_cabal && player_cabal != SevenSigns::CABAL_NULL && @npc.id == SevenSigns::PREACHER_NPC_ID
          if !pc.mage_class?
            if handle_cast(pc, PREACHER_FIGTER)
              if @owner.get_abnormal_level(pc, PREACHER_FIGTER) == 2
                @owner.broadcast_say(@npc, NpcString::A_CURSE_UPON_YOU, pc.name, 500)
              else
                @owner.broadcast_say(@npc, NpcString::YOU_DONT_HAVE_ANY_HOPE_YOUR_END_HAS_COME, nil, 1)
              end
              loser = true
              next
            end
          else
            if handle_cast(pc, PREACHER_MAGE)
              if @owner.get_abnormal_level(pc, PREACHER_MAGE) == 2
                @owner.broadcast_say(@npc, NpcString::S1_YOU_MIGHT_AS_WELL_GIVE_UP, pc.name, 500)
              else
                @owner.broadcast_say(@npc, NpcString::S1_YOU_BRING_AN_ILL_WIND, pc.name, 1)
              end
              loser = true
              next
            end
          end
        end

        if winner && loser
          break
        end
      end

      ThreadPoolManager.schedule_general(self, 3000)
    end

    private def handle_cast(pc : L2PcInstance, skill_id : Int32) : Bool
      if pc.dead? || !pc.visible? || !@npc.inside_radius?(pc, DISTANCE_TO_WATCH_OBJECT, false, false)
        return false
      end

      do_cast = false
      skill_level = 1
      level = @owner.get_abnormal_level(pc, skill_id)
      if level == 0
        do_cast = true
      elsif level == 1 && Rnd.rand(100) < 5
        do_cast = true
        skill_level = 2
      end

      if do_cast
        skill = SkillData[skill_id, skill_level]
        @npc.target = pc
        @npc.do_cast(skill)
        return true
      end

      false
    end
  end

  protected def broadcast_say(npc : L2Npc, message : NpcString, param : String?, chance : Int32)
    if chance == -1
      broadcast_npc_say(npc, Say2::NPC_ALL, message)
    elsif Rnd.rand(10_000) < chance
      broadcast_npc_say(npc, Say2::NPC_ALL, message, param || "")
    end
  end

  protected def get_abnormal_level(pc : L2PcInstance, skill_id : Int32) : Int32
    info = pc.effect_list.get_buff_info_by_skill_id(skill_id)
    info ? info.skill.abnormal_lvl : 0
  end
end
