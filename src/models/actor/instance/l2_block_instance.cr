require "./l2_monster_instance"

class L2BlockInstance < L2MonsterInstance
  getter color_effect = 0

  def change_color(attacker : L2PcInstance, holder : ArenaParticipantsHolder, team : Int32)
    sync do
      event = holder.event
      if @color_effect == 0x53
        @color_effect = 0
        broadcast_packet(NpcInfo.new(self, attacker))
        increase_team_points_and_send(attacker, team, event)
      else
        @color_effect = 0x53
        broadcast_packet(NpcInfo.new(self, attacker))
        increase_team_points_and_send(attacker, team, event)
      end

      random = Rnd.rand(100)
      if random > 69 && random <= 84
        drop_item(13787, event, attacker)
      elsif random > 84
        drop_item(13788, event, attacker)
      end
    end
  end

  def red=(red : Bool)
    @color_effect = red ? 0x53 : 0
  end

  def auto_attackable?(attacker : L2Character) : Bool
    if attacker.is_a?(L2PcInstance)
      return attacker.block_checker_arena > -1
    end

    true
  end

  def do_die(killer : L2Character?) : Bool
    false
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    unless can_target?(pc)
      return
    end

    pc.last_folk_npc = self

    if pc.target != self
      pc.target = self
      ai
    elsif interact
      pc.action_failed
    end
  end

  private def increase_team_points_and_send(pc : L2PcInstance, team : Int32, eng : BlockCheckerEngine)
    eng.increase_player_points(pc, team)

    time_left = ((eng.started_time - Time.ms) // 1000).to_i
    red = eng.holder.red_players.includes?(pc)

    change_points = ExCubeGameChangePoints.new(time_left, eng.blue_points, eng.red_points)
    secret_points = ExCubeGameExtendedChangePoints.new(time_left, eng.blue_points, eng.red_points, red, pc, eng.get_player_points(pc, red))

    eng.holder.broadcast_packet_to_team(change_points)
    eng.holder.broadcast_packet_to_team(secret_points)
  end

  private def drop_item(id : Int32, eng : BlockCheckerEngine, pc : L2PcInstance)
    drop = ItemTable.create_item("Loot", id, 1, pc, self)
    drop.drop_me(self, x + Rnd.rand(50), y + Rnd.rand(50), z)
    eng.add_new_drop(drop)
  end
end
