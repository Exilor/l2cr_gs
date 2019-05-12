class Q00735_MakeSpearsDull < TerritoryWarSuperClass
  def initialize
    super(735, self.class.simple_name, "Make Spears Dull")

    @class_ids = [
      23,
      101,
      36,
      108,
      8,
      93,
      2,
      88,
      3,
      89,
      48,
      114,
      46,
      113,
      55,
      117,
      9,
      92,
      24,
      102,
      37,
      109,
      34,
      107,
      21,
      100,
      127,
      131,
      128,
      132,
      129,
      133,
      130,
      134,
      135,
      136
    ]
    @random_min = 15
    @random_max = 20
    @npc_string = [
      NpcString::YOU_HAVE_DEFEATED_S2_OF_S1_WARRIORS_AND_ROGUES,
      NpcString::YOU_WEAKENED_THE_ENEMYS_ATTACK
    ]
  end
end
