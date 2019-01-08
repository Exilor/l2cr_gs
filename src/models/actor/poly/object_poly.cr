require "../../interfaces/script_type"

class ObjectPoly
  include ScriptType

  property poly_id : Int32 = 0
  property poly_type : String?

  getter_initializer active_object: L2Object

  def set_poly_info(poly_type : String, poly_id : String)
    self.poly_type = poly_type
    self.poly_id = poly_id.to_i
  end

  def morphed? : Bool
    !!poly_type
  end
end
