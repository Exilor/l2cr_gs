module MerchantPriceConfigTable
  extend self
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

  def get_merchant_price_config(npc : L2MerchantInstance) : MerchantPriceConfig
    ret = MPCS.find_value do |mpc|
      (reg = npc.world_region) && reg.contains_zone?(mpc.zone_id)
    end

    ret || default_mpc
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "merchantPriceConfig") do |n|
      default_id = parse_int(n, "defaultPriceConfig")
      each_element(n) do |d|
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

  private def parse_merchant_price_config(n)
    id = parse_int(n, "id")
    name = parse_string(n, "name")
    base_tax = parse_int(n, "baseTax")
    castle_id = parse_int(n, "castleId", -1)
    zone_id = parse_int(n, "zoneId", -1)

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
      total_tax / 100
    end

    def update_references
      if @castle_id > 0
        @castle = CastleManager.get_castle_by_id(@castle_id).not_nil!
      end
    end
  end
end
