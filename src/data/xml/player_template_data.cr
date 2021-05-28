require "../../models/actor/templates/l2_pc_template"

module PlayerTemplateData
  extend self
  extend XMLReader

  private TEMPLATES = EnumMap(ClassId, L2PcTemplate).new
  private NEW_CHARACTER_TEMPLATES = [] of L2PcTemplate

  def load
    TEMPLATES.clear
    timer = Timer.new
    parse_datapack_directory("stats/chars/baseStats")
    info { "Loaded #{TEMPLATES.size} templates in #{timer} s." }
  end

  private def parse_document(doc : XML::Node, file : File)
    set = StatsSet.new
    class_id = 0
    data_count = 0

    find_element(doc, "list") do |list|
      each_element(list) do |d, d_name|
        case d_name.casecmp
        when "classId"
          class_id = get_content(d).to_i
        when "staticdata"
          set = StatsSet.new
          set["classId"] = class_id
          each_element(d) do |nd, nd_name|
            next if nd_name.casecmp?("text")
            if get_children(nd).size > 1
              each_element(nd) do |cnd, cnd_name|
                if nd_name.casecmp?("collisionMale")
                  if cnd_name.casecmp?("radius")
                    set["collisionRadius"] = get_content(cnd)
                  elsif cnd_name.casecmp?("height")
                    set["collisionHeight"] = get_content(cnd)
                  end
                end

                if cnd_name.casecmp?("walk")
                  set["baseWalkSpd"] = get_content(cnd)
                elsif cnd_name.casecmp?("run")
                  set["baseRunSpd"] = get_content(cnd)
                elsif cnd_name.casecmp?("slowSwim")
                  set["baseSwimWalkSpd"] = get_content(cnd)
                elsif cnd_name.casecmp?("fastSwim")
                  set["baseSwimRunSpd"] = get_content(cnd)
                elsif cnd_name != "text"
                  set[nd_name + cnd_name] = get_content(cnd)
                end
              end
            else
              set[nd_name] = get_content(nd)
            end
          end
          set["basePDef"] = set.get_i32("basePDefchest", 0) &+ set.get_i32("basePDeflegs", 0) &+ set.get_i32("basePDefhead", 0) &+ set.get_i32("basePDeffeet", 0) &+ set.get_i32("basePDefgloves", 0) &+ set.get_i32("basePDefunderwear", 0) &+ set.get_i32("basePDefcloak", 0)
          set["baseMDef"] = set.get_i32("baseMDefrear", 0) &+ set.get_i32("baseMDeflear", 0) &+ set.get_i32("baseMDefrfinger", 0) &+ set.get_i32("baseMDefrfinger", 0) &+ set.get_i32("baseMDefneck", 0)
          TEMPLATES[ClassId[class_id]] = L2PcTemplate.new(set)
         when "lvlUpgainData"
          find_element(d, "level") do |ln|
            level = parse_int(ln, "val")
            each_element(ln) do |vn, vn_name|
              if vn_name.starts_with?("hp", "mp", "cp")
                if tmp = TEMPLATES[ClassId[class_id]]?
                  tmp.set_upgain_value(vn_name, level, get_content(vn).to_f)
                  data_count &+= 1
                end
              end
            end
          end
        end
      end
    end
  end

  def [](id : Int32) : L2PcTemplate
    class_id = ClassId.fetch(id) { raise "No ClassId with id #{id}" }
    self[class_id]
  end

  def [](id : ClassId) : L2PcTemplate
    TEMPLATES.fetch(id) { raise "No player template for ClassId #{id}" }
  end

  def new_character_templates : Array(L2PcTemplate)
    if NEW_CHARACTER_TEMPLATES.empty?
      NEW_CHARACTER_TEMPLATES << TEMPLATES[ClassId::FIGHTER]
      NEW_CHARACTER_TEMPLATES << TEMPLATES[ClassId::MAGE]
      NEW_CHARACTER_TEMPLATES << TEMPLATES[ClassId::ELVEN_FIGHTER]
      NEW_CHARACTER_TEMPLATES << TEMPLATES[ClassId::ELVEN_MAGE]
      NEW_CHARACTER_TEMPLATES << TEMPLATES[ClassId::DARK_FIGHTER]
      NEW_CHARACTER_TEMPLATES << TEMPLATES[ClassId::DARK_MAGE]
      NEW_CHARACTER_TEMPLATES << TEMPLATES[ClassId::ORC_FIGHTER]
      NEW_CHARACTER_TEMPLATES << TEMPLATES[ClassId::ORC_MAGE]
      NEW_CHARACTER_TEMPLATES << TEMPLATES[ClassId::DWARVEN_FIGHTER]
      NEW_CHARACTER_TEMPLATES << TEMPLATES[ClassId::MALE_SOLDIER]
      NEW_CHARACTER_TEMPLATES << TEMPLATES[ClassId::FEMALE_SOLDIER]
    end

    NEW_CHARACTER_TEMPLATES
  end
end
