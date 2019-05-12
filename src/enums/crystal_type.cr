class CrystalType < EnumClass
  getter crystal_id, crystal_enchant_bonus_armor, crystal_enchant_bonus_weapon
  protected initializer crystal_id: Int32, crystal_enchant_bonus_armor: Int32,
    crystal_enchant_bonus_weapon: Int32

  add(NONE,    0,  0,   0)
  add(D,    1458, 11,  90)
  add(C,    1459,  6,  45)
  add(B,    1460, 11,  67)
  add(A,    1461, 20, 145)
  add(S,    1462, 25, 250)
  add(S80,  1462, 25, 250)
  add(S84,  1462, 25, 250)
end
