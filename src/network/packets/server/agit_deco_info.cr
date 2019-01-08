class Packets::Outgoing::AgitDecoInfo < GameServerPacket
  initializer ch: AuctionableHall

  def write_impl
    c 0xfd

    d @ch.id

    fn = @ch.get_function(ClanHall::FUNC_RESTORE_HP)
    if fn.nil? || fn.lvl == 0
      c 0
    elsif (@ch.grade == 0 && fn.lvl < 220) || (@ch.grade == 1 && fn.lvl < 160) || (@ch.grade == 2 && fn.lvl < 260) || (@ch.grade == 3 && fn.lvl < 300)
      c 1
    else
      c 2
    end

    fn = @ch.get_function(ClanHall::FUNC_RESTORE_MP)
    if fn.nil? || fn.lvl == 0
      c 0
      c 0
    elsif ((@ch.grade == 0 || @ch.grade == 1) && (fn.lvl < 25)) || (@ch.grade == 2 && fn.lvl < 30) || (@ch.grade == 3 && fn.lvl < 40)
      c 1
      c 1
    else
      c 2
      c 2
    end

    fn = @ch.get_function(ClanHall::FUNC_RESTORE_EXP)
    if fn.nil? || fn.lvl == 0
      c 0
    elsif (@ch.grade == 0 && fn.lvl < 25) || (@ch.grade == 1 && fn.lvl < 30) || (@ch.grade == 2 && fn.lvl < 40) || (@ch.grade == 3 && fn.lvl < 50)
      c 1
    else
      c 2
    end

    fn = @ch.get_function(ClanHall::FUNC_TELEPORT)
    if fn.nil? || fn.lvl == 0
      c 0
    elsif fn.lvl < 2
      c 1
    else
      c 2
    end
    c 0

    fn = @ch.get_function(ClanHall::FUNC_DECO_CURTAINS)
    if fn.nil? || fn.lvl == 0
      c 0
    elsif fn.lvl <= 1
      c 1
    else
      c 2
    end

    fn = @ch.get_function(ClanHall::FUNC_ITEM_CREATE)
    if fn.nil? || fn.lvl == 0
      c 0
    elsif (@ch.grade == 0 && fn.lvl < 2) || fn.lvl < 3
      c 1
    else
      c 2
    end

    fn = @ch.get_function(ClanHall::FUNC_SUPPORT)
    if fn.nil? || fn.lvl == 0
      c 0
      c 0
    elsif (@ch.grade == 0 && fn.lvl < 2) || (@ch.grade == 1 && fn.lvl < 4) || (@ch.grade == 2 && fn.lvl < 5) || (@ch.grade == 3 && fn.lvl < 8)
      c 1
      c 1
    else
      c 2
      c 2
    end

    fn = @ch.get_function(ClanHall::FUNC_DECO_FRONTPLATEFORM)
    if fn.nil? || fn.lvl == 0
      c 0
    elsif fn.lvl <= 1
      c 1
    else
      c 2
    end

    fn = @ch.get_function(ClanHall::FUNC_ITEM_CREATE)
    if fn.nil? || fn.lvl == 0
      c 0
    elsif (@ch.grade == 0 && fn.lvl < 2) || fn.lvl < 3
      c 1
    else
      c 2
    end
    d 0
    d 0
  end
end
