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

  private def parse_document(doc, file)
    set = StatsSet.new
    class_id = 0
    data_count = 0

    doc.find_element("list") do |list|
      list.each_element do |d|
        case d.name.casecmp
        when "classId"
          class_id = d.text.to_i
        when "staticdata"
          set = StatsSet.new
          set["classId"] = class_id
          d.each_element do |nd|
            next if nd.name.casecmp?("text")
            if nd.children.size > 1
              nd.each_element do |cnd|
                if nd.name.casecmp?("collisionMale")
                  if cnd.name.casecmp?("radius")
                    set["collisionRadius"] = cnd.text
                  elsif cnd.name.casecmp?("height")
                    set["collisionHeight"] = cnd.text
                  end
                end

                if cnd.name.casecmp?("walk")
                  set["baseWalkSpd"] = cnd.text
                elsif cnd.name.casecmp?("run")
                  set["baseRunSpd"] = cnd.text
                elsif cnd.name.casecmp?("slowSwim")
                  set["baseSwimWalkSpd"] = cnd.text
                elsif cnd.name.casecmp?("fastSwim")
                  set["baseSwimRunSpd"] = cnd.text
                elsif cnd.name != "text"
                  set[nd.name + cnd.name] = cnd.text
                end
              end
            else
              set[nd.name] = nd.text
            end
          end
          set["basePDef"] = set.get_i32("basePDefchest", 0) + set.get_i32("basePDeflegs", 0) + set.get_i32("basePDefhead", 0) + set.get_i32("basePDeffeet", 0) + set.get_i32("basePDefgloves", 0) + set.get_i32("basePDefunderwear", 0) + set.get_i32("basePDefcloak", 0)
          set["baseMDef"] = set.get_i32("baseMDefrear", 0) + set.get_i32("baseMDeflear", 0) + set.get_i32("baseMDefrfinger", 0) + set.get_i32("baseMDefrfinger", 0) + set.get_i32("baseMDefneck", 0)
          template = L2PcTemplate.new(set)
          TEMPLATES[ClassId[class_id]] = template
         when "lvlUpgainData"
          d.each_element do |ln|
            if ln.name.casecmp?("level")
              level = ln["val"].to_i
              ln.each_element do |vn|
                name = vn.name
                if name.starts_with?("hp", "mp", "cp")
                  if tmp = TEMPLATES[ClassId[class_id]]?
                    tmp.set_upgain_value(name, level, vn.text.to_f)
                    data_count += 1
                  end
                end
              end
            end
          end
        else
          # [automatically added else]
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
