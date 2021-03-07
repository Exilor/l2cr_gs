module GameDB
  module ItemReuseDAOMySQLImpl
    extend self
    extend ItemReuseDAO

    private INSERT = "INSERT INTO character_item_reuse_save (charId,itemId,itemObjId,reuseDelay,systime) VALUES (?,?,?,?,?)"
    private SELECT = "SELECT charId,itemId,itemObjId,reuseDelay,systime FROM character_item_reuse_save WHERE charId=?"
    private DELETE = "DELETE FROM character_item_reuse_save WHERE charId=?"

    def delete(pc : L2PcInstance)
      GameDB.exec(DELETE, pc.l2id)
    rescue e
      error e
    end

    def insert(pc : L2PcInstance)
      delete(pc)

      if reuses = pc.item_reuse_time_stamps
        reuses.each_value do |ts|
          if ts.has_not_passed?
            GameDB.exec(
              INSERT,
              pc.l2id,
              ts.item_id,
              ts.item_l2id,
              ts.reuse,
              ts.stamp
            )
          end
        end
      end
    rescue e
      error "Could not store #{pc}'s item reuse data."
      error e
    end

    def load(pc : L2PcInstance)
      GameDB.each(SELECT, pc.l2id) do |rs|
        item_id = rs.get_i32(:"itemId")
        # item_l2id = rs.get_i32(:"itemObjId") # unused
        reuse_delay = rs.get_i64(:"reuseDelay")
        systime = rs.get_i64(:"systime")
        in_inventory = true

        unless item = pc.inventory.get_item_by_item_id(item_id)
          item = pc.warehouse.get_item_by_item_id(item_id)
          in_inventory = false
        end

        if item && item.id == item_id && item.reuse_delay > 0
          remaining = systime - Time.ms
          if remaining > 10
            pc.add_time_stamp_item(item, reuse_delay, systime)
            if in_inventory && item.etc_item?
              group = item.shared_reuse_group
              if group > 0
                debug { "Shared reuse group: #{group}." }
                p = Packets::Outgoing::ExUseSharedGroupItem.new(item_id, group, remaining.to_i32, reuse_delay.to_i32)
                pc.send_packet(p)
              end
            end
          end
        end
      end

      delete(pc)
    rescue e
      error { "Could not restore #{pc}'s item reuse data." }
      error e
    end
  end
end
