module AugmentationData
  extend self
  extend XMLReader

  # stats
  private STAT_BLOCKSIZE = 3640
  private STAT_SUBBLOCKSIZE = 91
  MIN_SKILL_ID = STAT_BLOCKSIZE * 4

  # skills
  private BLUE_START = 14561
  private SKILLS_BLOCKSIZE = 178

  # basestats
  private BASESTAT_STR = 16341
  private BASESTAT_MEN = 16344

  # accessory
  private ACC_START = 16669
  private ACC_BLOCKS_NUM = 10
  private ACC_STAT_SUBBLOCKSIZE = 21

  private ACC_RING_START = ACC_START
  private ACC_RING_SKILLS = 18
  private ACC_RING_BLOCKSIZE = ACC_RING_SKILLS + (4 * ACC_STAT_SUBBLOCKSIZE)
  private ACC_RING_END = (ACC_RING_START + (ACC_BLOCKS_NUM * ACC_RING_BLOCKSIZE)) - 1

  private ACC_EAR_START = ACC_RING_END + 1
  private ACC_EAR_SKILLS = 18
  private ACC_EAR_BLOCKSIZE = ACC_EAR_SKILLS + (4 * ACC_STAT_SUBBLOCKSIZE)
  private ACC_EAR_END = (ACC_EAR_START + (ACC_BLOCKS_NUM * ACC_EAR_BLOCKSIZE)) - 1

  private ACC_NECK_START = ACC_EAR_END + 1
  private ACC_NECK_SKILLS = 24
  private ACC_NECK_BLOCKSIZE = ACC_NECK_SKILLS + (4 * ACC_STAT_SUBBLOCKSIZE)

  #

  private BLUE_SKILLS   = [] of Array(Int32)
  private PURPLE_SKILLS = [] of Array(Int32)
  private RED_SKILLS    = [] of Array(Int32)

  private AUGMENTATION_CHANCES = [] of AugmentationChance
  private AUGMENTATION_CHANCES_ACC = [] of AugmentationChanceAcc

  private ALL_SKILLS = {} of Int32 => SkillHolder

  private struct AugmentationChance
    getter_initializer weapon_type : String, stone_id : Int32,
      variation_id : Int32, category_chance : Int32, augment_id : Int32,
      augment_chance : Float32
  end

  private struct AugmentationChanceAcc
    getter_initializer weapon_type : String, stone_id : Int32,
      variation_id : Int32, category_chance : Int32, augment_id : Int32,
      augment_chance : Float32
  end

  def load
    RED_SKILLS.clear
    BLUE_SKILLS.clear
    PURPLE_SKILLS.clear

    10.times do
      RED_SKILLS << [] of Int32
      BLUE_SKILLS << [] of Int32
      PURPLE_SKILLS << [] of Int32
    end

    if Config.retail_like_augmentation
      parse_datapack_file("stats/augmentation/retailchances.xml")
    else
      parse_datapack_file("stats/augmentation/augmentation_skillmap.xml")
    end

    if Config.retail_like_augmentation_accessory
      parse_datapack_file("stats/augmentation/retailchances_accessory.xml")
    end

    if Config.retail_like_augmentation
      info { "Loaded #{AUGMENTATION_CHANCES.size} augmentations." }
      info { "Loaded #{AUGMENTATION_CHANCES_ACC.size} accessory augmentations." }
    else
      10.times do |i|
        info { "Loaded #{BLUE_SKILLS[i].size} blue, #{PURPLE_SKILLS[i].size} purple and #{RED_SKILLS[i].size} red skills for Life Stone lvl #{i}." }
      end
    end
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |l|
      l.find_element("weapon") do |n|
        weapon_type = n["type"]
        n.find_element("stone") do |c|
          stone_id = c["id"].to_i
          c.find_element("variation") do |v|
            variation_id = v["id"].to_i
            v.find_element("category") do |j|
              category_chance = j["probability"].to_i
              j.find_element("augment") do |e|
                augment_id = e["id"].to_i
                augment_chance = e["chance"].to_f32
                if file.path.ends_with?("retailchances.xml")
                  aug = AugmentationChance.new(
                    weapon_type,
                    stone_id,
                    variation_id,
                    category_chance,
                    augment_id,
                    augment_chance
                  )
                  AUGMENTATION_CHANCES << aug
                else
                  aug = AugmentationChanceAcc.new(
                    weapon_type,
                    stone_id,
                    variation_id,
                    category_chance,
                    augment_id,
                    augment_chance
                  )
                  AUGMENTATION_CHANCES_ACC << aug
                end
              end
            end
          end
        end
      end

      l.find_element("augmentation") do |d| # for accessory augmentations
        bad_augment_data = 0

        skill_id = 0
        augmentation_id = d["id"].to_i
        skill_lvl = 0
        type = "blue"

        d.each_element do |cd|
          if cd.name.casecmp?("skillId")
            skill_id = cd["val"].to_i
          elsif cd.name.casecmp?("skillLevel")
            skill_lvl = cd["val"].to_i
          elsif cd.name.casecmp?("type")
            type = cd["val"]
          end
        end

        if skill_id == 0 || skill_lvl == 0
          bad_augment_data += 1
          next
        end

        k = (augmentation_id - BLUE_START) // SKILLS_BLOCKSIZE

        if type.casecmp?("blue")
          BLUE_SKILLS[k] << augmentation_id
        elsif type.casecmp?("purple")
          PURPLE_SKILLS[k] << augmentation_id
        else
          RED_SKILLS[k] << augmentation_id
        end

        ALL_SKILLS[augmentation_id] = SkillHolder.new(skill_id, skill_lvl)
      end
    end
  end

  def generate_random_augmentation(ls_level : Int32, ls_grade : Int32, body_part : Int32, ls_id : Int32, item : L2ItemInstance) : L2Augmentation?
    case body_part
    when L2Item::SLOT_LR_FINGER, L2Item::SLOT_LR_EAR, L2Item::SLOT_NECK
      generate_random_accessory_augmentation(ls_level, body_part, ls_id)
    else
      generate_random_weapon_augmentation(ls_level, ls_grade, ls_id, item)
    end
  end

  private def generate_random_weapon_augmentation(ls_level : Int32, ls_grade : Int32, ls_id : Int32, item : L2ItemInstance) : L2Augmentation?
    stat12 = 0
    stat34 = 0

    if Config.retail_like_augmentation
      if item.template.magic_weapon?
        selected_chances_12 = [] of AugmentationChance
        selected_chances_34 = [] of AugmentationChance
        AUGMENTATION_CHANCES.each do |ac|
          if ac.weapon_type == "mage" && ac.stone_id == ls_id
            if ac.variation_id == 1
              selected_chances_12 << ac
            else
              selected_chances_34 << ac
            end
          end
        end
        r = Rnd.rand(10000)
        s = 10000
        selected_chances_12.each do |ac|
          if s > r
            s -= ac.augment_chance * 100
            stat12 = ac.augment_id
          end
        end
        grade_chance = case ls_grade
        when Packets::Incoming::AbstractRefinePacket::GRADE_NONE
          Config.retail_like_augmentation_ng_chance
        when Packets::Incoming::AbstractRefinePacket::GRADE_MID
          Config.retail_like_augmentation_mid_chance
        when Packets::Incoming::AbstractRefinePacket::GRADE_HIGH
          Config.retail_like_augmentation_high_chance
        when Packets::Incoming::AbstractRefinePacket::GRADE_TOP
          Config.retail_like_augmentation_top_chance
        else
          Config.retail_like_augmentation_ng_chance
        end

        c = Rnd.rand(100)
        if c < grade_chance[0]
          c = 55
        elsif c < grade_chance[0] + grade_chance[1]
          c = 35
        elsif c < grade_chance[0] + grade_chance[1] + grade_chance[2]
          c = 7
        else
          c = 3
        end
        selected_chances_34_final = [] of AugmentationChance
        selected_chances_34.each do |ac|
          if ac.category_chance == c
            selected_chances_34_final << ac
          end
        end
        r = Rnd.rand(10000)
        s = 10000
        selected_chances_34_final.each do |ac|
          if s > r
            s -= ac.augment_chance * 100
            stat34 = ac.augment_id
          end
        end
      else
        selected_chances_12 = [] of AugmentationChance
        selected_chances_34 = [] of AugmentationChance
        AUGMENTATION_CHANCES.each do |ac|
          if ac.weapon_type == "warrior" && ac.stone_id == ls_id
            if ac.variation_id == 1
              selected_chances_12 << ac
            else
              selected_chances_34 << ac
            end
          end
        end
        r = Rnd.rand(10000)
        s = 10000
        selected_chances_12.each do |ac|
          if s > r
            s -= ac.augment_chance * 100
            stat12 = ac.augment_id
          end
        end
        grade_chance = case ls_grade
        when Packets::Incoming::AbstractRefinePacket::GRADE_NONE
          Config.retail_like_augmentation_ng_chance
        when Packets::Incoming::AbstractRefinePacket::GRADE_MID
          Config.retail_like_augmentation_mid_chance
        when Packets::Incoming::AbstractRefinePacket::GRADE_HIGH
          Config.retail_like_augmentation_high_chance
        when Packets::Incoming::AbstractRefinePacket::GRADE_TOP
          Config.retail_like_augmentation_top_chance
        else
          Config.retail_like_augmentation_ng_chance
        end

        c = Rnd.rand(100)
        if c < grade_chance[0]
          c = 55
        elsif c < grade_chance[0] + grade_chance[1]
          c = 35
        elsif c < grade_chance[0] + grade_chance[1] + grade_chance[2]
          c = 7
        else
          c = 3
        end
        selected_chances_34_final = [] of AugmentationChance
        selected_chances_34.each do |ac|
          if ac.category_chance == c
            selected_chances_34_final << ac
          end
        end
        r = Rnd.rand(10000)
        s = 10000
        selected_chances_34_final.each do |ac|
          if s > r
            s -= ac.augment_chance * 100
            stat34 = ac.augment_id
          end
        end
      end

      return L2Augmentation.new((stat34 << 16) + stat12)
    end

    generate_skill = false
    generate_glow = false

    ls_level = Math.min(ls_level, 9)

    case ls_grade
    when Packets::Incoming::AbstractRefinePacket::GRADE_NONE
      if Rnd.rand(1..100) <= Config.augmentation_ng_skill_chance
        generate_skill = true
      end

      if Rnd.rand(1..100) <= Config.augmentation_ng_glow_chance
        generate_glow = true
      end
    when Packets::Incoming::AbstractRefinePacket::GRADE_MID
      if Rnd.rand(1..100) <= Config.augmentation_mid_skill_chance
        generate_skill = true
      end

      if Rnd.rand(1..100) <= Config.augmentation_mid_glow_chance
        generate_glow = true
      end
    when Packets::Incoming::AbstractRefinePacket::GRADE_HIGH
      if Rnd.rand(1..100) <= Config.augmentation_high_skill_chance
        generate_skill = true
      end

      if Rnd.rand(1..100) <= Config.augmentation_high_glow_chance
        generate_glow = true
      end
    when Packets::Incoming::AbstractRefinePacket::GRADE_TOP
      if Rnd.rand(1..100) <= Config.augmentation_top_skill_chance
        generate_skill = true
      end

      if Rnd.rand(1..100) <= Config.augmentation_top_glow_chance
        generate_glow = true
      end
    when Packets::Incoming::AbstractRefinePacket::GRADE_ACC
      if Rnd.rand(1..100) <= Config.augmentation_acc_skill_chance
        generate_skill = true
      end
    end

    if !generate_skill && Rnd.rand(1..100) <= Config.augmentation_basestat_chance
      stat34 = Rnd.rand(BASESTAT_STR..BASESTAT_MEN)
    end

    result_color = Rnd.rand(0..100)

    if stat34 == 0 && !generate_skill
      if result_color <= (15 * ls_grade) + 40
        result_color = 1
      else
        result_color = 0
      end
    else
      if result_color <= (10 * ls_grade) + 5 || stat34 != 0
        result_color = 3
      elsif result_color <= (10 * ls_grade) + 10
        result_color = 1
      else
        result_color = 2
      end
    end

    if generate_skill
      case result_color
      when 1
        stat34 = BLUE_SKILLS[ls_level].sample(random: Rnd)
      when 2
        stat34 = PURPLE_SKILLS[ls_level].sample(random: Rnd)
      when 3
        stat34 = RED_SKILLS[ls_level].sample(random: Rnd)
      end
    end

    if stat34 == 0
      temp = Rnd.rand(2..3)
      color_offset = (result_color * (10 * STAT_SUBBLOCKSIZE)) + (temp * STAT_BLOCKSIZE) + 1
      offset = (ls_level * STAT_SUBBLOCKSIZE) + color_offset
      stat34 = Rnd.rand(offset..(offset + STAT_SUBBLOCKSIZE) - 1)

      if generate_glow && ls_grade >= 2
        offset = (ls_level * STAT_SUBBLOCKSIZE) + ((temp - 2) * STAT_BLOCKSIZE) + (ls_grade * (10 * STAT_SUBBLOCKSIZE)) + 1
      else
        offset = (ls_level * STAT_SUBBLOCKSIZE) + ((temp - 2) * STAT_BLOCKSIZE) + (Rnd.rand(0..1) * (10 * STAT_SUBBLOCKSIZE)) + 1
      end
    else
      if !generate_glow
        offset = (ls_level * STAT_SUBBLOCKSIZE) + (Rnd.rand(0..1) * STAT_BLOCKSIZE) + 1
      else
        offset = (ls_level * STAT_SUBBLOCKSIZE) + (Rnd.rand(0..1) * STAT_BLOCKSIZE) + (((ls_grade + result_color) // 2) * (10 * STAT_SUBBLOCKSIZE)) + 1
      end
    end

    stat12 = Rnd.rand(offset..(offset + STAT_SUBBLOCKSIZE) - 1)

    debug { "Augmentation success: stat12=#{stat12}, stat34=#{stat34}, result_color=#{result_color}, level=#{ls_level}, grade=#{ls_grade}." }

    L2Augmentation.new((stat34 << 16) + stat12)
  end

  private def generate_random_accessory_augmentation(ls_level : Int32, body_part : Int32, ls_id : Int32) : L2Augmentation?
    stat12 = 0
    stat34 = 0

    if Config.retail_like_augmentation_accessory
      selected_chances_12 = [] of AugmentationChanceAcc
      selected_chances_34 = [] of AugmentationChanceAcc
      AUGMENTATION_CHANCES_ACC.each do |ac|
        if ac.weapon_type == "warrior" && ac.stone_id == ls_id
          if ac.variation_id == 1
            selected_chances_12 << ac
          else
            selected_chances_34 << ac
          end
        end
      end
      r = Rnd.rand(10000)
      s = 10000
      selected_chances_12.each do |ac|
        if s > r
          s -= ac.augment_chance * 100
          stat12 = ac.augment_id
        end
      end
      c = Rnd.rand(100)
      if c < 55
        c = 55
      elsif c < 90
        c = 35
      elsif c < 99
        c = 9
      else
        c = 1;
      end
      selected_chances_34_final = [] of AugmentationChanceAcc
      selected_chances_34.each do |ac|
        if ac.category_chance == c
          selected_chances_34_final << ac
        end
      end
      r = Rnd.rand(10000)
      s = 10000
      selected_chances_34_final.each do |ac|
        if s > r
          s -= ac.augment_chance * 100
          stat34 = ac.augment_id
        end
      end

      return L2Augmentation.new((stat34 << 16) + stat12)
    end

    ls_level = Math.min(ls_level, 9)
    base = 0
    skills_length = 0

    case body_part
    when L2Item::SLOT_LR_FINGER
      base = ACC_RING_START + (ACC_RING_BLOCKSIZE * ls_level)
      skills_length = ACC_RING_SKILLS
    when L2Item::SLOT_LR_EAR
      base = ACC_EAR_START + (ACC_EAR_BLOCKSIZE * ls_level)
      skills_length = ACC_EAR_SKILLS
    when L2Item::SLOT_NECK
      base = ACC_NECK_START + (ACC_NECK_BLOCKSIZE * ls_level)
      skills_length = ACC_NECK_SKILLS
    else
      return
    end

    result_color = Rnd.rand(0..3)

    stat12 = Rnd.rand(ACC_STAT_SUBBLOCKSIZE)
    if Rnd.rand(1..100) <= Config.augmentation_acc_skill_chance
      stat34 = base + Rnd.rand(skills_length)
      op = OptionData[stat34]
    end

    if !op || (!op.has_active_skill? && !op.has_passive_skill? && !op.has_activation_skills?)
      stat34 = (stat12 + 1 + Rnd.rand(ACC_STAT_SUBBLOCKSIZE - 1)) % ACC_STAT_SUBBLOCKSIZE
      stat34 = base + skills_length + (ACC_STAT_SUBBLOCKSIZE * result_color) + stat34
    end
    stat12 = base + skills_length + (ACC_STAT_SUBBLOCKSIZE * result_color) + stat12

    debug { "Accessory augmentation success: stat12=#{stat12}, stat34=#{stat34}, level=#{ls_level}." }

    L2Augmentation.new((stat34 << 16) + stat12)
  end
end
