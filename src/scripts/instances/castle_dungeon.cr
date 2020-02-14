class Scripts::CastleDungeon < AbstractInstance
  private class CDWorld < InstanceWorld
  end

  # Locations
  private ENTER_LOC = {
    Location.new(12188, -48770, -3008),
    Location.new(12218, -48770, -3008),
    Location.new(12248, -48770, -3008),
  }

  private RAIDS_LOC = Location.new(11793, -49190, -3008, 0)
  # Misc
  private CASTLE_DUNGEON = {
    36403 => 13, # Gludio
    36404 => 14, # Dion
    36405 => 15, # Giran
    36406 => 16, # Oren
    36407 => 17, # Aden
    36408 => 18, # Innadril
    36409 => 19, # Goddard
    36410 => 20, # Rune
    36411 => 21  # Schuttgart
  }
  private FORTRESS = {
    1 => {101, 102, 112, 113},      # Gludio Castle
    2 => {103, 112, 114, 115},      # Dion Castle
    3 => {104, 114, 116, 118, 119}, # Giran Castle
    4 => {105, 113, 115, 116, 117}, # Oren Castle
    5 => {106, 107, 117, 118},      # Aden Castle
    6 => {108, 119},                # Innadril Castle
    7 => {109, 117, 120},           # Goddard Castle
    8 => {110, 120, 121},           # Rune Castle
    9 => {111, 121}                 # Schuttgart Castle
  }

  # Raid Bosses
  private RAIDS1 = {
    25546, # Rhianna the Traitor
    25549, # Tesla the Deceiver
    25552  # Soul Hunter Chakundel
  }
  private RAIDS2 = {
    25553, # Durango the Crusher
    25554, # Brutus the Obstinate
    25557, # Ranger Karankawa
    25560  # Sargon the Mad
  }
  private RAIDS3 = {
    25563, # Beautiful Atrielle
    25566, # Nagen the Tomboy
    25569  # Jax the Destroyer
  }

  def initialize
    super(self.class.simple_name)

    add_first_talk_id(CASTLE_DUNGEON.keys)
    add_start_npc(CASTLE_DUNGEON.keys)
    add_talk_id(CASTLE_DUNGEON.keys)
    add_kill_id(*RAIDS1, *RAIDS2, *RAIDS3)
    # add_kill_id(RAIDS2)
    # add_kill_id(RAIDS3)
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      if party = pc.party
        party.members.each do |m|
          teleport_player(m, ENTER_LOC.sample(random: Rnd), world.instance_id)
          world.add_allowed(m.l2id)
        end
      else
        teleport_player(pc, ENTER_LOC.sample(random: Rnd), world.instance_id)
        world.add_allowed(pc.l2id)
      end

      world.status = 0
      spawn_raid(world)
    else
      teleport_player(pc, ENTER_LOC.sample(random: Rnd), world.instance_id)
    end
  end

  def on_first_talk(npc, pc)
    "36403.html"
  end

  def on_kill(npc, player, is_summon)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(CDWorld)
      if RAIDS3.includes?(npc.id)
        finish_instance(world)
      else
        world.inc_status
        spawn_raid(world)
      end
    end

    nil
  end

  def on_talk(npc, pc)
    unless party = pc.party
      return "36403-01.html"
    end

    castle = npc.castle
    if castle.siege.in_progress?
      return "36403-04.html"
    end

    clan = pc.clan

    if npc.my_lord?(pc) || (clan && npc.castle.residence_id == clan.castle_id && clan.castle_id > 0)
      num_fort = (castle.residence_id == 1 || castle.residence_id == 5) ? 2 : 1
      fort = FORTRESS[castle.residence_id]
      num_fort.times do |i|
        fortress = FortManager.get_fort_by_id(fort[i]).not_nil!
        if fortress.fort_state == 0
          return "36403-05.html"
        end
      end
    end

    party.members.each do |m|
      mclan = m.clan
      if mclan.nil? || mclan.castle_id != castle.residence_id
        return "36403-02.html"
      end

      if Time.ms < InstanceManager.get_instance_time(m.l2id, CASTLE_DUNGEON[npc.id])
        return "36403-03.html"
      end
    end

    enter_instance(pc, CDWorld.new, "CastleDungeon.xml", CASTLE_DUNGEON[npc.id])

    super
  end

  private def spawn_raid(world)
    if world.status == 0
      spawn_id = RAIDS1.sample(random: Rnd)
    elsif world.status == 1
      spawn_id = RAIDS2.sample(random: Rnd)
    else
      spawn_id = RAIDS3.sample(random: Rnd)
    end

    add_spawn(spawn_id, RAIDS_LOC, false, 0, false, world.instance_id)
  end
end
