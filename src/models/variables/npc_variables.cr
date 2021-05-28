require "./abstract_variables"

class NpcVariables < AbstractVariables
  @objects : Hash(String, L2Character)?

  def restore_me : Bool
    true
  end

  def store_me : Bool
    true
  end

  def []=(key : String, value : L2Character?)
    return unless value
    (@objects ||= {} of String => L2Character)[key] = value
  end

  def get_i32(key : String) : Int32
    get_i32(key, 0)
  end

  def get_i64(key : String) : Int64
    get_i64(key, 0i64)
  end

  def get_object(key : String, klass : T.class) : T forall T
    {% unless T.union_types.all? { |t| t == Nil || t <= L2Character } %}
      {% raise "Can't use #{T} for NpcVariables#get_object" %}
    {% end %}
    (@objects.try &.[key]?).as(T)
  end
end
