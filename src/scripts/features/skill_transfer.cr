class Scripts::SkillTransfer < AbstractNpcAI
  private HOLY_POMANDER = "HOLY_POMANDER_"
  private POMANDERS = {
    ItemHolder.new(15307, 1), # Cardinal (97)
    ItemHolder.new(15308, 1), # Eva's Saint (105)
    ItemHolder.new(15309, 4)  # Shillen Saint (112)
  }

  def initialize
    super(self.class.simple_name, "features")

    set_player_profession_change_id { |evt| on_profession_change(evt) }
    set_player_profession_cancel_id { |evt| on_profession_cancel(evt) }

    self.on_enter_world = Config.skill_check_enable
  end


  def on_profession_change(event)
    pc = event.active_char
    index = get_transfer_class_index(pc)

    if index < 0
      return
    end

    name = "#{HOLY_POMANDER}#{pc.class_id.to_i}"

    unless pc.variables.get_bool(name, false)
      pc.variables[name] = true
      give_items(pc, POMANDERS[index])
    end
  end

  def on_profession_cancel(event)
    pc = event.active_char
    index = get_transfer_class_index(pc)

    if index < 0
      return
    end

    pomander_id = POMANDERS[index].id
    inv = pc.inventory

    inv.get_all_items_by_item_id(pomander_id).each do |item|
      inv.destroy_item("[HolyPomander - remove]", item, pc, nil)
    end

    name = "#{HOLY_POMANDER}#{event.class_id}"
    pc.variables.delete(name)
  end

  def on_enter_world(pc)
    debug "on_enter_world"
    if !pc.override_skill_conditions? || Config.skill_check_gm
      index = get_transfer_class_index(pc)
      if index < 0
        return super
      end

      count = POMANDERS[index].count - pc.inventory.get_inventory_item_count(POMANDERS[index].id, -1, false)
      pc.all_skills.each do |sk|
        SkillTreesData.get_transfer_skill_tree(pc.class_id).each_value do |s|
          if s.skill_id == sk.id
            #           Holy Weapon
            if sk.id == 1043 && index == 2 && pc.in_stance?
              next
            end

            count -= 1

            if count < 0
              class_name = ClassListData.get_class(pc.class_id).class_name
              Util.punish(pc, "has too many transferred skills or items (id: #{sk.id}, level: #{sk.level}, class: #{class_name}).", IllegalActionPunishmentType::BROADCAST)
              warn { "Illegal count #{count} from #{pc}." }
              if Config.skill_check_remove
                pc.remove_skill(sk)
              end
            end
          end
        end
      end

      if count > 0
        pc.inventory.add_item("[HolyPomander - remove]", POMANDERS[index].id, count, pc, nil)
      end
    end

    super
  end

  private def get_transfer_class_index(pc)
    case pc.class_id
    when .cardinal?
      0
    when .eva_saint?
      1
    when .shillien_saint?
      2
    else
      -1
    end
  end
end
