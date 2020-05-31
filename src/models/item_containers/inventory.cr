require "./item_container"

abstract class Inventory < ItemContainer
  ADENA_ID = 57
  ANCIENT_ADENA_ID = 5575
  MAX_ARMOR_WEIGHT = 12_000.0

  def self.max_adena : Int64
    Config.max_adena
  end

  {% for slot, i in %w[
    UNDER HEAD HAIR HAIR2 NECK RHAND CHEST LHAND REAR LEAR GLOVES LEGS FEET
    RFINGER LFINGER LBRACELET RBRACELET DECO1 DECO2 DECO3 DECO4 DECO5 DECO6
    CLOAK BELT TOTALSLOTS
  ] %}
    {{slot.id}} = {{i}}

    {% if slot != "TOTALSLOTS" %}
      def {{slot.downcase.id}}_slot : L2ItemInstance?
        @paperdoll[{{i}}]
      end

      def {{slot.downcase.id}}_slot=(item : L2ItemInstance?)
        self[{{i}}] = item
      end

      def {{slot.downcase.id}}_slot_empty? : Bool
        @paperdoll[{{i}}].nil?
      end
    {% end %}
  {% end %}

  @paperdoll = Slice(L2ItemInstance?).new(TOTALSLOTS, nil.as(L2ItemInstance?))
  @paperdoll_listeners = [] of PaperdollListener

  getter total_weight = 0
  getter mask = 0

  def initialize
    add_paperdoll_listener(StatsListener)
  end

  delegate size, to: @paperdoll

  private module PaperdollListener
    abstract def notify_equipped(slot, item, inv)
    abstract def notify_unequipped(slot, item, inv)
  end

  private struct ChangeRecorder
    include PaperdollListener

    getter changed_items = [] of L2ItemInstance

    # L2J has 'inventory' as an instance variable but doesn't use it anywhere
    # outside the initializer.
    def initialize(inventory : Inventory)
      inventory.add_paperdoll_listener(self)
    end

    def notify_equipped(slot, item, inv)
      unless @changed_items.includes?(item)
        @changed_items << item
      end
    end

    def notify_unequipped(slot, item, inv)
      unless @changed_items.includes?(item)
        @changed_items << item
      end
    end
  end

  private module BowCrossRodListener
    extend self
    extend PaperdollListener

    def notify_equipped(slot, item, inv)
      return unless slot == RHAND

      if item.item_type == WeaponType::BOW
        if arrow = inv.find_arrow_for_bow(item.template.as(L2Weapon))
          inv.lhand_slot = arrow
        end
      elsif item.item_type == WeaponType::CROSSBOW
        if bolt = inv.find_bolt_for_crossbow(item.template.as(L2Weapon))
          inv.lhand_slot = bolt
        end
      end
    end

    def notify_unequipped(slot, item, inv)
      return unless slot == RHAND

      case item.item_type
      when WeaponType::BOW, WeaponType::CROSSBOW, WeaponType::FISHINGROD
        if inv.lhand_slot
          inv.lhand_slot = nil
        end
      else
        # [automatically added else]
      end

    end
  end

  private module StatsListener
    extend self
    extend PaperdollListener

    def notify_equipped(slot : Int32, item : L2ItemInstance, inv : Inventory)
      inv.owner.add_stat_funcs(item.get_stat_funcs(inv.owner))
    end

    def notify_unequipped(slot : Int32, item : L2ItemInstance, inv : Inventory)
      inv.owner.remove_stats_owner(item)
    end
  end

  private module ItemSkillsListener
    extend self
    extend PaperdollListener

    def notify_equipped(slot, item, inv)
      return unless pc = inv.owner.as?(L2PcInstance)

      it = item.template
      update = false
      update_time_stamp = false

      if item.augmented?
        item.augmentation.apply_bonus(pc)
      end

      item.recharge_shots(true, true)
      item.update_element_attr_bonus(pc)

      if item.enchant_level >= 4
        if enchant_4_skill = it.enchant_4_skill
          pc.add_skill(enchant_4_skill, false)
          update = true
        end
      end

      item.apply_enchant_stats

      if skills = it.skills
        skills.each do |holder|
          if item_skill = holder.skill?
            item_skill.reference_item_id = item.id
            pc.add_skill(item_skill, false)
            if item_skill.active?
              unless pc.has_skill_reuse?(item_skill.hash)
                equip_delay = item.equip_reuse_delay
                if equip_delay > 0
                  pc.add_time_stamp(item_skill, equip_delay.to_i64)
                  pc.disable_skill(item_skill, equip_delay.to_i64)
                end
              end
              update_time_stamp = true
            end
            update = true
          end
        end
      end

      if update
        pc.send_skill_list
        if update_time_stamp
          pc.send_packet(Packets::Outgoing::SkillCoolTime.new(pc))
        end
      end
    end

    def notify_unequipped(slot, item, inv)
      return unless pc = inv.owner.as?(L2PcInstance)

      it = item.template
      update = false
      update_time_stamp = false

      item.augmentation?.try &.remove_bonus(pc)
      item.uncharge_all_shots
      item.remove_element_attr_bonus(pc)

      if item.enchant_level >= 4
        if enchant_4_skill = it.enchant_4_skill
          pc.remove_skill(enchant_4_skill, false, enchant_4_skill.passive?)
          update = true
        end
      end

      item.clear_enchant_stats

      if skills = it.skills
        skills.each do |holder|
          if item_skill = holder.skill
            pc.remove_skill(item_skill, false, item_skill.passive?)
            update = true
          end
        end
      end

      if item.armor?
        inv.items.each do |itm|
          if !itm.equipped? || !itm.template.skills || itm == item
            next
          end

          itm.template.skills.try &.each do |sk|
            if pc.get_skill_level(sk.skill_id) != -1
              next
            end

            if item_skill = sk.skill?
              pc.add_skill(item_skill, false)
              if item_skill.active?
                unless pc.has_skill_reuse?(item_skill.hash)
                  equip_delay = item.equip_reuse_delay
                  if equip_delay > 0
                    pc.add_time_stamp(item_skill, equip_delay.to_i64)
                    pc.disable_skill(item_skill, equip_delay.to_i64)
                  end
                end
                update_time_stamp = true
              end
              update = true
            end
          end
        end
      end

      if unequip_skill = it.unequip_skill
        unequip_skill.activate_skill(pc, pc)
      end

      if update
        pc.send_skill_list
        if update_time_stamp
          pc.send_packet(Packets::Outgoing::SkillCoolTime.new(pc))
        end
      end
    end
  end

  private module ArmorSetListener
    extend self
    extend PaperdollListener

    def notify_equipped(slot, item, inv)
      return unless pc = inv.owner.as?(L2PcInstance)
      return unless chest_item = inv.chest_slot

      return unless armor_set = ArmorSetsData[chest_item.id]

      update = false
      update_time_stamp = false

      if armor_set.contains_item?(slot, item.id)
        if armor_set.contains_all?(pc)
          armor_set.skills.each do |sh|
            if item_skill = sh.skill?
              pc.add_skill(item_skill, false)
              if item_skill.active?
                unless pc.has_skill_reuse?(item_skill.hash)
                  equip_delay = item.equip_reuse_delay
                  if equip_delay > 0
                    pc.add_time_stamp(item_skill, equip_delay.to_i64)
                    pc.disable_skill(item_skill, equip_delay.to_i64)
                  end
                end
                update_time_stamp = true
              end
              update = true
            end
          end

          if armor_set.contains_shield?(pc)
            armor_set.shield_skills.each do |sh|
              if skill = sh.skill?
                pc.add_skill(skill, false)
                update = true
              end
            end
          end

          if armor_set.enchanted_6?(pc)
            armor_set.enchant_6_skill_id.each do |sh|
              if skill = sh.skill?
                pc.add_skill(skill, false)
                update = true
              end
            end
          end
        end
      elsif armor_set.contains_shield?(item.id)
        armor_set.shield_skills.each do |sh|
          if skill = sh.skill?
            pc.add_skill(skill, false)
            update = true
          end
        end
      end

      if update
        pc.send_skill_list

        if update_time_stamp
          pc.send_packet(Packets::Outgoing::SkillCoolTime.new(pc))
        end
      end
    end

    def notify_unequipped(slot, item, inv)
      return unless pc = inv.owner.as?(L2PcInstance)

      remove = false

      if slot == CHEST
        return unless armor_set = ArmorSetsData[item.id]
        remove = true
        skills = armor_set.skills
        shield_skill = armor_set.shield_skills
        skill_id_6 = armor_set.enchant_6_skill
      else
        return unless chest_item = inv.chest_slot
        return unless armor_set = ArmorSetsData[chest_item.id]
        if armor_set.contains_item?(slot, item.id)
          remove = true
          skills = armor_set.skills
          shield_skill = armor_set.shield_skills
          skill_id_6 = armor_set.enchant_6_skill
        elsif armor_set.contains_shield?(item.id)
          remove = true
          shield_skill = armor_set.shield_skills
        end
      end

      if remove
        skills.try &.each do |sh|
          if item_skill = sh.skill?
            pc.remove_skill(item_skill, false, item_skill.passive?)
          end
        end

        shield_skill.try &.each do |sh|
          if item_skill = sh.skill?
            pc.remove_skill(item_skill, false, item_skill.passive?)
          end
        end

        skill_id_6.try &.each do |sh|
          if item_skill = sh.skill?
            pc.remove_skill(item_skill, false, item_skill.passive?)
          end
        end

        pc.check_item_restriction
        pc.send_skill_list
      end
    end
  end

  private module BraceletListener
    extend self
    extend PaperdollListener

    def notify_equipped(slot, item, inv)
      # no-op
    end

    def notify_unequipped(slot, item, inv)
      if item.template.body_part == L2Item::SLOT_R_BRACELET
        inv.unequip_item_in_slot(DECO1)
        inv.unequip_item_in_slot(DECO2)
        inv.unequip_item_in_slot(DECO3)
        inv.unequip_item_in_slot(DECO4)
        inv.unequip_item_in_slot(DECO5)
        inv.unequip_item_in_slot(DECO6)
      end
    end
  end

  abstract def equip_location : ItemLocation

  def drop_item(process : String?, item : L2ItemInstance?, actor : L2PcInstance, reference) : L2ItemInstance?
    return unless item

    item.sync do
      return unless @items.includes?(item)

      remove_item(item)
      item.set_owner_id(process, 0, actor, reference)
      item.item_location = ItemLocation::VOID
      item.last_change = L2ItemInstance::REMOVED

      item.update_database
      refresh_weight
    end

    item
  end

  def drop_item(process : String?, l2id : Int, count : Int, actor : L2PcInstance, reference) : L2ItemInstance?
    return unless item = get_item_by_l2id(l2id)

    item.sync do
      return unless @items.includes?(item)

      if item.count > count
        item.change_count(process, -count, actor, reference)
        item.last_change = L2ItemInstance::MODIFIED
        item.update_database

        item = ItemTable.create_item(process, item.id, count, actor, reference)
        item.update_database
        refresh_weight
        return item
      end
    end

    drop_item(process, item, actor, reference)
  end

  def add_item(item : L2ItemInstance)
    super
    equip_item(item) if item.equipped?
  end

  def remove_item(item : L2ItemInstance) : Bool
    if slot = @paperdoll.index(item)
      unequip_item_in_slot(slot)
    end

    super
  end

  # L2J: getPaperdollItem
  def [](slot : Int) : L2ItemInstance?
    @paperdoll.fetch(slot) { raise "Slot #{slot} outside of inventory bounds" }
  end

  # L2J: isPaperdollSlotEmpty
  def slot_empty?(slot : Int) : Bool
    self[slot].nil?
  end

  def self.get_paperdoll_index(slot : Int) : Int32
    case slot
    when L2Item::SLOT_UNDERWEAR
      UNDER
    when L2Item::SLOT_R_EAR
      REAR
    when L2Item::SLOT_LR_EAR, L2Item::SLOT_L_EAR
      LEAR
    when L2Item::SLOT_NECK
      NECK
    when L2Item::SLOT_R_FINGER, L2Item::SLOT_LR_FINGER
      RFINGER
    when L2Item::SLOT_L_FINGER
      LFINGER
    when L2Item::SLOT_HEAD
      HEAD
    when L2Item::SLOT_R_HAND, L2Item::SLOT_LR_HAND
      RHAND
    when L2Item::SLOT_L_HAND
      LHAND
    when L2Item::SLOT_GLOVES
      GLOVES
    when L2Item::SLOT_CHEST, L2Item::SLOT_FULL_ARMOR, L2Item::SLOT_ALLDRESS
      CHEST
    when L2Item::SLOT_LEGS
      LEGS
    when L2Item::SLOT_FEET
      FEET
    when L2Item::SLOT_BACK
      CLOAK
    when L2Item::SLOT_HAIR, L2Item::SLOT_HAIRALL
      HAIR
    when L2Item::SLOT_HAIR2
      HAIR2
    when L2Item::SLOT_R_BRACELET
      RBRACELET
    when L2Item::SLOT_L_BRACELET
      LBRACELET
    when L2Item::SLOT_DECO
      DECO1 # return first we deal with it later
    when L2Item::SLOT_BELT
      BELT
    else
      -1
    end
  end

  def get_paperdoll_item_by_l2_item_id(slot : Int) : L2ItemInstance?
    index = Inventory.get_paperdoll_index(slot)
    self[index] unless index == -1
  end

  def get_paperdoll_item_id(slot : Int) : Int32
    self[slot].try &.id || 0
  end

  def get_paperdoll_item_display_id(slot : Int) : Int32
    self[slot].try &.display_id || 0
  end

  def get_paperdoll_augmentation_id(slot : Int) : Int32
    self[slot].try &.augmentation?.try &.augmentation_id || 0
  end

  def get_paperdoll_l2id(slot : Int) : Int32
    self[slot].try &.l2id || 0
  end

  def add_paperdoll_listener(listener : PaperdollListener)
    sync do
      if @paperdoll_listeners.includes?(listener)
        fatal { "@paperdoll_listeners should not already include #{listener}." }
      end
      @paperdoll_listeners << listener
    end
  end

  def remove_paperdoll_listener(listener : PaperdollListener)
    sync { @paperdoll_listeners.delete_first(listener) }
  end

  # L2J: setPaperdollItem
  def []=(slot : Int, item : L2ItemInstance?) : L2ItemInstance?
    sync do
      old = self[slot]

      if old != item
        if old
          @paperdoll[slot] = nil
          old.item_location = base_location
          old.last_change = L2ItemInstance::MODIFIED

          mask = 0
          @paperdoll.each { |itm| mask |= itm.mask if itm }

          @mask = mask
          @paperdoll_listeners.each &.notify_unequipped(slot, old, self)

          old.update_database
        end

        if item
          @paperdoll[slot] = item
          item.set_item_location(equip_location, slot)
          item.last_change = L2ItemInstance::MODIFIED
          @mask |= item.mask
          @paperdoll_listeners.each &.notify_equipped(slot, item, self)
          item.update_database
        end
      end

      old
    end
  end

  def get_slot_from_item(item : L2ItemInstance) : Int32
    case item.location_slot
    when UNDER        then L2Item::SLOT_UNDERWEAR
    when LEAR         then L2Item::SLOT_L_EAR
    when REAR         then L2Item::SLOT_R_EAR
    when NECK         then L2Item::SLOT_NECK
    when RFINGER      then L2Item::SLOT_R_FINGER
    when LFINGER      then L2Item::SLOT_L_FINGER
    when HAIR         then L2Item::SLOT_HAIR
    when HAIR2        then L2Item::SLOT_HAIR2
    when HEAD         then L2Item::SLOT_HEAD
    when RHAND        then L2Item::SLOT_R_HAND
    when LHAND        then L2Item::SLOT_L_HAND
    when GLOVES       then L2Item::SLOT_GLOVES
    when CHEST        then item.body_part
    when LEGS         then L2Item::SLOT_LEGS
    when CLOAK        then L2Item::SLOT_BACK
    when FEET         then L2Item::SLOT_FEET
    when LBRACELET    then L2Item::SLOT_L_BRACELET
    when RBRACELET    then L2Item::SLOT_R_BRACELET
    when DECO1..DECO6 then L2Item::SLOT_DECO
    when BELT         then L2Item::SLOT_BELT
    else -1
    end
  end

  def unequip_item_in_body_slot_and_record(slot : Int)
    recorder = ChangeRecorder.new(self)

    begin
      unequip_item_in_body_slot(slot)
    ensure
      remove_paperdoll_listener(recorder)
    end

    recorder.changed_items
  end

  def unequip_item_in_slot(slot : Int)
    self[slot] = nil
  end

  def unequip_item_in_slot_and_record(slot : Int)
    recorder = ChangeRecorder.new(self)

    begin
      unequip_item_in_slot(slot)
      owner.refresh_expertise_penalty if owner.player?
    ensure
      remove_paperdoll_listener(recorder)
    end

    recorder.changed_items
  end

  def unequip_item_in_body_slot(slot : Int)
    paperdoll_slot =
    case slot
    when L2Item::SLOT_L_EAR
      LEAR
    when L2Item::SLOT_R_EAR
      REAR
    when L2Item::SLOT_NECK
      NECK
    when L2Item::SLOT_R_FINGER
      RFINGER
    when L2Item::SLOT_L_FINGER
      LFINGER
    when L2Item::SLOT_HAIR
      HAIR
    when L2Item::SLOT_HAIR2
      HAIR2
    when L2Item::SLOT_HAIRALL
      self[HAIR] = nil
      HAIR
    when L2Item::SLOT_HEAD
      HEAD
    when L2Item::SLOT_R_HAND, L2Item::SLOT_LR_HAND
      RHAND
    when L2Item::SLOT_L_HAND
      LHAND
    when L2Item::SLOT_GLOVES
      GLOVES
    when L2Item::SLOT_CHEST, L2Item::SLOT_ALLDRESS, L2Item::SLOT_FULL_ARMOR
      CHEST
    when L2Item::SLOT_LEGS
      LEGS
    when L2Item::SLOT_BACK
      CLOAK
    when L2Item::SLOT_FEET
      FEET
    when L2Item::SLOT_UNDERWEAR
      UNDER
    when L2Item::SLOT_L_BRACELET
      LBRACELET
    when L2Item::SLOT_R_BRACELET
      RBRACELET
    when L2Item::SLOT_DECO
      DECO1
    when L2Item::SLOT_BELT
      BELT
    else
      warn { "Inventory#unequip_item_in_body_slot: unhandled slot #{slot}." }
      -1
    end

    if paperdoll_slot >= 0
      if old = self[paperdoll_slot] = nil
        owner.refresh_expertise_penalty if owner.player?
      end

      return old
    end
  end

  def equip_item_and_record(item : L2ItemInstance)
    recorder = ChangeRecorder.new(self)

    begin
      equip_item(item)
    rescue e
      warn e
    ensure
      remove_paperdoll_listener(recorder)
    end

    recorder.changed_items
  end

  def equip_item(item : L2ItemInstance)
    owner = owner?
    if owner.is_a?(L2PcInstance)
      return unless owner.private_store_type.none?
      if !owner.override_item_conditions? && !owner.hero? && item.hero_item?
        return
      end
    end

    target_slot = item.body_part

    formal = chest_slot
    if item.id != 21163 && formal
      if formal.template.body_part == L2Item::SLOT_ALLDRESS
        case target_slot
        when L2Item::SLOT_LR_HAND, L2Item::SLOT_L_HAND, L2Item::SLOT_R_HAND,
             L2Item::SLOT_LEGS, L2Item::SLOT_FEET, L2Item::SLOT_GLOVES,
             L2Item::SLOT_HEAD
          return
        else
          # [automatically added else]
        end

      end
    end

    case target_slot
    when L2Item::SLOT_LR_HAND
      self[LHAND] = nil
      self[RHAND] = item
    when L2Item::SLOT_L_HAND
      rh = rhand_slot
      if rh && rh.body_part == L2Item::SLOT_LR_HAND && !(((rh.item_type == WeaponType::BOW) && (item.item_type == EtcItemType::ARROW)) || ((rh.item_type == WeaponType::CROSSBOW) && (item.item_type == EtcItemType::BOLT)) || ((rh.item_type == WeaponType::FISHINGROD) && (item.item_type == EtcItemType::LURE)))
        self[RHAND] = nil
      end
      self[LHAND] = item
    when L2Item::SLOT_R_HAND
      self[RHAND] = item
    when L2Item::SLOT_L_EAR, L2Item::SLOT_R_EAR, L2Item::SLOT_LR_EAR
      if @paperdoll[LEAR].nil?
        self[LEAR] = item
      elsif @paperdoll[REAR].nil?
        self[REAR] = item
      else
        self[LEAR] = item
      end
    when L2Item::SLOT_L_FINGER, L2Item::SLOT_R_FINGER, L2Item::SLOT_LR_FINGER
      if @paperdoll[LFINGER].nil?
        self[LFINGER] = item
      elsif @paperdoll[RFINGER].nil?
        self[RFINGER] = item
      else
        self[LFINGER] = item
      end
    when L2Item::SLOT_NECK
      self[NECK] = item
    when L2Item::SLOT_FULL_ARMOR
      self[LEGS] = nil
      self[CHEST] = item
    when L2Item::SLOT_CHEST
      self[CHEST] = item
    when L2Item::SLOT_LEGS
      chest = chest_slot
      if chest && chest.body_part == L2Item::SLOT_FULL_ARMOR
        self[CHEST] = nil
      end
      self[LEGS] = item
    when L2Item::SLOT_FEET
      self[FEET] = item
    when L2Item::SLOT_GLOVES
      self[GLOVES] = item
    when L2Item::SLOT_HEAD
      self[HEAD] = item
    when L2Item::SLOT_HAIR
      hair = hair_slot
      if hair && hair.body_part == L2Item::SLOT_HAIRALL
        self[HAIR2] = nil
      else
        self[HAIR] = nil
      end
      self[HAIR] = item
    when L2Item::SLOT_HAIR2
      hair2 = hair_slot
      if hair2 && hair2.body_part == L2Item::SLOT_HAIRALL
        self[HAIR] = nil
      else
        self[HAIR2] = nil
      end
      self[HAIR2] = item
    when L2Item::SLOT_HAIRALL
      self[HAIR2] = nil
      self[HAIR] = item
    when L2Item::SLOT_UNDERWEAR
      self[UNDER] = item
    when L2Item::SLOT_BACK
      self[CLOAK] = item
    when L2Item::SLOT_L_BRACELET
      self[LBRACELET] = item
    when L2Item::SLOT_R_BRACELET
      self[RBRACELET] = item
    when L2Item::SLOT_DECO
      equip_talisman(item)
    when L2Item::SLOT_BELT
      self[BELT] = item
    when L2Item::SLOT_ALLDRESS # formal dress
      self[LEGS] = nil
      self[LHAND] = nil
      self[RHAND] = nil
      self[RHAND] = nil
      self[LHAND] = nil
      self[HEAD] = nil
      self[FEET] = nil
      self[GLOVES] = nil
      self[CHEST] = item
    else
      warn { "Unknown body slot #{target_slot} for item ID #{item.id}." }
    end
  end

  protected def refresh_weight
    weight = @items.sum { |item| item.template.weight.to_i64 * item.count }
    @total_weight = Math.min(weight, Int32::MAX).to_i
  end

  def find_arrow_for_bow(bow : L2Weapon?) : L2ItemInstance?
    return unless bow
    @items.find do |item|
      item.etc_item? &&
      item.template.item_grade_s_plus == bow.item_grade_s_plus &&
      item.item_type == EtcItemType::ARROW
    end
  end

  def find_bolt_for_crossbow(crossbow : L2Weapon?) : L2ItemInstance?
    return unless crossbow
    @items.find do |item|
      item.etc_item? &&
      item.template.item_grade_s_plus == crossbow.item_grade_s_plus &&
      item.item_type == EtcItemType::BOLT
    end
  end

  def restore
    sql = "SELECT object_id, item_id, count, enchant_level, loc, loc_data, custom_type1, custom_type2, mana_left, time FROM items WHERE owner_id=? AND (loc=? OR loc=?) ORDER BY loc_data"
    GameDB.each(sql, owner_id, base_location.to_s, equip_location.to_s) do |rs|
      unless item = L2ItemInstance.restore_from_db(owner_id, rs)
        next
      end

      if pc = owner?.as?(L2PcInstance)
        if !pc.override_item_conditions? && !pc.hero? && item.hero_item?
          item.item_location = ItemLocation::INVENTORY
        end
      end

      L2World.store_object(item)

      if item.stackable? && get_item_by_item_id(item.id)
        add_item("Restore", item, owner.acting_player, nil)
      else
        add_item(item)
      end
    end

    refresh_weight
  rescue e
    error e
  end

  def talisman_slots : Int32
    owner.acting_player.not_nil!.stat.talisman_slots
  end

  def equip_talisman(item : L2ItemInstance)
    return if talisman_slots.zero?

    (DECO1...DECO1 + talisman_slots).each do |i|
      if self[i]
        if get_paperdoll_item_id(i) == item.id
          self[i] = item
          return
        end
      end
    end

    (DECO1...DECO1 + talisman_slots).each do |i|
      unless self[i]
        self[i] = item
        return
      end
    end

    self[DECO1] = item
  end

  def can_equip_cloak? : Bool
    owner.acting_player.not_nil!.stat.can_equip_cloak?
  end

  def reload_equipped_items
    @paperdoll.each do |item|
      next unless item
      slot = item.location_slot

      @paperdoll_listeners.each do |listener|
        listener.notify_unequipped(slot, item, self)
        listener.notify_equipped(slot, item, self)
      end
    end
  end
end
