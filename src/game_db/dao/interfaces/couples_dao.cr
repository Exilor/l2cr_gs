module GameDB
  module CouplesDAO
    include Loggable

    abstract def load(& : Couple ->)
    abstract def insert(id : Int32, pc1_id : Int32, pc2_id : Int32, affiance_date : Int64, wedding_date : Int64)
    abstract def update(wedding_date : Int64, couple_id : Int32)
    abstract def delete(couple_id : Int32)
  end
end
