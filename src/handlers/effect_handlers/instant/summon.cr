class EffectHandler::Summon < AbstractEffect
  @npc_id : Int32
  @exp_multiplier : Float32
  @consume_item_interval : Int32
  @life_time : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    if params.empty?
      raise "summon effect without parameters"
    end

    @npc_id = params.get_i32("npcId")
    @exp_multiplier = params.get_f32("expMultiplier", 1)

    item_id = params.get_i32("consumeItemId", 0)
    item_amount = params.get_i64("consumeItemCount", 1)
    @consume_item = ItemHolder.new(item_id, item_amount)

    @consume_item_interval = params.get_i32("consumeItemInterval", 0)
    @life_time = params.get_i32("lifeTime", 3600) * 1000
  end

  def instant?
    true
  end

  def on_start(info)
    return if !info.effected.player? || info.effected.has_summon?

    pc = info.effected.acting_player
    template = NpcData[@npc_id]
    summon = L2ServitorInstance.new(template, pc)
    consume_item_interval =
    if @consume_item_interval > 0
      @consume_item_interval * 1000
    else
      template.race.siege_weapon? ? 60_000 : 240_000
    end

    summon.name = template.name
    summon.title = pc.name
    summon.reference_skill = info.skill.id
    summon.exp_multiplier = @exp_multiplier
    summon.life_time = @life_time
    summon.item_consume = @consume_item
    summon.item_consume_interval = consume_item_interval

    if summon.level > Config.max_pet_level
      exp = ExperienceData.get_exp_for_level(Config.max_pet_level - 1)
      summon.stat.exp = exp
      warn { "#{summon} had a level above its maximum possible level." }
    else
      exp = ExperienceData.get_exp_for_level(summon.level % Config.max_pet_level)
      summon.stat.exp = exp
    end

    summon.heal!
    summon.heading = pc.heading

    pc.pet = summon

    summon.set_running
    summon.spawn_me
  end
end
