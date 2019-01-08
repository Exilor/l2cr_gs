require "./models/temp_item"

module RecipeController
  extend self
  include Packets::Outgoing
  extend Loggable

  private ACTIVE_MAKERS = {} of Int32 => RecipeItemMaker

  def request_book_open(pc : L2PcInstance, dwarven : Bool)
    if ACTIVE_MAKERS.has_key?(pc.l2id)
      pc.send_packet(SystemMessageId::CANT_ALTER_RECIPEBOOK_WHILE_CRAFTING)
      return
    end

    response = RecipeBookItemList.new(dwarven, pc.max_mp)
    if dwarven
      response.add_recipes(pc.dwarven_recipe_book)
    else
      response.add_recipes(pc.common_recipe_book)
    end

    pc.send_packet(response)
  end

  def request_make_item_abort(pc : L2PcInstance)
    ACTIVE_MAKERS.delete(pc.l2id)
  end

  def request_manufacture_item(manufacturer : L2PcInstance, recipe_list_id : Int32, pc : L2PcInstance)
    recipe_list = RecipeData.get_valid_recipe_list(pc, recipe_list_id)
    return unless recipe_list
    dwarf_recipes = manufacturer.dwarven_recipe_book
    common_recipes = manufacturer.common_recipe_book
    if !dwarf_recipes.includes?(recipe_list) && !common_recipes.includes?(recipe_list)
      Util.punish(pc, "sent an invalid recipe id.")
      warn "#{pc.name} sent a false recipe ID."
      return
    end

    if Config.alt_game_creation && ACTIVE_MAKERS.has_key?(manufacturer.l2id)
      pc.send_packet(SystemMessageId::CLOSE_STORE_WINDOW_AND_TRY_AGAIN)
      return
    end

    maker = RecipeItemMaker.new(manufacturer, recipe_list, pc)
    if maker.valid?
      if Config.alt_game_creation
        ACTIVE_MAKERS[manufacturer.l2id] = maker
        ThreadPoolManager.schedule_general(maker, 100)
      else
        maker.run
      end
    end
  end

  def request_make_item(pc : L2PcInstance, recipe_list_id : Int32)
    if pc.in_combat? || pc.in_duel?
      pc.send_packet(SystemMessageId::CANT_OPERATE_PRIVATE_STORE_DURING_COMBAT)
      return
    end

    recipe_list = RecipeData.get_valid_recipe_list(pc, recipe_list_id)
    return unless recipe_list

    dwarf_recipes = pc.dwarven_recipe_book
    common_recipes = pc.common_recipe_book
    if !dwarf_recipes.includes?(recipe_list) && !common_recipes.includes?(recipe_list)
      Util.punish(pc, "sent an invalid recipe id.")
      warn "#{pc.name} sent a false recipe ID."
      return
    end

    if Config.alt_game_creation && ACTIVE_MAKERS.has_key?(pc.l2id)
      sm = SystemMessage.s2_s1
      sm.add_item_name(recipe_list.item_id)
      sm.add_string("You are busy creating.")
      pc.send_packet(sm)
      return
    end

    maker = RecipeItemMaker.new(pc, recipe_list, pc)
    if maker.valid?
      if Config.alt_game_creation
        ACTIVE_MAKERS[pc.l2id] = maker
        ThreadPoolManager.schedule_general(maker, 100)
      else
        maker.run
      end
    end
  end

  private class RecipeItemMaker
    include Runnable
    include Loggable
    include Packets::Outgoing

    @creation_passes = 1
    @exp = -1
    @sp = -1
    @item_grab = 0
    @total_items = 0
    @delay = 0
    @skill_level : Int32
    @skill_id : Int32
    @skill : Skill
    @price : Int64 = 0i64
    getter? valid = false
    private getter! items : Array(TempItem)

    def initialize(@pc : L2PcInstance, @recipe_list : L2RecipeList, @target : L2PcInstance)
      if @recipe_list.dwarven_recipe?
        @skill_id = CommonSkill::CREATE_DWARVEN.id
      else
        @skill_id = CommonSkill::CREATE_COMMON.id
      end

      @skill_level = @pc.get_skill_level(@skill_id)
      @skill = @pc.get_known_skill(@skill_id).not_nil!

      @pc.in_craft_mode = true

      if @pc.looks_dead?
        @pc.action_failed
        abort
        return
      end

      if @target.looks_dead?
        @target.action_failed
        abort
        return
      end

      if @target.processing_transaction?
        @target.action_failed
        abort
        return
      end

      if @pc.processing_transaction?
        @pc.action_failed
        abort
        return
      end

      if @recipe_list.recipes.empty?
        @pc.action_failed
        abort
        return
      end

      if @recipe_list.level > @skill_level
        @pc.action_failed
        abort
        return
      end

      if @pc != @target
        if item = @pc.manufacture_items[@recipe_list.id]
          @price = item.cost
          if @target.adena < @price
            @target.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
            abort
            return
          end
        end
      end

      unless @items = list_items(false)
        abort
        return
      end

      items.each do |it|
        @total_items += it.quantity
      end

      unless calculate_stat_use(false, false)
        abort
        return
      end

      if Config.alt_game_creation
        calculate_alt_stat_change
      end

      update_make_info(true)
      update_current_mp
      update_current_load

      @pc.in_craft_mode = false
      @valid = true
    end

    def run
      unless Config.is_crafting_enabled
        @target.send_message("Item creation is currently disabled.")
        abort
        return
      end

      # unless @pc && @target
      #   warn "Player or target are nil."
      #   abort
      #   return
      # end

      unless @pc.online? && @target.online?
        warn "Player or target not online."
        abort
        return
      end

      if Config.alt_game_creation && !ACTIVE_MAKERS.has_key?(@pc.l2id)
        if @target != @pc
          @target.send_message("Manufacture aborted")
          @pc.send_message("Manufacure aborted")
        else
          @pc.send_message("Item creation aborted")
        end
        abort
        return
      end

      if Config.alt_game_creation && !items.empty?
        unless calculate_stat_use(true, true)
          return
        end

        update_current_mp
        grab_some_items

        if !items.empty?
          @delay = (Config.alt_game_creation_speed * @pc.get_m_reuse_rate(@skill) * GameTimer::TICKS_PER_SECOND * GameTimer::MILLIS_IN_TICK).to_i
          msu = MagicSkillUse.new(@pc, @skill_id, @skill_level, @delay, 0)
          @pc.broadcast_packet(msu)
          @pc.send_packet(SetupGauge.new(0, @delay))
          ThreadPoolManager.schedule_general(self, 100 + @delay)
        else
          @pc.send_packet(SetupGauge.new(0, @delay))
          begin
            sleep(@delay / 1000)
          rescue e
            error e
          ensure
            finish_crafting
          end
        end
      else
        finish_crafting
      end
    end

    def finish_crafting
      unless Config.alt_game_creation
        calculate_stat_use(false, true)
      end

      if @target != @pc && @price > 0
        adena_transfer = @target.transfer_item("PayManufacture", @target.inventory.adena_instance.l2id, @price, @pc.inventory, @pc)
        unless adena_transfer
          @target.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
          abort
          return
        end
      end

      @items = list_items(true)

      if @items.nil?
        # not done in L2J
        warn "@items is nil"
      elsif Rnd.rand(100) < @recipe_list.success_rate
        reward_player
        update_make_info(true)
      else
        if @target != @pc
          sm = SystemMessage.creation_of_s2_for_c1_at_s3_adena_failed
          sm.add_string(@target.name)
          sm.add_item_name(@recipe_list.item_id)
          sm.add_long(@price)
          @pc.send_packet(sm)

          sm = SystemMessage.c1_failed_to_create_s2_for_s3_adena
          sm.add_string(@pc.name)
          sm.add_item_name(@recipe_list.item_id)
          sm.add_long(@price)
          @target.send_packet(sm)
        else
          @target.send_packet(SystemMessageId::ITEM_MIXING_FAILED)
        end

        update_make_info(false)
      end

      update_current_mp
      update_current_load
      ACTIVE_MAKERS.delete(@pc.l2id)
      @pc.in_craft_mode = false
      @target.send_packet(ItemList.new(@target, false))
    end

    private def update_make_info(success)
      if @target == @pc
        @target.send_packet(RecipeItemMakeInfo.new(@recipe_list.id, @target, success))
      else
        @target.send_packet(RecipeShopItemInfo.new(@pc, @recipe_list.id))
      end
    end

    private def update_current_load
      @target.send_packet(StatusUpdate.current_load(@target))
    end

    private def update_current_mp
      @target.send_packet(StatusUpdate.current_mp(@target))
    end

    private def grab_some_items
      grab_items = @item_grab
      while grab_items > 0 && !items.empty?
        item = items.first
        count = item.quantity
        if count > grab_items
          count = grab_items
        end

        item.quantity = item.quantity - count

        if item.quantity <= 0
          items.shift
        else
          items[0] = item
        end

        grab_items -= count

        if @target == @pc
          sm = SystemMessage.s1_s2_equipped
          sm.add_long(count)
          sm.add_item_name(item.item_id)
          @pc.send_packet(sm)
        else
          @target.send_message("Manufacturer #{@pc.name} used #{count} #{item.item_name}")
        end
      end
    end

    private def calculate_alt_stat_change
      @item_grab = @skill_level

      @recipe_list.alt_stat_change.each do |asc|
        if asc.type.xp?
          @exp = asc.value
        elsif asc.type.sp?
          @sp = asc.value
        elsif asc.type.gim?
          @item_grab *= asc.value
        end
      end
      @creation_passes = (@total_items / @item_grab)
      if @total_items % @item_grab != 0
        @creation_passes += 1
      end
      if @creation_passes < 1
        @creation_passes = 1
      end
    end

    private def calculate_stat_use(is_wait, is_reduce)
      ret = true
      @recipe_list.stat_use.each do |su|
        mod_val = su.value.fdiv(@creation_passes)
        if su.type.hp?
          if @pc.current_hp <= mod_val
            if Config.alt_game_creation && is_wait
              @pc.send_packet(SetupGauge.new(0, @delay))
              ThreadPoolManager.schedule_general(self, 100 + @delay)
            else
              @target.send_packet(SystemMessageId::NOT_ENOUGH_HP)
              abort
            end
            ret = false
          elsif is_reduce
            @pc.reduce_current_hp(mod_val, @pc, @skill)
          end
        elsif su.type.mp?
          if @pc.current_mp < mod_val
            if Config.alt_game_creation && is_wait
              @pc.send_packet(SetupGauge.new(0, @delay))
              ThreadPoolManager.schedule_general(self, 100 + @delay)
            else
              @target.send_packet(SystemMessageId::NOT_ENOUGH_MP)
              abort
            end
            ret = false
          elsif is_reduce
            @pc.reduce_current_mp(mod_val)
          end
        else
          @target.send_message("Recipe error.")
          ret = false
          abort
        end
      end

      ret
    end

    private def list_items(remove)
      recipes = @recipe_list.recipes
      inv = @target.inventory
      materials = [] of TempItem
      recipes.each do |recipe|
        if recipe.quantity > 0
          item = inv.get_item_by_item_id(recipe.item_id)
          item_quantity_amount = item.try &.count || 0
          if item_quantity_amount < recipe.quantity
            sm = SystemMessage.missing_s2_s1_to_create
            sm.add_item_name(recipe.item_id)
            sm.add_long(recipe.quantity - item_quantity_amount)
            @target.send_packet(sm)
            abort
            return
          end
          materials << TempItem.new(item.not_nil!, recipe.quantity)
        end
      end

      if remove
        materials.each do |tmp|
          inv.destroy_item_by_item_id("Manufacture", tmp.item_id, tmp.quantity.to_i64, @target, @pc)
          if tmp.quantity > 1
            sm = SystemMessage.s2_s1_disappeared
            sm.add_item_name(tmp.item_id)
            sm.add_long(tmp.quantity)
            @target.send_packet(sm)
          else
            sm = SystemMessage.s1_disappeared
            sm.add_item_name(tmp.item_id)
            @target.send_packet(sm)
          end
        end
      end
      materials
    end

    private def abort
      update_make_info(false)
      @pc.in_craft_mode = false
      ACTIVE_MAKERS.delete(@pc.l2id)
    end

    private def reward_player
      rare_prod_id = @recipe_list.rare_item_id
      item_id = @recipe_list.item_id
      item_count = @recipe_list.count
      template = ItemTable[item_id]
      if rare_prod_id != -1 && (rare_prod_id == item_id || Config.craft_masterwork)
        if Rnd.rand(100) < @recipe_list.rarity
          item_id = rare_prod_id
          item_count = @recipe_list.rare_count
        end
      end

      @target.inventory.add_item("Manufacture", item_id, item_count.to_i64, @target, @pc)

      if @target != @pc
        if item_count == 1
          sm = SystemMessage.s2_created_for_c1_for_s3_adena
          sm.add_string(@target.name)
          sm.add_item_name(item_id)
          sm.add_long(@price)
          @pc.send_packet(sm)

          sm = SystemMessage.c1_created_s2_for_s3_adena
          sm.add_string(@pc.name)
          sm.add_item_name(item_id)
          sm.add_long(@price)
          @target.send_packet(sm)
        else
          sm = SystemMessage.s2_s3_s_created_for_c1_for_s4_adena
          sm.add_string(@target.name)
          sm.add_int(item_count)
          sm.add_item_name(item_id)
          sm.add_long(@price)
          @pc.send_packet(sm)

          sm = SystemMessage.c1_created_s2_s3_s_for_s4_adena
          sm.add_string(@pc.name)
          sm.add_int(item_count)
          sm.add_item_name(item_id)
          sm.add_long(@price)
          @target.send_packet(sm)
        end
      end

      if item_count > 1
        sm = SystemMessage.earned_s2_s1_s
        sm.add_item_name(item_id)
        sm.add_long(item_count)
        @target.send_packet(sm)
      else
        sm = SystemMessage.earned_item_s1
        sm.add_item_name(item_id)
        @target.send_packet(sm)
      end

      if Config.alt_game_creation
        recipe_level = @recipe_list.level
        if @exp < 0
          @exp = template.reference_price * item_count
          @exp /= recipe_level
        end
        if @sp < 0
          @sp = @exp / 10
        end
        if item_id == rare_prod_id
          @exp = (@exp * Config.alt_game_creation_rare_xpsp_rate).to_i32
          @sp = (@sp * Config.alt_game_creation_rare_xpsp_rate).to_i32
        end
        if @exp < 0
          @exp = 0
        end
        if @sp < 0
          @sp = 0
        end

        @skill_level.downto(recipe_level - 1) do |i|
          @exp /= 4
          @sp /= 4
        end
        @pc.add_exp_and_sp(
          @pc.calc_stat(
            Stats::EXPSP_RATE,
            @exp * Config.alt_game_creation_xp_rate * Config.alt_game_creation_speed
          ).to_i64,
          @pc.calc_stat(
            Stats::EXPSP_RATE,
            @sp * Config.alt_game_creation_sp_rate * Config.alt_game_creation_speed
          ).to_i32
        )
      end

      update_make_info(true)
    end
  end
end
