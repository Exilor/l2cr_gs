require "./updater_type"

class FortUpdater
  include Loggable

  getter run_count

  initializer fort : Fort, clan : L2Clan, run_count : Int32,
    updater_type : UpdaterType

  def call
    case @updater_type
    when .periodic_update?
      @run_count += 1

      if @fort.owner_clan?.nil? || @fort.owner_clan != @clan
        return
      end

      @fort.owner_clan.increase_blood_oath_count

      if @fort.fort_state == 2
        if @clan.warehouse.adena >= Config.fs_fee_for_castle
          @clan.warehouse.destroy_item_by_item_id("FS_fee_for_Castle", Inventory::ADENA_ID, Config.fs_fee_for_castle, nil, nil)
          @fort.contracted_castle.add_to_treasury_no_tax(Config.fs_fee_for_castle)
          @fort.raise_supply_lvl
        else
          @fort.set_fort_state(1, 0)
        end
      end

      @fort.save_fort_variables
    when .max_own_time?
      if @fort.owner_clan?.nil? || @fort.owner_clan != @clan
        return
      end

      if @fort.owned_time > Config.fs_max_own_time * 3600
        @fort.remove_owner(true)
        @fort.set_fort_state(0, 0)
      end
    end
  rescue e
    error e
  end
end
