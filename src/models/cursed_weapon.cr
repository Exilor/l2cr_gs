class CursedWeapon
  include Loggable
  include Packets::Outgoing

  @remove_task : TaskExecutor::Scheduler::PeriodicTask?
  @transformation_id = 0

  property disappear_chance : Int32 = 0
  property drop_rate : Int32 = 0
  property duration : Int32 = 0
  property duration_lost : Int32 = 0
  property nb_kills : Int32 = 0
  property stage_kills : Int32 = 0
  property player_id : Int32 = 0
  property player_karma : Int32 = 0
  property player_pk_kills : Int32 = 0
  property end_time : Int64 = 0i64
  property name : String
  property skill_id : Int32
  property item_id : Int32
  property! item : L2ItemInstance?
  property! player : L2PcInstance?
  property? activated : Bool = false
  property? dropped : Bool = false

  def initialize(item_id : Int32, skill_id : Int32, name : String)
    @item_id = item_id
    @skill_id = skill_id
    @name = name
    @skill_max_level = SkillData.get_max_level(skill_id)
  end

  def end_of_life
    if @activated
      if player? && player.online?
        info { "#{@name} being removed online." }

        player.abort_attack

        player.karma = @player_karma
        player.pk_kills = @player_pk_kills
        player.cursed_weapon_equipped_id = 0

        remove_skill

        player.inventory.unequip_item_in_body_slot(L2Item::SLOT_LR_HAND)
        player.store_me

        removed_item = player.inventory.destroy_item_by_item_id("", @item_id, 1, player, nil).not_nil!

        if !Config.force_inventory_update
          if removed_item.count == 0
            iu = InventoryUpdate.removed(removed_item)
          else
            iu = InventoryUpdate.modified(removed_item)
          end

          player.send_packet(iu)
        else
          player.send_packet(ItemList.new(player, true))
        end

        player.broadcast_user_info
      else
        info { "#{@name} being removed offline." }

        begin
          del = "DELETE FROM items WHERE owner_id=? AND item_id=?"
          GameDB.exec(del, @player_id, @item_id)
        rescue e
          error e
        end

        begin
          sql = "UPDATE characters SET karma=?, pkkills=? WHERE charId=?"
          GameDB.exec(sql, @player_karma, @player_pk_kills, @player_id)
        rescue e
          error e
        end
      end
    else
      if player? && player.inventory.get_item_by_item_id(@item_id)
        removed_item = player.inventory.destroy_item_by_item_id("", @item_id, 1, player, nil).not_nil!
        if !Config.force_inventory_update
          if removed_item.count == 0
            iu = InventoryUpdate.removed(removed_item)
          else
            iu = InventoryUpdate.modified(removed_item)
          end

          player.send_packet(iu)
        else
          player.send_packet(ItemList.new(player, true))
        end

        player.broadcast_user_info
      elsif @item
        item.decay_me
        L2World.remove_object(item)
        info { "#{@name} item has been removed from L2World." }
      end
    end

    CursedWeaponsManager.remove_from_db(@item_id)

    sm = SystemMessage.s1_has_disappeared
    sm.add_item_name(@item_id)
    CursedWeaponsManager.announce(sm)

    cancel_task

    @activated = false
    @dropped = false
    @end_time = 0i64
    @player = nil
    @player_id = 0
    @player_karma = 0
    @player_pk_kills = 0
    @item = nil
    @nb_kills = 0
  end

  private def cancel_task
    if task = @remove_task
      task.cancel
      @remove_task = nil
    end
  end

  private def drop_it(attackable : L2Attackable?, pc : L2PcInstance?)
    drop_it(attackable, pc, nil, true)
  end

  private def drop_it(attackable : L2Attackable?, pc : L2PcInstance?, killer : L2Character?, from_monster : Bool)
    @activated = true

    if from_monster
      unless pc
        raise "pc must not be nil here"
      end
      @item = attackable.drop_item(pc, @item_id, 1)
      item.drop_time = 0

      p1 = ExRedSky.new(10)
      p2 = Earthquake.new(*pc.xyz, 14, 3)
      Broadcast.to_all_online_players(p1)
      Broadcast.to_all_online_players(p2)
    else
      @item = player.inventory.get_item_by_item_id(@item_id)
      player.drop_item("DieDrop", item, killer, true)
      player.karma = @player_karma
      player.pk_kills = @player_pk_kills
      player.cursed_weapon_equipped_id = 0
      remove_skill
      player.abort_attack
    end

    @dropped = true

    sm = SystemMessage.s2_was_dropped_in_the_s1_region
    if pc
      sm.add_zone_name(*pc.xyz)
    elsif @player
      sm.add_zone_name(*player.xyz)
    else
      unless killer
        raise "killer must not be nil here"
      end
      sm.add_zone_name(*killer.xyz)
    end

    sm.add_item_name(@item_id)
    CursedWeaponsManager.announce(sm)
  end

  def drop_it(killer : L2Character)
    if Rnd.rand(100) <= @disappear_chance
      end_of_life
    else
      drop_it(nil, nil, killer, false)
      player.karma = @player_karma
      player.pk_kills = @player_pk_kills
      player.cursed_weapon_equipped_id = 0
      remove_skill
      player.abort_attack
      player.broadcast_user_info
    end
  end

  def cursed_on_login
    do_transform
    give_skill

    sm = SystemMessage.s2_owner_has_logged_into_the_s1_region
    sm.add_zone_name(*player.xyz)
    sm.add_item_name(player.cursed_weapon_equipped_id)
    CursedWeaponsManager.announce(sm)

    cw = CursedWeaponsManager.get_cursed_weapon(player.cursed_weapon_equipped_id).not_nil!
    sm = SystemMessage.s2_minute_of_usage_time_are_left_for_s1
    time_left = cw.time_left / 60_000
    sm.add_item_name(player.cursed_weapon_equipped_id)
    sm.add_int(time_left.to_i)
    player.send_packet(sm)
  end

  def give_skill
    if @stage_kills == 0
      level = 1
    else
      level = 1 + (@nb_kills // @stage_kills)
    end

    if level > @skill_max_level
      level = @skill_max_level
    end

    skill = SkillData[@skill_id, level]
    player.add_skill(skill, false)

    player.add_skill(CommonSkill::VOID_BURST.skill, false)
    player.add_transform_skill(CommonSkill::VOID_BURST.skill)
    player.add_skill(CommonSkill::VOID_FLOW.skill, false)
    player.add_transform_skill(CommonSkill::VOID_FLOW.skill)
    player.send_skill_list
  end

  def do_transform
    if @item_id == 8689
      @transformation_id = 302
    elsif @item_id == 8190
      @transformation_id = 301
    end
    debug "transforming to ID #{@transformation_id}."
    if player.transformed? || player.in_stance?
      player.stop_transformation(true)
      task = -> do
        TransformData.transform_player(@transformation_id, player)
      end
      ThreadPoolManager.schedule_general(task, 500)
    else
      TransformData.transform_player(@transformation_id, player)
    end
  end

  def remove_skill
    player.remove_skill(@skill_id)
    player.remove_skill(CommonSkill::VOID_BURST.skill.id)
    player.remove_skill(CommonSkill::VOID_FLOW.skill.id)
    player.untransform
    player.send_skill_list
  end

  def reactivate
    @activated = true

    if @end_time - Time.ms <= 0
      end_of_life
    else
      @remove_task = start_remove_task(@duration_lost * 12000, @duration_lost * 12000)
    end
  end

  def check_drop(attackable : L2Attackable, pc : L2PcInstance) : Bool
    if Rnd.rand(100_000) < @drop_rate
      drop_it(attackable, pc)
      @end_time = Time.ms + (@duration * 60_000)
      @remove_task = start_remove_task(@duration_lost * 12_000, @duration_lost * 12_000)
      info { "#{@name} has dropped from #{attackable} killed by #{pc.name}." }
      return true
    end

    false
  end

  def activate(pc : L2PcInstance, item : L2ItemInstance)
    if pc.mounted? && !pc.dismount
      sm = SystemMessage.failed_to_pickup_s1
      sm.add_item_name(item)
      pc.send_packet(sm)
      pc.drop_item("InvDrop", item, nil, true)
      return
    end

    @activated = true

    @player = pc
    @player_id = pc.l2id
    @player_karma = pc.karma
    @player_pk_kills = pc.pk_kills

    save_data

    player.cursed_weapon_equipped_id = @item_id
    player.karma = 9_999_999
    player.pk_kills = 0

    if party = player.party
      party.remove_party_member(player, L2Party::MessageType::Expelled)
    end

    do_transform
    give_skill

    @item = item

    player.inventory.equip_item(item)

    sm = SystemMessage.s1_equipped
    sm.add_item_name(item)
    player.send_packet(sm)

    player.heal!

    if !Config.force_inventory_update
      player.send_packet(InventoryUpdate.single(item))
    else
      player.send_packet(ItemList.new(player, false))
    end

    player.broadcast_user_info

    atk = SocialAction.new(player.l2id, 17)
    player.broadcast_packet(atk)

    sm = SystemMessage.the_owner_of_s2_has_appeared_in_the_s1_region
    sm.add_zone_name(*player.xyz)
    sm.add_item_name(item)
    CursedWeaponsManager.announce(sm)
  end

  def save_data
    debug "Saving data."

    begin
      del = "DELETE FROM cursed_weapons WHERE itemId = ?"
      GameDB.exec(del, @item_id)
    rescue e
      error e
    end

    if @activated
      begin
        sql = "INSERT INTO cursed_weapons (itemId, charId, playerKarma, playerPkKills, nbKills, endTime) VALUES (?, ?, ?, ?, ?, ?)"
        GameDB.exec(
          sql,
          @item_id,
          @player_id,
          @player_karma,
          @player_pk_kills,
          @nb_kills,
          @end_time
        )
      rescue e
        error e
      end
    end
  end

  def increase_kills
    @nb_kills += 1

    if @player && player.online?
      player.pk_kills = @nb_kills
      player.send_packet(UserInfo.new(player))
      if @nb_kills % @stage_kills == 0
        if @nb_kills <= @stage_kills * (@skill_max_level &- 1)
          give_skill
        end
      end
    end

    @end_time -= @duration_lost * 60_000

    save_data
  end

  def active? : Bool
    @activated || @dropped
  end

  def level : Int32
    if @nb_kills > (@stage_kills * @skill_max_level)
      return @skill_max_level
    end

    if @stage_kills == 0
      return 0
    end

    @nb_kills // @stage_kills
  end

  def time_left : Int64
    @end_time - Time.ms
  end

  def go_to(pc : L2PcInstance)
    if @activated && @player
      pc.tele_to_location(player.location, true)
    elsif @dropped && @item
      pc.tele_to_location(item.location, true)
    else
      pc.send_message("#{@name} not found in the world.")
    end
  end

  def world_position : Location?
    if @activated && @player
      player.location
    elsif @dropped && @item
      item.location
    end
  end

  private def start_remove_task(delay, interval)
    task = -> do
      if Time.ms >= end_time
        end_of_life
      end
    end

    ThreadPoolManager.schedule_general_at_fixed_rate(task, delay, interval)
  end

  def to_log(io : IO)
    io << "CursedWeapon(" << @name << ')'
  end
end
