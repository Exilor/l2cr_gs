require "./abstract_variables"

class NpcVariables < AbstractVariables
  @objects : Hash(String, L2Object)?

  def restore_me : Bool
    true
  end

  def store_me : Bool
    true
  end

  def []=(key : String, value : L2Object?)
    return unless value
    (@objects ||= {} of String => L2Object)[key] = value
  end

  def get_i32(key : String) : Int32
    get_i32(key, 0)
  end

  def get_object(key : String, klass : T.class) forall T
    (@objects.try &.[key]?).as(T)
  end
end
