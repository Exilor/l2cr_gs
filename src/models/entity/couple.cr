class Couple
  include Loggable

  getter id = 0
  getter player1_id = 0
  getter player2_id = 0
  getter affiance_date = Calendar.new
  getter wedding_date = Calendar.new
  getter? married = false

  def initialize(id : Int32, pc1_id : Int32, pc2_id : Int32, married : Bool, affiance_date : Int64, wedding_date : Int64)
    @id = id
    @player1_id = pc1_id
    @player2_id = pc2_id
    @married = married
    @affiance_date.ms = affiance_date
    @wedding_date.ms = wedding_date
  end

  def initialize(pc1 : L2PcInstance, pc2 : L2PcInstance)
    @player1_id = pc1.l2id
    @player2_id = pc2.l2id
    @id = IdFactory.next

    GameDB.couples.insert(
      @id, @player1_id, @player2_id, @affiance_date.ms, @wedding_date.ms
    )
  end

  def marry
    @wedding_date.ms = Time.ms
    GameDB.couples.update(@wedding_date.ms, @id)
    @married = true
  end

  def divorce
    GameDB.couples.delete(@id)
  end
end
