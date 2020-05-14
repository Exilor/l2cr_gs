require "../l2_tower"

class L2ControlTowerInstance < L2Tower
  @guards : Interfaces::Array(L2Spawn)?

  def instance_type : InstanceType
    InstanceType::L2ControlTowerInstance
  end

  def do_die(killer : L2Character?) : Bool
    if castle.siege.in_progress?
      castle.siege.killed_ct(self)
      if @guards && !guards.empty?
        guards.each do |sp|
          begin
            sp.stop_respawn
          rescue e
            error e
          end
        end
        guards.clear
      end
    end

    super
  end

  def register_guard(guard : L2Spawn)
    guards << guard
  end

  private def guards : Interfaces::Array(L2Spawn)
    @guards || sync { @guards ||= Concurrent::Array(L2Spawn).new }
  end
end
