class Scripts::IsleOfPrayer < AbstractNpcAI
  private YELLOW_SEED_OF_EVIL_SHARD = 9593
  private GREEN_SEED_OF_EVIL_SHARD  = 9594
  private BLUE_SEED_OF_EVIL_SHARD   = 9595
  private RED_SEED_OF_EVIL_SHARD    = 9596

  private MONSTERS = {
    22257 => ItemChanceHolder.new(YELLOW_SEED_OF_EVIL_SHARD, 2087), # Island Guardian
    22258 => ItemChanceHolder.new(YELLOW_SEED_OF_EVIL_SHARD, 2147), # White Sand Mirage
    22259 => ItemChanceHolder.new(YELLOW_SEED_OF_EVIL_SHARD, 2642), # Muddy Coral
    22260 => ItemChanceHolder.new(YELLOW_SEED_OF_EVIL_SHARD, 2292), # Kleopora
    22261 => ItemChanceHolder.new(GREEN_SEED_OF_EVIL_SHARD,  1171), # Seychelles
    22262 => ItemChanceHolder.new(GREEN_SEED_OF_EVIL_SHARD,  1173), # Naiad
    22263 => ItemChanceHolder.new(GREEN_SEED_OF_EVIL_SHARD,  1403), # Sonneratia
    22264 => ItemChanceHolder.new(GREEN_SEED_OF_EVIL_SHARD,  1207), # Castalia
    22265 => ItemChanceHolder.new(RED_SEED_OF_EVIL_SHARD,     575), # Chrysocolla
    22266 => ItemChanceHolder.new(RED_SEED_OF_EVIL_SHARD,     493), # Pythia
    22267 => ItemChanceHolder.new(RED_SEED_OF_EVIL_SHARD,     770), # Dark Water Dragon
    22268 => ItemChanceHolder.new(BLUE_SEED_OF_EVIL_SHARD,    987), # Shade
    22269 => ItemChanceHolder.new(BLUE_SEED_OF_EVIL_SHARD,    995), # Shade
    22270 => ItemChanceHolder.new(BLUE_SEED_OF_EVIL_SHARD,   1008), # Water Dragon Detractor
    22271 => ItemChanceHolder.new(BLUE_SEED_OF_EVIL_SHARD,   1008)  # Water Dragon Detractor
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_kill_id(MONSTERS.keys)
  end

  def on_kill(npc, killer, is_summon)
    holder = MONSTERS[npc.id]

    if Rnd.rand(10_000) <= holder.chance
      npc.drop_item(killer, holder)
    end

    super
  end
end
