class StatFunction < EnumClass
  getter_initializer name: String, order: Int32

  add(ADD, "Add", 30)
  add(DIV, "Div", 20)
  add(ENCHANT, "Enchant", 0)
  add(ENCHANTHP, "EnchantHp", 40)
  add(MUL, "Mul", 20)
  add(SET, "Set", 0)
  add(SHARE, "Share", 30)
  add(SUB, "Sub", 30)
end
