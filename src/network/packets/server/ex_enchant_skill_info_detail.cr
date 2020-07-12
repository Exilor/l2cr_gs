class Packets::Outgoing::ExEnchantSkillInfoDetail < GameServerPacket
  private TYPE_NORMAL_ENCHANT  = 0
  private TYPE_SAFE_ENCHANT    = 1
  private TYPE_UNTRAIN_ENCHANT = 2
  private TYPE_CHANGE_ENCHANT  = 3

  @book_id = 0
  @req_count = 0
  @multi = 1
  @chance : Int32
  @sp : Int32
  @adena_count : Int32

  def initialize(type : Int32, skill_id : Int32, skill_lvl : Int32, pc : L2PcInstance)
    enchant_learn = EnchantSkillGroupsData.get_skill_enchantment_by_skill_id(skill_id)

    if enchant_learn
      if skill_lvl > 100
        esd = enchant_learn.get_enchant_skill_holder(skill_lvl)
      else
        esd = enchant_learn.first_route_group.try &.enchant_group_details.first?
      end
    end

    unless esd
      raise "Skill with id #{skill_id} doesn't have enchant data for level #{skill_lvl}"
    end

    if type == 0
      @multi = Config.normal_enchant_cost_multiplier
    elsif type == 1
      @multi = Config.safe_enchant_cost_multiplier
    end

    @chance = esd.get_rate(pc).to_i32
    @sp = esd.sp_cost
    if type == TYPE_UNTRAIN_ENCHANT
      @sp = (0.8 * @sp).to_i
    end
    @adena_count = esd.adena_cost * @multi
    @type = type
    @skill_id = skill_id
    @skill_lvl = skill_lvl

    case type
    when TYPE_NORMAL_ENCHANT
      @book_id = EnchantSkillGroupsData::NORMAL_ENCHANT_BOOK
      @req_count = (@skill_lvl % 100) > 1 ? 0 : 1
    when TYPE_SAFE_ENCHANT
      @book_id = EnchantSkillGroupsData::SAFE_ENCHANT_BOOK
      @req_count = 1
    when TYPE_UNTRAIN_ENCHANT
      @book_id = EnchantSkillGroupsData::UNTRAIN_ENCHANT_BOOK
      @req_count = 1
    when TYPE_CHANGE_ENCHANT
      @book_id = EnchantSkillGroupsData::CHANGE_ENCHANT_BOOK
      @req_count = 1
    else
      return
    end

    if @type != TYPE_SAFE_ENCHANT && !Config.es_sp_book_needed
      @req_count = 0
    elsif @type == TYPE_SAFE_ENCHANT && !Config.safe_es_sp_book_needed
      @req_count = 0
    end

    # debug "Cost multiplier: #{@multi}."
  end

  private def write_impl
    c 0xfe
    h 0x5e

    d @type
    d @skill_id
    d @skill_lvl
    d @sp * @multi
    d @chance
    d 0x02
    d Inventory::ADENA_ID
    d @adena_count
    d @book_id
    d @req_count
  end
end
