require "../../models/multisell/entry"
require "../../models/multisell/ingredient"
require "../../models/multisell/list_container"
require "../../models/multisell/prepared_list_container"

module MultisellData
  extend self
  extend XMLReader
  include Packets::Outgoing
  include Multisell

  private ENTRIES = {} of Int32 => ListContainer

  PAGE_SIZE = 40
  PC_BANG_POINTS = -100
  CLAN_REPUTATION = -200
  FAME = -300

  def load
    ENTRIES.clear
    timer = Timer.new
    parse_datapack_directory("multisell")

    info { "Loaded #{ENTRIES.size} multisell lists in #{timer} s." }
  end

  private def parse_document(doc, file)
    id = File.basename(file.path, ".xml").to_i

    entry_id = 1
    list = ListContainer.new(id)

    find_element(doc, "list") do |n|
      list.apply_taxes = parse_bool(n, "applyTaxes", false)

      if use_rate = parse_double(n, "useRate", nil)
        list.use_rate = use_rate
      end

      list.maintain_enchantment = parse_bool(n, "maintainEnchantment", false)

      each_element(n) do |d, d_name|
        if d_name.casecmp?("item")
          entry = parse_entry(d, entry_id, list)
          entry_id &+= 1
          list.entries << entry
        elsif d_name.casecmp?("npcs")
          find_element(d, "npc") do |b|
            if b.text.number?
              npc_id = get_content(b).to_i
              if npc_id > 0
                list.allow_npc(npc_id)
              end
            end
          end
        end
      end

      ENTRIES[id] = list
    end
  end

  private def parse_entry(n, entry_id, list)
    entry = Entry.new(entry_id)

    first = get_first_element_child(n)
    n = first

    while n
      case get_node_name(n).casecmp
      when "ingredient"
        set = get_attributes(n)
        entry.add_ingredient(Ingredient.new(set))
      when "production"
        set = get_attributes(n)
        entry.add_product(Ingredient.new(set))
      end

      n = get_next_element(n)
    end

    entry
  end

  def separate_and_send(list_id : Int32, pc : L2PcInstance, npc : L2Npc?, inventory_only : Bool)
    separate_and_send(list_id, pc, npc, inventory_only, 1, 1)
  end

  def separate_and_send(list_id : Int32, pc : L2PcInstance, npc : L2Npc?, inventory_only : Bool, product_multiplier : Float64, ingredient_multiplier : Float64)
    unless template = ENTRIES[list_id]?
      warn { "Cannot find list with id #{list_id} requested by #{pc} from #{npc}." }
      return
    end

    if (npc && !template.npc_allowed?(npc.id)) || (!npc && template.npc_only?)
      warn { "#{pc} tried to open multisell from #{npc} which isn't allowed." }
      return
    end

    list = PreparedListContainer.new(template, inventory_only, pc, npc)

    if product_multiplier != 1 || ingredient_multiplier != 1
      list.entries.each do |entry|
        entry.products.each do |product|
          product.item_count = Math.max(product.item_count * product_multiplier, 1).to_i64
        end

        entry.ingredients.each do |ingredient|
          ingredient.item_count = Math.max(ingredient.item_count * ingredient_multiplier, 1).to_i64
        end
      end
    end

    index = 0

    loop do
      pc.send_packet(MultisellList.new(list, index))
      index &+= PAGE_SIZE
      break unless index < list.entries.size
    end

    pc.multisell = list
  end

  def has_special_ingredient?(id : Int32, amount : Int64, pc : L2PcInstance) : Bool
    case id
    when CLAN_REPUTATION
      clan = pc.clan
      if clan.nil?
        pc.send_packet(SystemMessageId::YOU_ARE_NOT_A_CLAN_MEMBER)
      elsif !pc.clan_leader?
        pc.send_packet(SystemMessageId::YOU_ARE_NOT_A_CLAN_MEMBER)
      elsif clan.reputation_score < amount
        pc.send_packet(SystemMessageId::ONLY_THE_CLAN_LEADER_IS_ENABLED)
      else
        pc.send_packet(SystemMessageId::THE_CLAN_REPUTATION_SCORE_IS_TOO_LOW)
        return true
      end
    when FAME
      if pc.fame < amount
      else
        pc.send_packet(SystemMessageId::NOT_ENOUGH_FAME_POINTS)
        return true
      end
    end

    false
  end

  def take_special_ingredient(id : Int32, amount : Int64, pc : L2PcInstance) : Bool
    case id
    when CLAN_REPUTATION
      pc.clan.not_nil!.take_reputation_score(amount.to_i, true)
      sm = SystemMessage.s1_deducted_from_clan_rep
      sm.add_long(amount)
      pc.send_packet(sm)
      return true
    when FAME
      pc.fame -= amount.to_i
      pc.send_packet(UserInfo.new(pc))
      pc.send_packet(ExBrExtraUserInfo.new(pc))
      return true
    end

    false
  end

  def give_special_product(id : Int32, amount : Int64, pc : L2PcInstance)
    case id
    when CLAN_REPUTATION
      pc.clan.not_nil!.add_reputation_score(amount.to_i, true)
    when FAME
      pc.fame += amount.to_i
      pc.send_packet(UserInfo.new(pc))
      pc.send_packet(ExBrExtraUserInfo.new(pc))
    end
  end

  private def verify
    ENTRIES.each_value do |list|
      list.entries.each do |ent|
        ent.ingredients.each do |ing|
          unless verify_ingredient(ing)
            warn { "Cannot find ingredient with item id: #{ing.item_id} in list #{list.list_id}." }
          end
        end
        ent.products.each do |ing|
          unless verify_ingredient(ing)
            warn { "Cannot find product with item id: #{ing.item_id} in list #{list.list_id}." }
          end
        end
      end
    end
  end

  private def verify_ingredient(ing : Ingredient)
    id = ing.item_id
    id == CLAN_REPUTATION || id == FAME || !!ing.template
  end
end
