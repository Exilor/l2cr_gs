class AbsorberInfo
  # include UniqueId

  def_equals_and_hash @l2id
  property_initializer l2id: Int32, absorbed_hp: Float64
end
