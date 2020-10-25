require "../models/entity/couple"

module CoupleManager
  extend self
  extend Loggable

  private COUPLES = Concurrent::Array(Couple).new

  def load
    sql = "SELECT id FROM mods_wedding ORDER BY id"
    GameDB.each(sql) do |rs|
      couples << Couple.new(rs.get_i32(:"id"))
    end
    info { "Loaded #{couples.size} couples." }
  rescue e
    error e
  end

  def reload
    COUPLES.clear
    load
  end

  def get_couple(couple_id : Int32) : Couple
    idx = get_couple_index(couple_id)
    if idx >= 0
      couples.unsafe_at(idx)
    end
  end

  def create_couple(pc1 : L2PcInstance, pc2 : L2PcInstance)
    if pc1.partner_id == 0 && pc2.partner_id == 0
      couple = Couple.new(pc1, pc2)
      couples << couple
      pc1.partner_id = pc2.l2id
      pc2.partner_id = pc1.l2id
      pc1.couple_id = couple.id
      pc2.couple_id = couple.id
    end
  end

  def delete_couple(couple_id : Int32)
    idx = get_couple_index(couple_id)
    if couple = couples[idx]?
      if pc1 = L2World.get_player(couple.player1_id)
        pc1.partner_id = 0
        pc1.married = false
        pc1.couple_id = 0
      end
      if pc2 = L2World.get_player(couple.player2_id)
        pc2.partner_id = 0
        pc2.married = false
        pc2.couple_id = 0
      end
      couple.divorce
      couples.delete_at(idx)
    end
  end

  def get_couple_index(couple_id : Int32) : Int32
    couples.index { |c| c.id == couple_id } || -1
  end

  def couples : Interfaces::Array(Couple)
    COUPLES
  end
end
