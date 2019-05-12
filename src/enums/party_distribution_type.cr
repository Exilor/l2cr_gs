class PartyDistributionType < EnumClass
  getter sys_string_id
  protected initializer sys_string_id: Int32
  # use #to_i instead of #id
  add(FINDERS_KEEPERS, 487)
  add(RANDOM, 488)
  add(RANDOM_INCLUDING_SPOIL, 798)
  add(BY_TURN, 799)
  add(BY_TURN_INCLUDING_SPOIL, 800)
end
