module MerchantPriceConfigTable
  extend self
  # extend InstanceListManager
  extend XMLReader

  private MPCS_FILE = "MerchantPriceConfig.xml"
  private MPCS = {} of Int32 => MerchantPriceConfig

  class_getter! default_mpc : MerchantPriceConfig

  def load
    parse_datapack_file(MPCS_FILE)
  end

  def get_merchant_price_config(id : Int32) : MerchantPriceConfig?
    MPCS[id]?
  end

  def get_merchant_price_config!(id : Int32) : MerchantPriceConfig
    MPCS.fetch(id) { raise "No merchant price config with id #{id}" }
  end

  def get_merchant_price_config(npc : L2MerchantInstance) : MerchantPriceConfig
    MPCS.each_value do |mpc|
      if npc.world_region? && npc.world_region.contains_zone?(mpc.zone_id)
        return mpc
      end
    end

    default_mpc
  end

  private def parse_document(doc, file)
    doc.find_element("merchantPriceConfig") do |n|
      default_id = n["defaultPriceConfig"].to_i
      n.each_element do |d|
        if mpc = parse_merchant_price_config(d)
          MPCS[mpc.id] = mpc
        end
      end

      @@default_mpc = get_merchant_price_config(default_id)
    end
  end

  def load_instances
    load
    info { "Loaded #{MPCS.size} merchant price configurations." }
  rescue e
    error e
  end

  def activate_instances
    # no-op
  end

  def update_references
    MPCS.each_value &.update_references
  end

  def parse_merchant_price_config(n)
    unless id = n["id"]?
      raise "priceConfig must define 'id'"
    end
    id = id.to_i

    unless name = n["name"]?
      raise "priceConfig must define 'name'"
    end

    unless base_tax = n["baseTax"]?
      raise "priceConfig must define 'baseTax'"
    end
    base_tax = base_tax.to_i

    if castle_id = n["castleId"]?
      castle_id = castle_id.to_i
    else
      castle_id = -1
    end

    if zone_id = n["zoneId"]?
      zone_id = zone_id.to_i
    else
      zone_id = -1
    end

    MerchantPriceConfig.new(id, name, base_tax, castle_id, zone_id)
  end

  class MerchantPriceConfig
    getter! castle : Castle

    getter_initializer id : Int32, name : String, base_tax : Int32,
      castle_id : Int32, zone_id : Int32

    def base_tax_rate
      @base_tax.fdiv(100)
    end

    def has_castle? : Bool
      !!@castle
    end

    def castle_tax_rate : Float64
      has_castle? ? castle.tax_rate : 0.0
    end

    def total_tax : Int32
      has_castle? ? castle.tax_percent + base_tax : base_tax
    end

    def total_tax_rate : Float64
      total_tax / 100.0
    end

    def update_references
      if @castle_id > 0
        @castle = CastleManager.get_castle_by_id!(@castle_id)
      end
    end
  end
end
