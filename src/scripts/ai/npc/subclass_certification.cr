class Scripts::SubclassCertification < AbstractNpcAI
  private NPCS = {
    30026, 30031, 30037, 30066, 30070, 30109, 30115, 30120, 30154, 30174, 30175,
    30176, 30187, 30191, 30195, 30288, 30289, 30290, 30297, 30358, 30373, 30462,
    30474, 30498, 30499, 30500, 30503, 30504, 30505, 30508, 30511, 30512, 30513,
    30520, 30525, 30565, 30594, 30595, 30676, 30677, 30681, 30685, 30687, 30689,
    30694, 30699, 30704, 30845, 30847, 30849, 30854, 30857, 30862, 30865, 30894,
    30897, 30900, 30905, 30910, 30913, 31269, 31272, 31276, 31279, 31285, 31288,
    31314, 31317, 31321, 31324, 31326, 31328, 31331, 31334, 31336, 31755, 31958,
    31961, 31965, 31968, 31974, 31977, 31996, 32092, 32093, 32094, 32095, 32096,
    32097, 32098, 32145, 32146, 32147, 32150, 32153, 32154, 32157, 32158, 32160,
    32171, 32193, 32199, 32202, 32213, 32214, 32221, 32222, 32229, 32230, 32233,
    32234
  }
  private CERTIFICATE_EMERGENT_ABILITY = 10280
  private CERTIFICATE_MASTER_ABILITY = 10612
  private ABILITY_CERTIFICATES = {
    0 => 10281, # Certificate - Warrior Ability
    1 => 10283, # Certificate - Rogue Ability
    2 => 10282, # Certificate - Knight Ability
    3 => 10286, # Certificate - Summoner Ability
    4 => 10284, # Certificate - Wizard Ability
    5 => 10285, # Certificate - Healer Ability
    6 => 10287  # Certificate - Enchanter Ability
  }
  private TRANSFORMATION_SEALBOOKS = {
    0 => 10289, # Transformation Sealbook: Divine Warrior
    1 => 10290, # Transformation Sealbook: Divine Rogue
    2 => 10288, # Transformation Sealbook: Divine Knight
    3 => 10294, # Transformation Sealbook: Divine Summoner
    4 => 10292, # Transformation Sealbook: Divine Wizard
    5 => 10291, # Transformation Sealbook: Divine Healer
    6 => 10293  # Transformation Sealbook: Divine Enchanter
  }

  private MIN_LVL = 65

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    st.state = State::STARTED
    "Main.html"
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "GetCertified"
      if !pc.subclass_active?
        html = "NotSubclass.html"
      elsif pc.level < MIN_LVL
        html = "NotMinLevel.html"
      elsif npc.is_a?(L2VillageMasterInstance) && npc.check_village_master(pc.active_class)
        html = "CertificationList.html"
      else
        html = "WrongVillageMaster.html"
      end
    when "Obtain65"
      html = replace_html(pc, "EmergentAbility.html", true, nil).sub("%level%", "65").sub("%skilltype%", "common skill").sub("%event%", "lvl65Emergent")
    when "Obtain70"
      html = replace_html(pc, "EmergentAbility.html", true, nil).sub("%level%", "70").sub("%skilltype%", "common skill").sub("%event%", "lvl70Emergent")
    when "Obtain75"
      html = replace_html(pc, "ClassAbility.html", true, nil)
    when "Obtain80"
      html = replace_html(pc, "EmergentAbility.html", true, nil).sub("%level%", "80").sub("%skilltype%", "transformation skill").sub("%event%", "lvl80Class")
    when "lvl65Emergent"
      html = do_certification(pc, st, "EmergentAbility", CERTIFICATE_EMERGENT_ABILITY, 65)
    when "lvl70Emergent"
      html = do_certification(pc, st, "EmergentAbility", CERTIFICATE_EMERGENT_ABILITY, 70)
    when "lvl75Master"
      html = do_certification(pc, st, "ClassAbility", CERTIFICATE_MASTER_ABILITY, 75)
    when "lvl75Class"
      html = do_certification(pc, st, "ClassAbility", ABILITY_CERTIFICATES[get_class_index(pc)]?, 75)
    when "lvl80Class"
      html = do_certification(pc, st, "ClassAbility", TRANSFORMATION_SEALBOOKS[get_class_index(pc)]?, 80)
    when "Main.html", "Explanation.html", "NotObtain.html"
      html = event
    else
      # automatically added
    end


    html
  end

  private def replace_html(pc, html_file, replace_class, lvl_to_replace)
    html = get_htm(pc, html_file)

    if replace_class
      html = html.sub("%class%", ClassListData.get_class(pc.active_class).client_code)
    end

    if lvl_to_replace
      html = html.sub("%level%", lvl_to_replace)
    end

    html
  end

  private def get_class_index(pc)
    case
    when pc.in_category?(CategoryType::SUB_GROUP_WARRIOR)
      0
    when pc.in_category?(CategoryType::SUB_GROUP_ROGUE)
      1
    when pc.in_category?(CategoryType::SUB_GROUP_KNIGHT)
      2
    when pc.in_category?(CategoryType::SUB_GROUP_SUMMONER)
      3
    when pc.in_category?(CategoryType::SUB_GROUP_WIZARD)
      4
    when pc.in_category?(CategoryType::SUB_GROUP_HEALER)
      5
    when pc.in_category?(CategoryType::SUB_GROUP_ENCHANTER)
      6
    else
      -1
    end
  end

  private def do_certification(player, qs, variable, item_id, level)
    unless item_id
      return
    end

    tmp = "#{variable}#{level}-#{player.class_index}"
    global_var = qs.get_global_quest_var(tmp)

    if global_var != "" && global_var != "0"
      html = "AlreadyReceived.html"
    elsif player.level < level
      html = replace_html(player, "LowLevel.html", false, level.to_s)
    else
      unless item = player.inventory.add_item("Quest", item_id, 1, player, player.target)
        return
      end

      sm = SystemMessage.earned_item_s1
      sm.add_item_name(item)
      player.send_packet(sm)

      qs.save_global_quest_var(tmp, item.l2id.to_s)
      html = "GetAbility.html"
    end

    html
  end
end