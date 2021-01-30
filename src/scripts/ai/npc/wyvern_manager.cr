class Scripts::WyvernManager < AbstractNpcAI
  enum ManagerType : UInt8
    CASTLE
    CLAN_HALL
    FORT
  end

  # Misc
  private CRYSTAL_B_GRADE = 1460
  private WYVERN = 12621
  private WYVERN_FEE = 25
  private STRIDER_LVL = 55
  private STRIDERS = {
    12526,
    12527,
    12528,
    16038,
    16039,
    16040,
    16068,
    13197
  }
  # NPCS
  private MANAGERS = {
    35101 => ManagerType::CASTLE,
    35143 => ManagerType::CASTLE,
    35185 => ManagerType::CASTLE,
    35227 => ManagerType::CASTLE,
    35275 => ManagerType::CASTLE,
    35317 => ManagerType::CASTLE,
    35364 => ManagerType::CASTLE,
    35510 => ManagerType::CASTLE,
    35536 => ManagerType::CASTLE,
    35419 => ManagerType::CLAN_HALL,
    35638 => ManagerType::CLAN_HALL,
    36457 => ManagerType::FORT,
    36458 => ManagerType::FORT,
    36459 => ManagerType::FORT,
    36460 => ManagerType::FORT,
    36461 => ManagerType::FORT,
    36462 => ManagerType::FORT,
    36463 => ManagerType::FORT,
    36464 => ManagerType::FORT,
    36465 => ManagerType::FORT,
    36466 => ManagerType::FORT,
    36467 => ManagerType::FORT,
    36468 => ManagerType::FORT,
    36469 => ManagerType::FORT,
    36470 => ManagerType::FORT,
    36471 => ManagerType::FORT,
    36472 => ManagerType::FORT,
    36473 => ManagerType::FORT,
    36474 => ManagerType::FORT,
    36475 => ManagerType::FORT,
    36476 => ManagerType::FORT,
    36477 => ManagerType::FORT
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(MANAGERS.keys)
    add_talk_id(MANAGERS.keys)
    add_first_talk_id(MANAGERS.keys)
  end

  private def mount_wyvern(npc, pc) : String
    if pc.mounted? && pc.mount_level >= STRIDER_LVL && STRIDERS.includes?(pc.mount_npc_id)
      if owner_of_clan?(npc, pc) && get_quest_items_count(pc, CRYSTAL_B_GRADE) >= WYVERN_FEE
        take_items(pc, CRYSTAL_B_GRADE, WYVERN_FEE)
        pc.dismount
        pc.mount(WYVERN, 0, true)
        return "wyvernmanager-04.html"
      end
      return sub(pc, "wyvernmanager-06.html")
    end

    sub(pc, "wyvernmanager-05.html")
  end

  private def owner_of_clan?(npc, pc)
    unless pc.clan_leader?
      return false
    end

    case MANAGERS[npc.id]
    when ManagerType::CASTLE
      if castle = npc.castle?
        return pc.clan_id == castle.owner_id
      end

      false
    when ManagerType::CLAN_HALL
      if hall = npc.conquerable_hall
        return pc.clan_id == hall.owner_id
      end

      false
    when ManagerType::FORT
      if (fort = npc.fort?) && (clan = fort.owner_clan?)
        return pc.clan_id == clan.id
      end

      false
    else
      false
    end
  end

  private def in_siege?(npc)
    case MANAGERS[npc.id]
    when ManagerType::CASTLE
      npc.castle.zone.active?
    when ManagerType::CLAN_HALL
      hall = npc.conquerable_hall
      hall ? hall.in_siege? : npc.castle.siege.in_progress?
    when ManagerType::FORT
      npc.fort.zone.active?
    else
      false
    end
  end

  private def get_residence_name(npc)
    case MANAGERS[npc.id]
    when ManagerType::CASTLE
      npc.castle.name
    when ManagerType::CLAN_HALL
      npc.conquerable_hall.not_nil!.name
    when ManagerType::FORT
      npc.fort.name
    end

  end

  private def gsub(npc, html_prefix)
    sub(html_prefix, "wyvernmanager-01.html")
    .sub("%residence_name%", get_residence_name(npc))
  end

  private def sub(html_prefix, html_file)
    get_htm(html_prefix, html_file)
    .sub("%wyvern_fee%", WYVERN_FEE)
    .sub("%strider_level%", STRIDER_LVL)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    case event
    when "Return"
      if !owner_of_clan?(npc, pc)
        html = "wyvernmanager-02.html"
      elsif Config.allow_wyvern_always
        html = gsub(npc, pc)
      elsif MANAGERS[npc.id].castle? && SevenSigns.instance.seal_validation_period? && SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_STRIFE) == SevenSigns::CABAL_DUSK
        html = "wyvernmanager-dusk.html"
      else
        html = gsub(npc, pc)
      end
    when "Help"
      if MANAGERS[npc.id].castle?
        html = sub(pc, "wyvernmanager-03.html")
      else
        html = sub(pc, "wyvernmanager-03b.html")
      end
    when "RideWyvern"
      if !Config.allow_wyvern_always
        if !Config.allow_wyvern_during_siege && (in_siege?(npc) || pc.in_siege?)
          pc.send_message("You cannot summon wyvern while in siege.")
          return
        end
        if MANAGERS[npc.id].castle? && SevenSigns.instance.seal_validation_period? && SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_STRIFE) == SevenSigns::CABAL_DUSK
          html = "wyvernmanager-dusk.html"
        else
          html = mount_wyvern(npc, pc)
        end
      else
        html = mount_wyvern(npc, pc)
      end
    end


    html
  end

  def on_first_talk(npc, pc)
    if owner_of_clan?(npc, pc)
      if Config.allow_wyvern_always
        html = gsub(npc, pc)
      else
        if MANAGERS[npc.id].castle? && SevenSigns.instance.seal_validation_period? && SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_STRIFE) == SevenSigns::CABAL_DUSK
          html = "wyvernmanager-dusk.html"
        else
          html = gsub(npc, pc)
        end
      end
    else
      html = "wyvernmanager-02.html"
    end

    html
  end
end
