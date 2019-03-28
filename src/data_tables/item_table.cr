module ItemTable
  extend self
  extend Loggable

  private TEMPLATES = [] of L2Item?
  private ETC_ITEMS = {} of Int32 => L2EtcItem
  private ARMORS    = {} of Int32 => L2Armor
  private WEAPONS   = {} of Int32 => L2Weapon

  SLOTS = {
    "shirt" => L2Item::SLOT_UNDERWEAR,
    "lbracelet" => L2Item::SLOT_L_BRACELET,
    "rbracelet" => L2Item::SLOT_R_BRACELET,
    "talisman" => L2Item::SLOT_DECO,
    "chest" => L2Item::SLOT_CHEST,
    "fullarmor" => L2Item::SLOT_FULL_ARMOR,
    "head" => L2Item::SLOT_HEAD,
    "hair" => L2Item::SLOT_HAIR,
    "hairall" => L2Item::SLOT_HAIRALL,
    "underwear" => L2Item::SLOT_UNDERWEAR,
    "back" => L2Item::SLOT_BACK,
    "neck" => L2Item::SLOT_NECK,
    "legs" => L2Item::SLOT_LEGS,
    "feet" => L2Item::SLOT_FEET,
    "gloves" => L2Item::SLOT_GLOVES,
    "chest,legs" => L2Item::SLOT_CHEST | L2Item::SLOT_LEGS,
    "belt" => L2Item::SLOT_BELT,
    "rhand" => L2Item::SLOT_R_HAND,
    "lhand" => L2Item::SLOT_L_HAND,
    "lrhand" => L2Item::SLOT_LR_HAND,
    "rear;lear" => L2Item::SLOT_R_EAR | L2Item::SLOT_L_EAR,
    "rfinger;lfinger" => L2Item::SLOT_R_FINGER | L2Item::SLOT_L_FINGER,
    "wolf" => L2Item::SLOT_WOLF,
    "greatwolf" => L2Item::SLOT_GREATWOLF,
    "hatchling" => L2Item::SLOT_HATCHLING,
    "strider" => L2Item::SLOT_STRIDER,
    "babypet" => L2Item::SLOT_BABYPET,
    "none" => L2Item::SLOT_NONE,

    # retail compatibility
    "onepiece" => L2Item::SLOT_FULL_ARMOR,
    "hair2" => L2Item::SLOT_HAIR2,
    "dhair" => L2Item::SLOT_HAIRALL,
    "alldress" => L2Item::SLOT_ALLDRESS,
    "deco1" => L2Item::SLOT_DECO,
    "waist" => L2Item::SLOT_BELT
  }

  def load
    ARMORS.clear
    ETC_ITEMS.clear
    WEAPONS.clear

    info "Loading items..."
    timer = Timer.new
    highest = 0
    DocumentEngine.load_items.each do |item|
      if highest < item.id
        highest = item.id
      end

      case item
      when L2EtcItem
        ETC_ITEMS[item.id] = item
      when L2Armor
        ARMORS[item.id] = item
      when L2Weapon
        WEAPONS[item.id] = item
      end
    end

    0.upto(highest) do |i|
      TEMPLATES << (ARMORS[i]? || ETC_ITEMS[i]? || WEAPONS[i]?)
    end
    TEMPLATES.trim

    info "Loaded #{a = ETC_ITEMS.size} etc item templates."
    info "Loaded #{b = ARMORS.size} armor item templates."
    info "Loaded #{c = WEAPONS.size} weapon item templates."
    info "Loaded #{a + b + c} item templates in #{timer.result} s."
  end

  def [](id : Int) : L2Item
    unless item = self[id]?
      raise "No item template with id #{id}"
    end

    item
  end

  def []?(index : Int) : L2Item?
    TEMPLATES[index]
  end

  def create_item(process : String?, item_id : Int32, count : Int64, actor : L2PcInstance?, reference = nil) : L2ItemInstance
    item = L2ItemInstance.new(IdFactory.next, item_id)

    if process && process.casecmp?("loot")
      # TODO: command channel and other stuff
    end

    # if Config::DEBUG
    #   debug "Created item with oid #{item.l2id} and item id #{item.id}."
    # end

    L2World.store_object(item)

    if item.stackable? && count > 1
      item.count = count
    end

    # TODO: Config::LOG_ITEMS

    if actor && actor.gm? && Config.gmaudit
      ref = "no-reference"
      case reference
      when L2Object
        ref = reference.name || "no-name"
      when String
        ref = reference
      end
      name = actor.target.try &.name || "no-name"
      GMAudit.log(actor, "#{process} (id: #{item_id}, count: #{item.count}, name: #{item.item_name}, item_obj_id: #{item.l2id})", name, "L2Object referencing this action is: #{ref}")
    end

    OnItemCreate.new(process, item, actor, reference).async(item.template)

    item
  end

  def destroy_item(process : String?, item : L2ItemInstance, actor : L2PcInstance?, reference)
    item.sync do
      item.count = 0
      item.owner_id = 0
      item.item_location = :VOID
      item.last_change = L2ItemInstance::REMOVED

      L2World.remove_object(item)
      IdFactory.release(item.l2id)

      if Config.log_items
        # TODO
      end

      if actor && actor.gm? && Config.gmaudit
        ref = "no-reference"
        case reference
        when L2Object
          ref = reference.name || "no-name"
        when String
          ref = reference
        end
        name = actor.target.try &.name || "no-target"
        GMAudit.log(actor, "#{process} (id: #{item.id}, count: #{item.count}, item_obj_id: #{item.l2id})", name, "L2Object referencing this action is: #{ref}")
      end

      if item.pet_item?
        begin
          GameDB.exec("DELETE FROM pets WHERE item_obj_id=?", item.l2id)
        rescue e
          error { "Failed to delete pet associated with #{item}." }
          error e
        else
          debug { "Deleted a pet associated with #{item}." }
        end
      end
    end
  end

  def reload
    load
    EnchantItemHPBonusData.load
  end

  def all_armors_id : Enumerable(Int32)
    ARMORS.local_each_key
  end

  def all_weapons_id : Enumerable(Int32)
    WEAPONS.local_each_key
  end
end
