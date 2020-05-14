require "./l2_spawn"

class L2GroupSpawn < L2Spawn
  include Loggable

  def initialize(template : L2NpcTemplate)
    super
    self.amount = 1
  end

  def do_group_spawn : L2Npc?
    if @template.type?("L2Pet") || @template.type?("L2Minion")
      return
    end

    new_loc_x = new_loc_y = new_loc_z = 0
    if x == 0 && y == 0
      if location_id == 0
        return
      end

      if loc = TerritoryTable.get_random_point(location_id)
        new_loc_x = loc.x
        new_loc_y = loc.y
        new_loc_z = loc.z
      end
    else
      new_loc_x, new_loc_y, new_loc_z = x, y, z
    end

    mob = L2ControllableMobInstance.new(@template)
    mob.heal!

    if heading == -1
      mob.heading = Rnd.rand(61794)
    else
      mob.heading = heading
    end

    mob.spawn = self
    mob.spawn_me(new_loc_x, new_loc_y, new_loc_z)
    mob.on_spawn

    debug { "Spawned mob id #{@template.id} at #{mob.xyz}." }

    mob
  rescue e
    error e
    nil
  end
end
