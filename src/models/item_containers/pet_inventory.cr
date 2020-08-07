require "./inventory"

class PetInventory < Inventory
  def initialize(owner : L2PetInstance)
    @owner = owner
    super()
  end

  def owner : L2PetInstance
    @owner.not_nil!
  end

  def owner? : L2PetInstance
    @owner
  end

  def owner_id : Int32
    owner.owner.l2id
  end

  def refresh_weight
    super
    owner.update_and_broadcast_status(1)
  end

  def validate_capacity(item : L2ItemInstance) : Bool
    slots = 0
    if !item.stackable? && get_item_by_item_id(item.id)
      unless item.template.has_ex_immediate_effect?
        slots = 1
      end
    end

    validate_capacity(slots)
  end

  def validate_capacity(slots : Int) : Bool
    @items.size + slots <= owner.inventory_limit
  end

  def validate_weight(item : L2ItemInstance, count : Int) : Bool
    weight = 0
    template = ItemTable[item.id]?
    return false unless template
    weight += count * template.weight
    validate_weight(weight)
  end

  def validate_weight(weight : Int) : Bool
    @total_weight + weight <= owner.max_load
  end

  def base_location : ItemLocation
    ItemLocation::PET
  end

  def equip_location : ItemLocation
    ItemLocation::PET_EQUIP
  end

  def restore
    super
    @items.each do |item|
      if item.equipped?
        unless item.template.check_condition(@owner, @owner, false)
          unequip_item_in_slot(item.location_slot)
        end
      end
    end
  end

  def transfer_items_to_owner
    @items.safe_each do |item|
      owner.transfer_item(
        "return",
        item.l2id,
        item.count,
        @owner.owner.inventory,
        @owner.owner,
        @owner
      )
    end
  end
end
