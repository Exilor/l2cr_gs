require "../models/entity/couple"

module CoupleManager
  extend self
  include Loggable

  private COUPLES = Concurrent::Map(Int32, Couple).new

  def load
    GameDB.couples.load { |couple| COUPLES[couple.id] = couple }
    info { "Loaded #{COUPLES.size} couples." }
  rescue e
    error e
  end

  def reload
    COUPLES.clear
    load
  end

  def get_couple(couple_id : Int32) : Couple?
    COUPLES[couple_id]?
  end

  def create_couple(pc1 : L2PcInstance, pc2 : L2PcInstance)
    if pc1.partner_id == 0 && pc2.partner_id == 0
      couple = Couple.new(pc1, pc2)
      COUPLES[couple.id] = couple
      pc1.partner_id = pc2.l2id
      pc2.partner_id = pc1.l2id
      pc1.couple_id = couple.id
      pc2.couple_id = couple.id
    end
  end

  def delete_couple(couple_id : Int32)
    if couple = COUPLES.delete(couple_id)
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
    end
  end

  def couples : Enumerable(Couple)
    COUPLES.local_each_value
  end
end
