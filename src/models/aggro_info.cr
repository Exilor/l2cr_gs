class AggroInfo
  getter hate = 0i64
  getter damage = 0

  getter_initializer attacker : L2Character

  def_equals_and_hash @attacker

  def check_hate(owner : L2Character) : Int64
    a = @attacker

    if a.looks_dead? || !a.visible? || !owner.known_list.knows_object?(a)
      @hate = 0i64
    end

    @hate
  end

  def stop_hate
    @hate = 0i64
  end

  def add_hate(value : Int64)
    @hate = Math.min(@hate + value, 999_999_999_i64)
  end

  def add_damage(value : Int32)
    @damage = Math.min(@damage + value.to_i64, 999_999_999).to_i32
  end
end
